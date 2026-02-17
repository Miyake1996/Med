import SwiftUI
import SwiftData

/// 検査記録詳細表示ビュー
struct RecordDetailView: View {
    let record: ExaminationRecord
    let patient: Patient
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditRecord = false

    var body: some View {
        List {
            // 記録日
            Section {
                HStack {
                    Text("記録日")
                    Spacer()
                    Text(record.recordDate, style: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .fontWeight(.medium)
                }
            }

            // 身体計測
            if record.height != nil || record.weight != nil || record.waistCircumference != nil {
                Section("身体計測") {
                    optionalRow("身長", value: record.height, format: "%.1f", unit: "cm")
                    optionalRow("体重", value: record.weight, format: "%.1f", unit: "kg")
                    if let bmi = record.bmi {
                        evaluatedRow("BMI", value: String(format: "%.1f", bmi), unit: "kg/m²",
                                     evaluation: ReferenceDatabase.bmi.evaluate(bmi))
                    }
                    optionalRow("腹囲", value: record.waistCircumference, format: "%.1f", unit: "cm")
                }
            }

            // バイタルサイン
            if record.systolicBP != nil || record.heartRate != nil {
                Section("バイタルサイン") {
                    if let sys = record.systolicBP, let dia = record.diastolicBP {
                        let eval = ReferenceDatabase.systolicBP.evaluate(Double(sys))
                        evaluatedRow("血圧", value: "\(sys)/\(dia)", unit: "mmHg", evaluation: eval)
                        HStack {
                            Text("分類")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.bpClassification(systolic: sys, diastolic: dia))
                                .font(.caption)
                        }
                    }
                    if let hr = record.heartRate {
                        plainRow("脈拍", value: "\(hr)", unit: "/min")
                    }
                }
            }

            // 血糖関連
            if record.fastingGlucose != nil || record.hba1c != nil || record.casualGlucose != nil {
                Section("血糖関連") {
                    if let fg = record.fastingGlucose {
                        evaluatedRow("空腹時血糖", value: "\(fg)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.fastingGlucose.evaluate(Double(fg)))
                    }
                    if let a1c = record.hba1c {
                        evaluatedRow("HbA1c", value: String(format: "%.1f", a1c), unit: "%",
                                     evaluation: ReferenceDatabase.hba1c.evaluate(a1c))
                        HStack {
                            Text("コントロール")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.diabetesControl(hba1c: a1c))
                                .font(.caption)
                        }
                    }
                    if let cg = record.casualGlucose {
                        evaluatedRow("随時血糖", value: "\(cg)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.casualGlucose.evaluate(Double(cg)))
                    }
                    optionalRow("グリコアルブミン", value: record.glycoalbumin, format: "%.1f", unit: "%")
                }
            }

            // 脂質
            if record.ldlCholesterol != nil || record.hdlCholesterol != nil || record.triglycerides != nil {
                Section("脂質") {
                    if let tc = record.totalCholesterol {
                        evaluatedRow("総コレステロール", value: "\(tc)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.totalCholesterol.evaluate(Double(tc)))
                    }
                    if let ldl = record.ldlCholesterol {
                        evaluatedRow("LDL-C", value: "\(ldl)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.ldlCholesterol.evaluate(Double(ldl)))
                    }
                    if let hdl = record.hdlCholesterol {
                        evaluatedRow("HDL-C", value: "\(hdl)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.hdlCholesterol.evaluate(Double(hdl)))
                    }
                    if let tg = record.triglycerides {
                        evaluatedRow("中性脂肪", value: "\(tg)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.triglycerides.evaluate(Double(tg)))
                    }
                    if let nonHDL = record.calculatedNonHDL {
                        evaluatedRow("Non-HDL-C", value: "\(nonHDL)", unit: "mg/dL",
                                     evaluation: ReferenceDatabase.nonHDLCholesterol.evaluate(Double(nonHDL)))
                    }
                }
            }

            // 肝機能
            if record.ast != nil || record.alt != nil || record.gammaGTP != nil {
                Section("肝機能") {
                    if let ast = record.ast {
                        evaluatedRow("AST", value: "\(ast)", unit: "U/L",
                                     evaluation: ReferenceDatabase.ast.evaluate(Double(ast)))
                    }
                    if let alt = record.alt {
                        evaluatedRow("ALT", value: "\(alt)", unit: "U/L",
                                     evaluation: ReferenceDatabase.alt.evaluate(Double(alt)))
                    }
                    if let ggt = record.gammaGTP {
                        evaluatedRow("γ-GTP", value: "\(ggt)", unit: "U/L",
                                     evaluation: ReferenceDatabase.gammaGTP.evaluate(Double(ggt)))
                    }
                }
            }

            // 腎機能
            if record.creatinine != nil || record.eGFR != nil || record.uricAcid != nil {
                Section("腎機能") {
                    optionalRow("BUN", value: record.bun, format: "%.1f", unit: "mg/dL")
                    if let cr = record.creatinine {
                        evaluatedRow("Cr", value: String(format: "%.2f", cr), unit: "mg/dL",
                                     evaluation: ReferenceDatabase.creatinine.evaluate(cr))
                    }
                    if let egfr = record.calculatedEGFR(gender: patient.gender, age: patient.age) {
                        evaluatedRow("eGFR", value: String(format: "%.1f", egfr), unit: "mL/min/1.73m²",
                                     evaluation: ReferenceDatabase.eGFR.evaluate(egfr))
                        HStack {
                            Text("CKDステージ")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.ckdStage(eGFR: egfr))
                                .font(.caption)
                        }
                    }
                    if let ua = record.uricAcid {
                        evaluatedRow("尿酸", value: String(format: "%.1f", ua), unit: "mg/dL",
                                     evaluation: ReferenceDatabase.uricAcid.evaluate(ua))
                    }
                }
            }

            // 尿検査
            if record.urineProtein != nil || record.urineGlucose != nil || record.urineOccultBlood != nil {
                Section("尿検査") {
                    if let up = record.urineProtein {
                        urineRow("尿蛋白", value: up)
                    }
                    if let ug = record.urineGlucose {
                        urineRow("尿糖", value: ug)
                    }
                    if let uob = record.urineOccultBlood {
                        urineRow("尿潜血", value: uob)
                    }
                    optionalRow("尿アルブミン", value: record.urineAlbumin, format: "%.1f", unit: "mg/gCr")
                }
            }

            // 血算
            if record.wbc != nil || record.hemoglobin != nil || record.platelets != nil {
                Section("血算") {
                    if let wbc = record.wbc {
                        evaluatedRow("WBC", value: String(format: "%.1f", wbc), unit: "×10³/μL",
                                     evaluation: ReferenceDatabase.wbc.evaluate(wbc))
                    }
                    optionalRow("RBC", value: record.rbc, format: "%.1f", unit: "×10⁴/μL")
                    if let hb = record.hemoglobin {
                        evaluatedRow("Hb", value: String(format: "%.1f", hb), unit: "g/dL",
                                     evaluation: ReferenceDatabase.hemoglobin.evaluate(hb))
                    }
                    optionalRow("Ht", value: record.hematocrit, format: "%.1f", unit: "%")
                    if let plt = record.platelets {
                        evaluatedRow("Plt", value: String(format: "%.1f", plt), unit: "×10⁴/μL",
                                     evaluation: ReferenceDatabase.platelets.evaluate(plt))
                    }
                }
            }

            // 心電図
            if record.ecgNormal != nil {
                Section("心電図") {
                    HStack {
                        Text("判定")
                        Spacer()
                        if record.ecgNormal == true {
                            Label("正常", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("異常あり", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    if let findings = record.ecgFindings, !findings.isEmpty {
                        VStack(alignment: .leading) {
                            Text("所見")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(findings)
                        }
                    }
                }
            }

            // 生活習慣
            if record.smokingStatus != nil || record.drinkingFrequency != nil || record.exerciseFrequency != nil {
                Section("生活習慣") {
                    if let s = record.smokingStatus {
                        plainRow("喫煙", value: s.rawValue, unit: "")
                    }
                    if let d = record.drinkingFrequency {
                        plainRow("飲酒", value: d.rawValue, unit: "")
                    }
                    if let e = record.exerciseFrequency {
                        plainRow("運動", value: e.rawValue, unit: "")
                    }
                    optionalRow("睡眠時間", value: record.sleepHours, format: "%.1f", unit: "時間")
                }
            }

            // メモ
            if record.clinicalNotes != nil || record.treatmentPlan != nil {
                Section("診察所見・メモ") {
                    if let notes = record.clinicalNotes, !notes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("診察所見")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(notes)
                        }
                    }
                    if let plan = record.treatmentPlan, !plan.isEmpty {
                        VStack(alignment: .leading) {
                            Text("治療方針")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(plan)
                        }
                    }
                }
            }
        }
        .navigationTitle("検査記録詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("編集") { showingEditRecord = true }
            }
        }
        .sheet(isPresented: $showingEditRecord) {
            RecordEntryView(patient: patient, existingRecord: record)
        }
    }

    // MARK: - 行ヘルパー

    private func plainRow(_ label: String, value: String, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
            if !unit.isEmpty {
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func optionalRow(_ label: String, value: Double?, format: String, unit: String) -> some View {
        Group {
            if let v = value {
                plainRow(label, value: String(format: format, v), unit: unit)
            }
        }
    }

    private func evaluatedRow(_ label: String, value: String, unit: String, evaluation: Evaluation) -> some View {
        HStack {
            Image(systemName: evaluation.icon)
                .foregroundStyle(colorForEvaluation(evaluation))
                .font(.caption)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(colorForEvaluation(evaluation))
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func urineRow(_ label: String, value: String) -> some View {
        let eval = ReferenceDatabase.evaluateUrineQualitative(value)
        return HStack {
            Image(systemName: eval.icon)
                .foregroundStyle(colorForEvaluation(eval))
                .font(.caption)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(colorForEvaluation(eval))
        }
    }

    private func colorForEvaluation(_ eval: Evaluation) -> Color {
        switch eval {
        case .normal: return .green
        case .caution: return .orange
        case .abnormal: return .red
        }
    }
}
