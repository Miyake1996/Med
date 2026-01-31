import SwiftUI

struct ContentView: View {
    @StateObject private var calculator = DosageCalculator()
    @State private var showingResult = false

    var body: some View {
        NavigationView {
            Form {
                // 患者情報セクション
                Section {
                    PatientInfoSection(calculator: calculator)
                } header: {
                    Label("患者情報", systemImage: "person.fill")
                }

                // 薬剤選択セクション
                Section {
                    DrugSelectionSection(calculator: calculator)
                } header: {
                    Label("薬剤選択", systemImage: "pills.fill")
                }

                // 計算ボタン
                Section {
                    Button(action: {
                        calculator.calculate()
                        if calculator.result != nil {
                            showingResult = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Label("投与量を計算", systemImage: "function")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .disabled(calculator.selectedDrug == nil || calculator.weight <= 0)

                    if let error = calculator.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.callout)
                    }
                }

                // 結果表示セクション
                if let result = calculator.result {
                    Section {
                        ResultView(result: result)
                    } header: {
                        Label("計算結果", systemImage: "checkmark.circle.fill")
                    }
                }
            }
            .navigationTitle("小児薬用量計算")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        calculator.reset()
                    }) {
                        Label("リセット", systemImage: "arrow.counterclockwise")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - 患者情報入力セクション
struct PatientInfoSection: View {
    @ObservedObject var calculator: DosageCalculator

    var body: some View {
        // 年齢入力
        HStack {
            Text("年齢")
            Spacer()
            Picker("年", selection: $calculator.ageYears) {
                ForEach(0..<16, id: \.self) { year in
                    Text("\(year)歳").tag(year)
                }
            }
            .pickerStyle(.menu)

            Picker("月", selection: $calculator.ageMonths) {
                ForEach(0..<12, id: \.self) { month in
                    Text("\(month)ヶ月").tag(month)
                }
            }
            .pickerStyle(.menu)
        }

        // 体重入力
        HStack {
            Text("体重")
            Spacer()
            TextField("kg", value: $calculator.weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text("kg")
                .foregroundColor(.secondary)
        }

        // 標準体重の参考表示
        if calculator.totalMonths > 0 {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("参考: \(referenceWeight(months: calculator.totalMonths))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    /// 月齢に応じた参考体重
    private func referenceWeight(months: Int) -> String {
        // 日本人小児の標準体重（概算）
        let weight: Double
        switch months {
        case 0..<1: weight = 3.0
        case 1..<2: weight = 4.0
        case 2..<3: weight = 5.0
        case 3..<4: weight = 6.0
        case 4..<5: weight = 6.5
        case 5..<6: weight = 7.0
        case 6..<9: weight = 7.5
        case 9..<12: weight = 8.5
        case 12..<18: weight = 9.5
        case 18..<24: weight = 11.0
        case 24..<36: weight = 12.5
        case 36..<48: weight = 14.5
        case 48..<60: weight = 16.5
        case 60..<72: weight = 18.5
        case 72..<84: weight = 21.0
        case 84..<96: weight = 24.0
        case 96..<108: weight = 27.0
        case 108..<120: weight = 30.0
        case 120..<132: weight = 34.0
        case 132..<144: weight = 38.0
        case 144..<156: weight = 43.0
        case 156..<168: weight = 48.0
        default: weight = 55.0
        }
        return String(format: "標準体重 約%.1fkg", weight)
    }
}

// MARK: - 薬剤選択セクション
struct DrugSelectionSection: View {
    @ObservedObject var calculator: DosageCalculator

    var body: some View {
        // カテゴリ選択
        Picker("カテゴリ", selection: $calculator.selectedCategory) {
            ForEach(DrugCategory.allCases) { category in
                Text(category.rawValue).tag(category)
            }
        }
        .onChange(of: calculator.selectedCategory) { _ in
            calculator.selectedDrug = nil
            calculator.result = nil
        }

        // 薬剤選択
        Picker("薬剤", selection: $calculator.selectedDrug) {
            Text("選択してください").tag(nil as Drug?)
            ForEach(calculator.availableDrugs) { drug in
                VStack(alignment: .leading) {
                    Text(drug.displayName)
                    Text(drug.dosageForm.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .tag(drug as Drug?)
            }
        }
        .onChange(of: calculator.selectedDrug) { _ in
            calculator.result = nil
        }

        // 選択された薬剤の情報
        if let drug = calculator.selectedDrug {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label(drug.dosageForm.rawValue, systemImage: "capsule.fill")
                        .font(.caption)
                        .foregroundColor(.blue)

                    if let conc = drug.concentration {
                        Text("・\(formatConcentration(conc, unit: drug.concentrationUnit))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                if let notes = drug.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func formatConcentration(_ value: Double, unit: String) -> String {
        if value >= 1 {
            return String(format: "%.0f%@", value, unit)
        } else {
            return String(format: "%.3f%@", value, unit)
        }
    }
}

// MARK: - 結果表示ビュー
struct ResultView: View {
    let result: DosageResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 薬剤名
            Text(result.drug.displayName)
                .font(.headline)
                .foregroundColor(.primary)

            Divider()

            // 投与量（mg）
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("1回量:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(formatNumber(result.dosePerDose)) mg")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }

                HStack {
                    Text("1日量:")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(formatNumber(result.dosePerDay)) mg")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            // 製剤量（mL/g）
            if let volumePerDose = result.volumePerDose,
               let volumePerDay = result.volumePerDay,
               let concentration = result.drug.concentration {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("製剤量（\(result.drug.concentrationUnit)換算）")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Text("1回量:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(formatNumber(volumePerDose)) \(volumeUnit(for: result.drug))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("1日量:")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(formatNumber(volumePerDay)) \(volumeUnit(for: result.drug))")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }

            // 警告・注意事項
            if !result.warnings.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(result.warnings, id: \.self) { warning in
                        Text(warning)
                            .font(.callout)
                            .foregroundColor(warning.contains("⚠️") ? .red : .secondary)
                    }
                }
            }

            // 安全範囲外の警告
            if !result.isWithinSafeRange {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("投与量が推奨範囲を超えています。医師に確認してください。")
                        .font(.callout)
                        .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }

    private func formatNumber(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "%.1f", value)
        } else if value >= 10 {
            return String(format: "%.2f", value)
        } else if value >= 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.3f", value)
        }
    }

    private func volumeUnit(for drug: Drug) -> String {
        if drug.concentrationUnit.contains("mL") {
            return "mL"
        } else if drug.concentrationUnit.contains("g") {
            return "g"
        } else {
            return "単位"
        }
    }
}

#Preview {
    ContentView()
}
