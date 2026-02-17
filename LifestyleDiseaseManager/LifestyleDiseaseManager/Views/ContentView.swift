import SwiftUI
import SwiftData

/// メインタブビュー
struct ContentView: View {
    var body: some View {
        TabView {
            PatientListView()
                .tabItem {
                    Label("患者一覧", systemImage: "person.3.fill")
                }

            SummaryDashboardView()
                .tabItem {
                    Label("ダッシュボード", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

/// ダッシュボード - 全患者の概要
struct SummaryDashboardView: View {
    @Query(sort: \Patient.name) private var patients: [Patient]

    var body: some View {
        NavigationStack {
            List {
                if patients.isEmpty {
                    ContentUnavailableView(
                        "患者データがありません",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("「患者一覧」タブから患者を登録してください")
                    )
                } else {
                    Section("疾患別患者数") {
                        ForEach(DiseaseType.allCases) { disease in
                            let count = patients.filter { $0.diseases.contains(disease) }.count
                            HStack {
                                Image(systemName: disease.icon)
                                    .foregroundStyle(colorForDisease(disease))
                                Text(disease.rawValue)
                                Spacer()
                                Text("\(count)名")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section("要注意患者") {
                        let alertPatients = patientsNeedingAttention()
                        if alertPatients.isEmpty {
                            Text("該当なし")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(alertPatients, id: \.patient.id) { item in
                                NavigationLink(destination: PatientDetailView(patient: item.patient)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.patient.name)
                                            .font(.headline)
                                        Text(item.reason)
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }

                    Section("最近の受診") {
                        let recentPatients = patientsWithRecentRecords()
                        if recentPatients.isEmpty {
                            Text("記録がありません")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(recentPatients, id: \.id) { patient in
                                NavigationLink(destination: PatientDetailView(patient: patient)) {
                                    HStack {
                                        Text(patient.name)
                                        Spacer()
                                        if let latest = patient.latestRecord {
                                            Text(latest.recordDate, style: .date)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("ダッシュボード")
        }
    }

    private func colorForDisease(_ disease: DiseaseType) -> Color {
        switch disease {
        case .diabetes: return .orange
        case .hypertension: return .red
        case .dyslipidemia: return .purple
        }
    }

    private func patientsNeedingAttention() -> [(patient: Patient, reason: String)] {
        var results: [(patient: Patient, reason: String)] = []
        for patient in patients {
            guard let record = patient.latestRecord else { continue }
            var reasons: [String] = []
            if let hba1c = record.hba1c, hba1c >= 8.0 {
                reasons.append("HbA1c \(String(format: "%.1f", hba1c))%")
            }
            if let sys = record.systolicBP, sys >= 160 {
                reasons.append("血圧 \(sys)mmHg")
            }
            if let ldl = record.ldlCholesterol, ldl >= 180 {
                reasons.append("LDL \(ldl)mg/dL")
            }
            if let egfr = record.calculatedEGFR(gender: patient.gender, age: patient.age), egfr < 30 {
                reasons.append("eGFR \(String(format: "%.1f", egfr))")
            }
            if !reasons.isEmpty {
                results.append((patient: patient, reason: reasons.joined(separator: "、")))
            }
        }
        return results
    }

    private func patientsWithRecentRecords() -> [Patient] {
        patients
            .filter { $0.latestRecord != nil }
            .sorted { ($0.latestRecord?.recordDate ?? .distantPast) > ($1.latestRecord?.recordDate ?? .distantPast) }
            .prefix(10)
            .map { $0 }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Patient.self, ExaminationRecord.self], inMemory: true)
}
