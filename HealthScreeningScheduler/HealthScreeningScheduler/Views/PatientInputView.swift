import SwiftUI

struct PatientInputView: View {
    @Binding var patient: Patient
    let onSubmit: () -> Void

    @State private var ageString: String = "40"
    @State private var heightString: String = "170.0"
    @State private var weightString: String = "65.0"
    @State private var showingMedicalHistory = false
    @State private var showingFamilyHistory = false

    var body: some View {
        Form {
            // MARK: - 基本情報
            Section(header: Text("基本情報")) {
                // 年齢
                HStack {
                    Text("年齢")
                    Spacer()
                    TextField("年齢", text: $ageString)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: ageString) { _, newValue in
                            if let age = Int(newValue) {
                                patient.age = age
                            }
                        }
                    Text("歳")
                }

                // 性別
                Picker("性別", selection: $patient.gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }

            // MARK: - 身体測定
            Section(header: Text("身体測定")) {
                // 身長
                HStack {
                    Text("身長")
                    Spacer()
                    TextField("身長", text: $heightString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: heightString) { _, newValue in
                            if let height = Double(newValue) {
                                patient.heightCm = height
                            }
                        }
                    Text("cm")
                }

                // 体重
                HStack {
                    Text("体重")
                    Spacer()
                    TextField("体重", text: $weightString)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .onChange(of: weightString) { _, newValue in
                            if let weight = Double(newValue) {
                                patient.weightKg = weight
                            }
                        }
                    Text("kg")
                }

                // BMI表示
                HStack {
                    Text("BMI")
                    Spacer()
                    Text(String(format: "%.1f", patient.bmi))
                        .foregroundColor(bmiColor)
                    Text("(\(patient.bmiCategory))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // 推定腹囲
                HStack {
                    Text("推定腹囲")
                    Spacer()
                    Text(String(format: "%.1f cm", patient.estimatedWaistCircumference))
                        .foregroundColor(patient.isWaistCircumferenceHigh ? .orange : .primary)
                    if patient.isWaistCircumferenceHigh {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
            }

            // MARK: - 生活習慣
            Section(header: Text("生活習慣")) {
                // 飲酒
                Picker("飲酒習慣", selection: $patient.drinkingHabit) {
                    ForEach(DrinkingHabit.allCases) { habit in
                        Text(habit.rawValue).tag(habit)
                    }
                }

                // 喫煙
                Picker("喫煙習慣", selection: $patient.smokingHabit) {
                    ForEach(SmokingHabit.allCases) { habit in
                        Text(habit.rawValue).tag(habit)
                    }
                }
            }

            // MARK: - 既往歴
            Section(header: Text("既往歴")) {
                Toggle("糖尿病", isOn: $patient.medicalHistory.hasDiabetes)
                Toggle("高血圧", isOn: $patient.medicalHistory.hasHypertension)
                Toggle("脂質異常症", isOn: $patient.medicalHistory.hasDyslipidemia)
                Toggle("心疾患", isOn: $patient.medicalHistory.hasHeartDisease)
                Toggle("脳卒中", isOn: $patient.medicalHistory.hasStroke)
                Toggle("がん", isOn: $patient.medicalHistory.hasCancer)
                Toggle("肝疾患", isOn: $patient.medicalHistory.hasLiverDisease)
                Toggle("腎疾患", isOn: $patient.medicalHistory.hasKidneyDisease)
            }

            // MARK: - 家族歴
            Section(header: Text("家族歴（血縁者の病歴）")) {
                Toggle("糖尿病", isOn: $patient.familyHistory.diabetesInFamily)
                Toggle("高血圧", isOn: $patient.familyHistory.hypertensionInFamily)
                Toggle("心疾患", isOn: $patient.familyHistory.heartDiseaseInFamily)
                Toggle("脳卒中", isOn: $patient.familyHistory.strokeInFamily)
                Toggle("がん", isOn: $patient.familyHistory.cancerInFamily)
            }

            // MARK: - 評価ボタン
            Section {
                Button(action: onSubmit) {
                    HStack {
                        Spacer()
                        Image(systemName: "chart.bar.doc.horizontal")
                        Text("リスク評価とスケジュール作成")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
                .listRowBackground(Color.clear)
            }
        }
        .onAppear {
            ageString = String(patient.age)
            heightString = String(format: "%.1f", patient.heightCm)
            weightString = String(format: "%.1f", patient.weightKg)
        }
    }

    private var bmiColor: Color {
        switch patient.bmi {
        case ..<18.5:
            return .blue
        case 18.5..<25.0:
            return .green
        case 25.0..<30.0:
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    NavigationStack {
        PatientInputView(patient: .constant(Patient()), onSubmit: {})
            .navigationTitle("患者情報入力")
    }
}
