import SwiftUI
import SwiftData

/// 患者詳細ビュー
struct PatientDetailView: View {
    @Bindable var patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddRecord = false
    @State private var showingEditPatient = false

    private var sortedRecords: [ExaminationRecord] {
        patient.records.sorted { $0.recordDate > $1.recordDate }
    }

    var body: some View {
        List {
            // 患者情報セクション
            Section {
                patientInfoSection
            }

            // 最新検査結果の評価
            if let latest = patient.latestRecord {
                Section("最新検査結果の評価") {
                    latestAssessmentSection(record: latest)
                }

                // 前回比較
                if sortedRecords.count >= 2 {
                    Section("前回との比較") {
                        comparisonSection(current: sortedRecords[0], previous: sortedRecords[1])
                    }
                }
            }

            // 検査履歴
            Section("検査履歴（\(patient.records.count)件）") {
                if sortedRecords.isEmpty {
                    Text("記録がありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedRecords) { record in
                        NavigationLink(destination: RecordDetailView(record: record, patient: patient)) {
                            recordRowView(record: record)
                        }
                    }
                    .onDelete(perform: deleteRecords)
                }
            }
        }
        .navigationTitle(patient.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingAddRecord = true }) {
                        Label("検査記録を追加", systemImage: "plus.circle")
                    }
                    Button(action: { showingEditPatient = true }) {
                        Label("患者情報を編集", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            RecordEntryView(patient: patient)
        }
        .sheet(isPresented: $showingEditPatient) {
            PatientEditView(mode: .edit(patient))
        }
    }

    // MARK: - 患者情報

    private var patientInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    if !patient.kanaName.isEmpty {
                        Text(patient.kanaName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(patient.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                if !patient.medicalRecordNumber.isEmpty {
                    VStack(alignment: .trailing) {
                        Text("カルテ番号")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(patient.medicalRecordNumber)
                            .font(.headline)
                    }
                }
            }

            Divider()

            HStack(spacing: 20) {
                Label("\(patient.age)歳", systemImage: "person.fill")
                Label(patient.gender.rawValue, systemImage: patient.gender == .male ? "figure.stand" : "figure.stand.dress")
                Label(patient.birthDate, format: .dateTime.year().month().day())
                    .environment(\.locale, Locale(identifier: "ja_JP"))
            }
            .font(.subheadline)

            if !patient.diseases.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patient.diseases) { disease in
                        HStack(spacing: 4) {
                            Image(systemName: disease.icon)
                            Text(disease.rawValue)
                        }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(diseaseColor(disease).opacity(0.12))
                        .foregroundStyle(diseaseColor(disease))
                        .clipShape(Capsule())
                    }
                }
            }

            if !patient.memo.isEmpty {
                Text(patient.memo)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - 最新検査結果の評価

    private func latestAssessmentSection(record: ExaminationRecord) -> some View {
        let items = HealthAssessment.generateSummary(record: record, patient: patient)
        let grouped = Dictionary(grouping: items, by: \.category)
        let categories = ["身体計測", "バイタルサイン", "血糖", "脂質", "肝機能", "腎機能", "尿検査", "血算"]

        return ForEach(categories.filter { grouped[$0] != nil }, id: \.self) { category in
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fontWeight(.semibold)
                ForEach(grouped[category] ?? []) { item in
                    HStack {
                        Image(systemName: item.evaluation.icon)
                            .foregroundStyle(colorForEvaluation(item.evaluation))
                            .font(.caption)
                        Text(item.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.value) \(item.unit)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(colorForEvaluation(item.evaluation))
                        if let note = item.note {
                            Text(note)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - 前回比較

    private func comparisonSection(current: ExaminationRecord, previous: ExaminationRecord) -> some View {
        let comparisons = HealthAssessment.compareToPrevious(current: current, previous: previous)
        return ForEach(comparisons) { item in
            HStack {
                Text(item.name)
                    .font(.subheadline)
                Spacer()
                Text(String(format: item.format, item.previous))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(String(format: item.format, item.current))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("(\(item.formattedDifference))")
                    .font(.caption)
                    .foregroundStyle(item.difference > 0 ? .red : .green)
                Text(item.trend)
                    .font(.caption)
            }
        }
    }

    // MARK: - 検査記録行

    private func recordRowView(record: ExaminationRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.recordDate, style: .date)
                    .font(.headline)
                    .environment(\.locale, Locale(identifier: "ja_JP"))
                Spacer()
            }
            HStack(spacing: 12) {
                if let sys = record.systolicBP, let dia = record.diastolicBP {
                    Label("BP \(sys)/\(dia)", systemImage: "heart.fill")
                        .font(.caption)
                }
                if let hba1c = record.hba1c {
                    Label("A1c \(String(format: "%.1f", hba1c))%", systemImage: "drop.fill")
                        .font(.caption)
                }
                if let bmi = record.bmi {
                    Label("BMI \(String(format: "%.1f", bmi))", systemImage: "figure.stand")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    // MARK: - ヘルパー

    private func deleteRecords(at offsets: IndexSet) {
        for index in offsets {
            let record = sortedRecords[index]
            modelContext.delete(record)
        }
    }

    private func colorForEvaluation(_ eval: Evaluation) -> Color {
        switch eval {
        case .normal: return .green
        case .caution: return .orange
        case .abnormal: return .red
        }
    }

    private func diseaseColor(_ disease: DiseaseType) -> Color {
        switch disease {
        case .diabetes: return .orange
        case .hypertension: return .red
        case .dyslipidemia: return .purple
        }
    }
}
