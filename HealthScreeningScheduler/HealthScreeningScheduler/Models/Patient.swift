import Foundation

// MARK: - 性別
enum Gender: String, CaseIterable, Identifiable {
    case male = "男性"
    case female = "女性"

    var id: String { rawValue }
}

// MARK: - 飲酒習慣
enum DrinkingHabit: String, CaseIterable, Identifiable {
    case none = "飲まない"
    case occasionally = "時々飲む（週1-2回）"
    case regularly = "習慣的に飲む（週3回以上）"
    case daily = "毎日飲む"

    var id: String { rawValue }

    var riskScore: Double {
        switch self {
        case .none: return 0.0
        case .occasionally: return 0.5
        case .regularly: return 1.0
        case .daily: return 2.0
        }
    }

    // 1日あたりの平均アルコール摂取量（エタノール換算g）
    var estimatedDailyAlcohol: Double {
        switch self {
        case .none: return 0
        case .occasionally: return 10
        case .regularly: return 30
        case .daily: return 40
        }
    }
}

// MARK: - 喫煙習慣
enum SmokingHabit: String, CaseIterable, Identifiable {
    case never = "吸わない"
    case former = "過去に吸っていた"
    case current = "現在吸っている"

    var id: String { rawValue }

    var riskScore: Double {
        switch self {
        case .never: return 0.0
        case .former: return 1.0
        case .current: return 2.0
        }
    }
}

// MARK: - 既往歴
struct MedicalHistory: Identifiable {
    let id = UUID()
    var hasDiabetes: Bool = false           // 糖尿病
    var hasHypertension: Bool = false       // 高血圧
    var hasDyslipidemia: Bool = false       // 脂質異常症
    var hasHeartDisease: Bool = false       // 心疾患
    var hasStroke: Bool = false             // 脳卒中
    var hasCancer: Bool = false             // がん
    var hasLiverDisease: Bool = false       // 肝疾患
    var hasKidneyDisease: Bool = false      // 腎疾患
}

// MARK: - 家族歴
struct FamilyHistory: Identifiable {
    let id = UUID()
    var diabetesInFamily: Bool = false      // 糖尿病の家族歴
    var hypertensionInFamily: Bool = false  // 高血圧の家族歴
    var heartDiseaseInFamily: Bool = false  // 心疾患の家族歴
    var strokeInFamily: Bool = false        // 脳卒中の家族歴
    var cancerInFamily: Bool = false        // がんの家族歴
}

// MARK: - 患者情報
struct Patient: Identifiable {
    let id = UUID()
    var age: Int = 40
    var gender: Gender = .male
    var heightCm: Double = 170.0
    var weightKg: Double = 65.0
    var drinkingHabit: DrinkingHabit = .none
    var smokingHabit: SmokingHabit = .never
    var medicalHistory: MedicalHistory = MedicalHistory()
    var familyHistory: FamilyHistory = FamilyHistory()

    // BMI計算
    var bmi: Double {
        let heightM = heightCm / 100.0
        guard heightM > 0 else { return 0 }
        return weightKg / (heightM * heightM)
    }

    // BMI分類（日本肥満学会基準）
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "低体重"
        case 18.5..<25.0:
            return "普通体重"
        case 25.0..<30.0:
            return "肥満（1度）"
        case 30.0..<35.0:
            return "肥満（2度）"
        case 35.0..<40.0:
            return "肥満（3度）"
        default:
            return "肥満（4度）"
        }
    }

    // 腹囲の推定（BMIから概算）
    var estimatedWaistCircumference: Double {
        // 日本人の標準的な関係式から推定
        if gender == .male {
            return 50.0 + (bmi * 1.8)
        } else {
            return 45.0 + (bmi * 1.6)
        }
    }

    // メタボリックシンドローム腹囲基準（日本基準）
    var isWaistCircumferenceHigh: Bool {
        let waist = estimatedWaistCircumference
        if gender == .male {
            return waist >= 85.0
        } else {
            return waist >= 90.0
        }
    }
}
