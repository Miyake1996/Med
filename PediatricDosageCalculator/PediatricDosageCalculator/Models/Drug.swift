import Foundation

/// 投与頻度
enum DosageFrequency: String, CaseIterable, Identifiable {
    case perDose = "1回量"
    case perDay = "1日量"
    case divided2 = "1日2回分割"
    case divided3 = "1日3回分割"
    case divided4 = "1日4回分割"

    var id: String { rawValue }

    var divisor: Double {
        switch self {
        case .perDose: return 1
        case .perDay: return 1
        case .divided2: return 2
        case .divided3: return 3
        case .divided4: return 4
        }
    }
}

/// 薬剤カテゴリ
enum DrugCategory: String, CaseIterable, Identifiable {
    case antipyretic = "解熱鎮痛薬"
    case antibiotic = "抗菌薬"
    case antiviral = "抗ウイルス薬"
    case antiemetic = "制吐薬"
    case bronchodilator = "気管支拡張薬"
    case antiallergic = "抗アレルギー薬"
    case steroid = "ステロイド"
    case antitussive = "鎮咳薬"
    case expectorant = "去痰薬"
    case antidiarrheal = "整腸・止瀉薬"

    var id: String { rawValue }
}

/// 剤形
enum DosageForm: String, CaseIterable {
    case syrup = "シロップ"
    case powder = "散剤・ドライシロップ"
    case tablet = "錠剤"
    case suppository = "坐薬"
    case tape = "貼付剤"
    case granule = "顆粒"
}

/// 年齢制限
struct AgeRestriction {
    let minimumMonths: Int?
    let maximumMonths: Int?

    static let none = AgeRestriction(minimumMonths: nil, maximumMonths: nil)
    static func minimum(months: Int) -> AgeRestriction {
        AgeRestriction(minimumMonths: months, maximumMonths: nil)
    }
    static func range(minMonths: Int, maxMonths: Int) -> AgeRestriction {
        AgeRestriction(minimumMonths: minMonths, maximumMonths: maxMonths)
    }
}

/// 投与量計算方法
enum DosageCalculationType {
    case perKg(mgPerKg: Double, frequency: DosageFrequency)
    case perKgRange(minMgPerKg: Double, maxMgPerKg: Double, frequency: DosageFrequency)
    case byWeight(thresholds: [(maxWeight: Double, dose: Double)])
    case byAge(thresholds: [(maxMonths: Int, dose: Double)])
    case fixed(dose: Double)
}

/// 薬剤モデル
struct Drug: Identifiable {
    let id = UUID()
    let genericName: String           // 一般名
    let brandName: String             // 商品名
    let category: DrugCategory        // カテゴリ
    let dosageForm: DosageForm        // 剤形
    let concentration: Double?        // 濃度 (mg/mL or mg/g)
    let concentrationUnit: String     // 濃度単位
    let calculationType: DosageCalculationType
    let maxDosePerDay: Double?        // 1日最大投与量 (mg)
    let maxDosePerDose: Double?       // 1回最大投与量 (mg)
    let ageRestriction: AgeRestriction
    let notes: String?                // 備考

    var displayName: String {
        "\(genericName)（\(brandName)）"
    }
}

/// 計算結果
struct DosageResult: Identifiable {
    let id = UUID()
    let drug: Drug
    let dosePerDose: Double           // 1回量 (mg)
    let dosePerDay: Double            // 1日量 (mg)
    let volumePerDose: Double?        // 1回量 (mL or g)
    let volumePerDay: Double?         // 1日量 (mL or g)
    let frequency: DosageFrequency
    let warnings: [String]
    let isWithinSafeRange: Bool
}
