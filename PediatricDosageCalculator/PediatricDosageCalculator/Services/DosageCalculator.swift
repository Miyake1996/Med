import Foundation

/// 投与量計算サービス
class DosageCalculator: ObservableObject {
    @Published var selectedCategory: DrugCategory = .antipyretic
    @Published var selectedDrug: Drug?
    @Published var ageYears: Int = 0
    @Published var ageMonths: Int = 0
    @Published var weight: Double = 0
    @Published var result: DosageResult?
    @Published var errorMessage: String?

    /// 総月齢を計算
    var totalMonths: Int {
        ageYears * 12 + ageMonths
    }

    /// 現在選択されているカテゴリの薬剤リスト
    var availableDrugs: [Drug] {
        DrugDatabase.drugs(for: selectedCategory)
    }

    /// 投与量を計算
    func calculate() {
        guard let drug = selectedDrug else {
            errorMessage = "薬剤を選択してください"
            result = nil
            return
        }

        guard weight > 0 else {
            errorMessage = "体重を入力してください"
            result = nil
            return
        }

        // 年齢制限チェック
        if let minMonths = drug.ageRestriction.minimumMonths, totalMonths < minMonths {
            let minAge = formatAge(months: minMonths)
            errorMessage = "この薬剤は\(minAge)未満には使用できません"
            result = nil
            return
        }

        if let maxMonths = drug.ageRestriction.maximumMonths, totalMonths > maxMonths {
            let maxAge = formatAge(months: maxMonths)
            errorMessage = "この薬剤は\(maxAge)以上には使用できません"
            result = nil
            return
        }

        errorMessage = nil
        result = calculateDosage(drug: drug, weight: weight, ageMonths: totalMonths)
    }

    /// 投与量計算のメインロジック
    private func calculateDosage(drug: Drug, weight: Double, ageMonths: Int) -> DosageResult {
        var warnings: [String] = []
        var dosePerDay: Double = 0
        var dosePerDose: Double = 0
        var frequency: DosageFrequency = .perDay

        switch drug.calculationType {
        case .perKg(let mgPerKg, let freq):
            frequency = freq
            if freq == .perDose {
                dosePerDose = mgPerKg * weight
                dosePerDay = dosePerDose * 3  // 仮に1日3回
            } else {
                dosePerDay = mgPerKg * weight
                dosePerDose = dosePerDay / 3  // 仮に1日3回
            }

        case .perKgRange(let minMgPerKg, let maxMgPerKg, let freq):
            frequency = freq
            let averageMgPerKg = (minMgPerKg + maxMgPerKg) / 2
            if freq == .perDose {
                dosePerDose = averageMgPerKg * weight
                dosePerDay = dosePerDose * 3
                warnings.append("推奨量: \(formatNumber(minMgPerKg * weight))〜\(formatNumber(maxMgPerKg * weight)) mg/回")
            } else {
                dosePerDay = averageMgPerKg * weight
                dosePerDose = dosePerDay / 3
                warnings.append("推奨量: \(formatNumber(minMgPerKg * weight))〜\(formatNumber(maxMgPerKg * weight)) mg/日")
            }

        case .byWeight(let thresholds):
            frequency = .perDose
            for threshold in thresholds {
                if weight <= threshold.maxWeight {
                    dosePerDose = threshold.dose
                    break
                }
            }
            if dosePerDose == 0 {
                dosePerDose = thresholds.last?.dose ?? 0
            }
            dosePerDay = dosePerDose

        case .byAge(let thresholds):
            frequency = .perDay
            for threshold in thresholds {
                if ageMonths < threshold.maxMonths {
                    dosePerDose = threshold.dose
                    break
                }
            }
            if dosePerDose == 0 {
                dosePerDose = thresholds.last?.dose ?? 0
            }
            dosePerDay = dosePerDose

        case .fixed(let dose):
            frequency = .perDose
            dosePerDose = dose
            dosePerDay = dose
        }

        // 最大投与量チェック
        var isWithinSafeRange = true

        if let maxPerDay = drug.maxDosePerDay {
            if case .perKgRange = drug.calculationType {
                // mg/kg/日の場合、体重で掛けた値と比較
                if dosePerDay > maxPerDay * weight {
                    warnings.append("⚠️ 1日最大量(\(formatNumber(maxPerDay * weight))mg)を超えています")
                    isWithinSafeRange = false
                }
            } else {
                if dosePerDay > maxPerDay {
                    warnings.append("⚠️ 1日最大量(\(formatNumber(maxPerDay))mg)を超えています")
                    isWithinSafeRange = false
                }
            }
        }

        if let maxPerDose = drug.maxDosePerDose {
            if dosePerDose > maxPerDose {
                warnings.append("⚠️ 1回最大量(\(formatNumber(maxPerDose))mg)を超えています")
                dosePerDose = maxPerDose
                isWithinSafeRange = false
            }
        }

        // 製剤量（mL or g）の計算
        var volumePerDose: Double? = nil
        var volumePerDay: Double? = nil

        if let concentration = drug.concentration, concentration > 0 {
            volumePerDose = dosePerDose / concentration
            volumePerDay = dosePerDay / concentration
        }

        // 備考を警告に追加
        if let notes = drug.notes {
            warnings.append("💡 \(notes)")
        }

        return DosageResult(
            drug: drug,
            dosePerDose: dosePerDose,
            dosePerDay: dosePerDay,
            volumePerDose: volumePerDose,
            volumePerDay: volumePerDay,
            frequency: frequency,
            warnings: warnings,
            isWithinSafeRange: isWithinSafeRange
        )
    }

    /// 月齢を年齢表記に変換
    private func formatAge(months: Int) -> String {
        if months < 12 {
            return "\(months)ヶ月"
        } else if months % 12 == 0 {
            return "\(months / 12)歳"
        } else {
            return "\(months / 12)歳\(months % 12)ヶ月"
        }
    }

    /// 数値フォーマット
    private func formatNumber(_ value: Double) -> String {
        if value >= 100 {
            return String(format: "%.0f", value)
        } else if value >= 10 {
            return String(format: "%.1f", value)
        } else if value >= 1 {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.3f", value)
        }
    }

    /// 入力をリセット
    func reset() {
        ageYears = 0
        ageMonths = 0
        weight = 0
        selectedDrug = nil
        result = nil
        errorMessage = nil
    }
}
