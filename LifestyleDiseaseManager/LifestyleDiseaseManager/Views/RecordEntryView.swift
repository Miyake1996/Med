import SwiftUI
import SwiftData

/// 検査記録入力ビュー
struct RecordEntryView: View {
    let patient: Patient
    var existingRecord: ExaminationRecord?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 記録日
    @State private var recordDate = Date()

    // 身体計測
    @State private var height = ""
    @State private var weight = ""
    @State private var waistCircumference = ""

    // バイタルサイン
    @State private var systolicBP = ""
    @State private var diastolicBP = ""
    @State private var heartRate = ""

    // 血糖関連
    @State private var fastingGlucose = ""
    @State private var hba1c = ""
    @State private var casualGlucose = ""
    @State private var glycoalbumin = ""

    // 脂質
    @State private var totalCholesterol = ""
    @State private var ldlCholesterol = ""
    @State private var hdlCholesterol = ""
    @State private var triglycerides = ""
    @State private var nonHDLCholesterol = ""

    // 肝機能
    @State private var ast = ""
    @State private var alt = ""
    @State private var gammaGTP = ""

    // 腎機能
    @State private var bun = ""
    @State private var creatinine = ""
    @State private var eGFR = ""
    @State private var uricAcid = ""

    // 尿検査
    @State private var urineProtein = "-"
    @State private var urineGlucose = "-"
    @State private var urineOccultBlood = "-"
    @State private var urineAlbumin = ""

    // 血算
    @State private var wbc = ""
    @State private var rbc = ""
    @State private var hemoglobin = ""
    @State private var hematocrit = ""
    @State private var platelets = ""

    // 心電図
    @State private var ecgFindings = ""
    @State private var ecgNormal = true

    // 生活習慣
    @State private var smokingStatus: SmokingStatus = .never
    @State private var drinkingFrequency: DrinkingFrequency = .none
    @State private var exerciseFrequency: ExerciseFrequency = .none
    @State private var sleepHours = ""

    // メモ
    @State private var clinicalNotes = ""
    @State private var treatmentPlan = ""

    private let urineOptions = ["-", "±", "+", "2+", "3+"]

    var body: some View {
        NavigationStack {
            Form {
                Section("記録日") {
                    DatePicker("日付", selection: $recordDate, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }

                Section("身体計測") {
                    numberField("身長", text: $height, unit: "cm")
                    numberField("体重", text: $weight, unit: "kg")
                    numberField("腹囲", text: $waistCircumference, unit: "cm")
                    if let h = Double(height), let w = Double(weight), h > 0 {
                        let bmi = w / pow(h / 100, 2)
                        HStack {
                            Text("BMI")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.1f kg/m²", bmi))
                                .foregroundStyle(bmi >= 18.5 && bmi < 25.0 ? .green : .orange)
                                .fontWeight(.medium)
                        }
                    }
                }

                Section("バイタルサイン") {
                    numberField("収縮期血圧", text: $systolicBP, unit: "mmHg")
                    numberField("拡張期血圧", text: $diastolicBP, unit: "mmHg")
                    numberField("脈拍", text: $heartRate, unit: "/min")
                    if let sys = Int(systolicBP), let dia = Int(diastolicBP) {
                        HStack {
                            Text("判定")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.bpClassification(systolic: sys, diastolic: dia))
                                .foregroundStyle(sys < 140 && dia < 90 ? .green : .orange)
                                .fontWeight(.medium)
                        }
                    }
                }

                Section("血糖関連") {
                    numberField("空腹時血糖", text: $fastingGlucose, unit: "mg/dL")
                    numberField("HbA1c", text: $hba1c, unit: "%")
                    numberField("随時血糖", text: $casualGlucose, unit: "mg/dL")
                    numberField("グリコアルブミン", text: $glycoalbumin, unit: "%")
                    if let a1c = Double(hba1c) {
                        HStack {
                            Text("判定")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.diabetesControl(hba1c: a1c))
                                .foregroundStyle(a1c < 7.0 ? .green : .orange)
                                .fontWeight(.medium)
                        }
                    }
                }

                Section("脂質") {
                    numberField("総コレステロール", text: $totalCholesterol, unit: "mg/dL")
                    numberField("LDL-C", text: $ldlCholesterol, unit: "mg/dL")
                    numberField("HDL-C", text: $hdlCholesterol, unit: "mg/dL")
                    numberField("中性脂肪", text: $triglycerides, unit: "mg/dL")
                    numberField("Non-HDL-C", text: $nonHDLCholesterol, unit: "mg/dL")
                    if let tc = Int(totalCholesterol), let hdl = Int(hdlCholesterol), nonHDLCholesterol.isEmpty {
                        HStack {
                            Text("Non-HDL-C（計算値）")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(tc - hdl) mg/dL")
                                .fontWeight(.medium)
                        }
                    }
                }

                Section("肝機能") {
                    numberField("AST", text: $ast, unit: "U/L")
                    numberField("ALT", text: $alt, unit: "U/L")
                    numberField("γ-GTP", text: $gammaGTP, unit: "U/L")
                }

                Section("腎機能") {
                    numberField("BUN", text: $bun, unit: "mg/dL")
                    numberField("Cr", text: $creatinine, unit: "mg/dL")
                    numberField("eGFR", text: $eGFR, unit: "mL/min/1.73m²")
                    numberField("尿酸", text: $uricAcid, unit: "mg/dL")
                    if let cr = Double(creatinine), cr > 0, eGFR.isEmpty {
                        let base = 194.0 * pow(cr, -1.094) * pow(Double(patient.age), -0.287)
                        let calculatedEGFR = patient.gender == .female ? base * 0.739 : base
                        HStack {
                            Text("eGFR（計算値）")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(String(format: "%.1f mL/min/1.73m²", calculatedEGFR))
                                .foregroundStyle(calculatedEGFR >= 60 ? .green : .orange)
                                .fontWeight(.medium)
                        }
                        HStack {
                            Text("CKDステージ")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(ReferenceDatabase.ckdStage(eGFR: calculatedEGFR))
                                .font(.caption)
                        }
                    }
                }

                Section("尿検査") {
                    Picker("尿蛋白", selection: $urineProtein) {
                        ForEach(urineOptions, id: \.self) { Text($0) }
                    }
                    Picker("尿糖", selection: $urineGlucose) {
                        ForEach(urineOptions, id: \.self) { Text($0) }
                    }
                    Picker("尿潜血", selection: $urineOccultBlood) {
                        ForEach(urineOptions, id: \.self) { Text($0) }
                    }
                    numberField("尿アルブミン", text: $urineAlbumin, unit: "mg/gCr")
                }

                Section("血算") {
                    numberField("WBC", text: $wbc, unit: "×10³/μL")
                    numberField("RBC", text: $rbc, unit: "×10⁴/μL")
                    numberField("Hb", text: $hemoglobin, unit: "g/dL")
                    numberField("Ht", text: $hematocrit, unit: "%")
                    numberField("Plt", text: $platelets, unit: "×10⁴/μL")
                }

                Section("心電図") {
                    Toggle("心電図正常", isOn: $ecgNormal)
                    if !ecgNormal {
                        TextField("所見", text: $ecgFindings, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }

                Section("生活習慣") {
                    Picker("喫煙", selection: $smokingStatus) {
                        ForEach(SmokingStatus.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("飲酒", selection: $drinkingFrequency) {
                        ForEach(DrinkingFrequency.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("運動", selection: $exerciseFrequency) {
                        ForEach(ExerciseFrequency.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    numberField("睡眠時間", text: $sleepHours, unit: "時間")
                }

                Section("診察所見・メモ") {
                    TextField("診察所見", text: $clinicalNotes, axis: .vertical)
                        .lineLimit(3...8)
                    TextField("治療方針", text: $treatmentPlan, axis: .vertical)
                        .lineLimit(3...8)
                }
            }
            .navigationTitle(existingRecord == nil ? "検査記録入力" : "検査記録編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
            .onAppear { loadExistingData() }
        }
    }

    // MARK: - ヘルパービュー

    private func numberField(_ label: String, text: Binding<String>, unit: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            TextField("", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)
        }
    }

    // MARK: - データ読み込み

    private func loadExistingData() {
        guard let record = existingRecord else { return }
        recordDate = record.recordDate

        if let v = record.height { height = String(format: "%.1f", v) }
        if let v = record.weight { weight = String(format: "%.1f", v) }
        if let v = record.waistCircumference { waistCircumference = String(format: "%.1f", v) }

        if let v = record.systolicBP { systolicBP = "\(v)" }
        if let v = record.diastolicBP { diastolicBP = "\(v)" }
        if let v = record.heartRate { heartRate = "\(v)" }

        if let v = record.fastingGlucose { fastingGlucose = "\(v)" }
        if let v = record.hba1c { hba1c = String(format: "%.1f", v) }
        if let v = record.casualGlucose { casualGlucose = "\(v)" }
        if let v = record.glycoalbumin { glycoalbumin = String(format: "%.1f", v) }

        if let v = record.totalCholesterol { totalCholesterol = "\(v)" }
        if let v = record.ldlCholesterol { ldlCholesterol = "\(v)" }
        if let v = record.hdlCholesterol { hdlCholesterol = "\(v)" }
        if let v = record.triglycerides { triglycerides = "\(v)" }
        if let v = record.nonHDLCholesterol { nonHDLCholesterol = "\(v)" }

        if let v = record.ast { ast = "\(v)" }
        if let v = record.alt { alt = "\(v)" }
        if let v = record.gammaGTP { gammaGTP = "\(v)" }

        if let v = record.bun { bun = String(format: "%.1f", v) }
        if let v = record.creatinine { creatinine = String(format: "%.2f", v) }
        if let v = record.eGFR { eGFR = String(format: "%.1f", v) }
        if let v = record.uricAcid { uricAcid = String(format: "%.1f", v) }

        if let v = record.urineProtein { urineProtein = v }
        if let v = record.urineGlucose { urineGlucose = v }
        if let v = record.urineOccultBlood { urineOccultBlood = v }
        if let v = record.urineAlbumin { urineAlbumin = String(format: "%.1f", v) }

        if let v = record.wbc { wbc = String(format: "%.1f", v) }
        if let v = record.rbc { rbc = String(format: "%.1f", v) }
        if let v = record.hemoglobin { hemoglobin = String(format: "%.1f", v) }
        if let v = record.hematocrit { hematocrit = String(format: "%.1f", v) }
        if let v = record.platelets { platelets = String(format: "%.1f", v) }

        if let v = record.ecgNormal { ecgNormal = v }
        if let v = record.ecgFindings { ecgFindings = v }

        if let v = record.smokingStatus { smokingStatus = v }
        if let v = record.drinkingFrequency { drinkingFrequency = v }
        if let v = record.exerciseFrequency { exerciseFrequency = v }
        if let v = record.sleepHours { sleepHours = String(format: "%.1f", v) }

        clinicalNotes = record.clinicalNotes ?? ""
        treatmentPlan = record.treatmentPlan ?? ""
    }

    // MARK: - 保存

    private func save() {
        let record = existingRecord ?? ExaminationRecord(patient: patient, recordDate: recordDate)

        record.recordDate = recordDate

        record.height = Double(height)
        record.weight = Double(weight)
        record.waistCircumference = Double(waistCircumference)

        record.systolicBP = Int(systolicBP)
        record.diastolicBP = Int(diastolicBP)
        record.heartRate = Int(heartRate)

        record.fastingGlucose = Int(fastingGlucose)
        record.hba1c = Double(hba1c)
        record.casualGlucose = Int(casualGlucose)
        record.glycoalbumin = Double(glycoalbumin)

        record.totalCholesterol = Int(totalCholesterol)
        record.ldlCholesterol = Int(ldlCholesterol)
        record.hdlCholesterol = Int(hdlCholesterol)
        record.triglycerides = Int(triglycerides)
        record.nonHDLCholesterol = Int(nonHDLCholesterol)

        record.ast = Int(ast)
        record.alt = Int(alt)
        record.gammaGTP = Int(gammaGTP)

        record.bun = Double(bun)
        record.creatinine = Double(creatinine)
        record.eGFR = Double(eGFR)
        record.uricAcid = Double(uricAcid)

        record.urineProtein = urineProtein
        record.urineGlucose = urineGlucose
        record.urineOccultBlood = urineOccultBlood
        record.urineAlbumin = Double(urineAlbumin)

        record.wbc = Double(wbc)
        record.rbc = Double(rbc)
        record.hemoglobin = Double(hemoglobin)
        record.hematocrit = Double(hematocrit)
        record.platelets = Double(platelets)

        record.ecgNormal = ecgNormal
        record.ecgFindings = ecgNormal ? nil : ecgFindings

        record.smokingStatus = smokingStatus
        record.drinkingFrequency = drinkingFrequency
        record.exerciseFrequency = exerciseFrequency
        record.sleepHours = Double(sleepHours)

        record.clinicalNotes = clinicalNotes.isEmpty ? nil : clinicalNotes
        record.treatmentPlan = treatmentPlan.isEmpty ? nil : treatmentPlan

        if existingRecord == nil {
            record.patient = patient
            modelContext.insert(record)
        }

        dismiss()
    }
}
