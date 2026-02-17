import SwiftUI
import SwiftData

/// 患者一覧ビュー
struct PatientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Patient.name) private var patients: [Patient]
    @State private var showingAddPatient = false
    @State private var searchText = ""

    private var filteredPatients: [Patient] {
        if searchText.isEmpty { return patients }
        return patients.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.kanaName.localizedCaseInsensitiveContains(searchText) ||
            $0.medicalRecordNumber.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if filteredPatients.isEmpty {
                    ContentUnavailableView(
                        searchText.isEmpty ? "患者が登録されていません" : "該当する患者がいません",
                        systemImage: searchText.isEmpty ? "person.crop.circle.badge.plus" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "右上の＋ボタンから患者を登録してください" : "検索条件を変更してください")
                    )
                } else {
                    ForEach(filteredPatients) { patient in
                        NavigationLink(destination: PatientDetailView(patient: patient)) {
                            PatientRowView(patient: patient)
                        }
                    }
                    .onDelete(perform: deletePatients)
                }
            }
            .navigationTitle("患者一覧")
            .searchable(text: $searchText, prompt: "名前・カナ・ID で検索")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPatient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPatient) {
                PatientEditView(mode: .add)
            }
        }
    }

    private func deletePatients(at offsets: IndexSet) {
        for index in offsets {
            let patient = filteredPatients[index]
            modelContext.delete(patient)
        }
    }
}

/// 患者行ビュー
struct PatientRowView: View {
    let patient: Patient

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(patient.name)
                    .font(.headline)
                Spacer()
                if !patient.medicalRecordNumber.isEmpty {
                    Text("ID: \(patient.medicalRecordNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Label("\(patient.age)歳", systemImage: "person.fill")
                    .font(.caption)
                Label(patient.gender.rawValue, systemImage: patient.gender == .male ? "figure.stand" : "figure.stand.dress")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            if !patient.diseases.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patient.diseases) { disease in
                        Text(disease.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(diseaseColor(disease).opacity(0.15))
                            .foregroundStyle(diseaseColor(disease))
                            .clipShape(Capsule())
                    }
                }
            }

            if let latest = patient.latestRecord {
                HStack {
                    Image(systemName: "clock")
                    Text("最終受診: ")
                    Text(latest.recordDate, style: .date)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func diseaseColor(_ disease: DiseaseType) -> Color {
        switch disease {
        case .diabetes: return .orange
        case .hypertension: return .red
        case .dyslipidemia: return .purple
        }
    }
}

/// 患者登録・編集ビュー
struct PatientEditView: View {
    enum Mode {
        case add
        case edit(Patient)
    }

    let mode: Mode
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var kanaName = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -50, to: Date()) ?? Date()
    @State private var gender: Gender = .male
    @State private var selectedDiseases: Set<DiseaseType> = []
    @State private var medicalRecordNumber = ""
    @State private var memo = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("基本情報") {
                    TextField("氏名", text: $name)
                    TextField("フリガナ", text: $kanaName)
                    DatePicker("生年月日", selection: $birthDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                    Picker("性別", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Text(g.rawValue).tag(g)
                        }
                    }
                }

                Section("疾患") {
                    ForEach(DiseaseType.allCases) { disease in
                        Toggle(disease.rawValue, isOn: Binding(
                            get: { selectedDiseases.contains(disease) },
                            set: { isOn in
                                if isOn { selectedDiseases.insert(disease) }
                                else { selectedDiseases.remove(disease) }
                            }
                        ))
                    }
                }

                Section("その他") {
                    TextField("カルテ番号", text: $medicalRecordNumber)
                        .keyboardType(.numberPad)
                    TextField("メモ", text: $memo, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isAddMode ? "患者登録" : "患者編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.isEmpty)
                }
            }
            .onAppear { loadExistingData() }
        }
    }

    private var isAddMode: Bool {
        if case .add = mode { return true }
        return false
    }

    private func loadExistingData() {
        if case .edit(let patient) = mode {
            name = patient.name
            kanaName = patient.kanaName
            birthDate = patient.birthDate
            gender = patient.gender
            selectedDiseases = Set(patient.diseases)
            medicalRecordNumber = patient.medicalRecordNumber
            memo = patient.memo
        }
    }

    private func save() {
        switch mode {
        case .add:
            let patient = Patient(
                name: name,
                kanaName: kanaName,
                birthDate: birthDate,
                gender: gender,
                diseases: Array(selectedDiseases),
                medicalRecordNumber: medicalRecordNumber,
                memo: memo
            )
            modelContext.insert(patient)
        case .edit(let patient):
            patient.name = name
            patient.kanaName = kanaName
            patient.birthDate = birthDate
            patient.gender = gender
            patient.diseases = Array(selectedDiseases)
            patient.medicalRecordNumber = medicalRecordNumber
            patient.memo = memo
            patient.updatedAt = Date()
        }
        dismiss()
    }
}
