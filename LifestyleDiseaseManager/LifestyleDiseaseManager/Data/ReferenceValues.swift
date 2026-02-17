import Foundation

/// 検査基準値データベース
struct ReferenceRange {
    let name: String
    let unit: String
    let normalMin: Double?
    let normalMax: Double?
    let cautionMin: Double?
    let cautionMax: Double?
    let description: String

    /// 値の判定
    func evaluate(_ value: Double) -> Evaluation {
        if let min = normalMin, let max = normalMax {
            if value >= min && value <= max { return .normal }
        } else if let max = normalMax {
            if value <= max { return .normal }
        } else if let min = normalMin {
            if value >= min { return .normal }
        }

        if let cMin = cautionMin, value < cMin { return .abnormal }
        if let cMax = cautionMax, value > cMax { return .abnormal }

        return .caution
    }
}

enum Evaluation: String {
    case normal = "正常"
    case caution = "要注意"
    case abnormal = "異常"

    var color: String {
        switch self {
        case .normal: return "green"
        case .caution: return "orange"
        case .abnormal: return "red"
        }
    }

    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .abnormal: return "xmark.circle.fill"
        }
    }
}

/// 基準値データベース
struct ReferenceDatabase {

    // MARK: - バイタルサイン
    static let systolicBP = ReferenceRange(
        name: "収縮期血圧", unit: "mmHg",
        normalMin: nil, normalMax: 130,
        cautionMin: nil, cautionMax: 180,
        description: "130未満が目標（高血圧治療ガイドライン2019）"
    )

    static let diastolicBP = ReferenceRange(
        name: "拡張期血圧", unit: "mmHg",
        normalMin: nil, normalMax: 80,
        cautionMin: nil, cautionMax: 110,
        description: "80未満が目標"
    )

    // MARK: - BMI
    static let bmi = ReferenceRange(
        name: "BMI", unit: "kg/m²",
        normalMin: 18.5, normalMax: 25.0,
        cautionMin: 16.0, cautionMax: 30.0,
        description: "18.5〜25.0が適正範囲"
    )

    static let waistMale = ReferenceRange(
        name: "腹囲（男性）", unit: "cm",
        normalMin: nil, normalMax: 85.0,
        cautionMin: nil, cautionMax: 100.0,
        description: "男性85cm未満が基準"
    )

    static let waistFemale = ReferenceRange(
        name: "腹囲（女性）", unit: "cm",
        normalMin: nil, normalMax: 90.0,
        cautionMin: nil, cautionMax: 105.0,
        description: "女性90cm未満が基準"
    )

    // MARK: - 血糖関連
    static let fastingGlucose = ReferenceRange(
        name: "空腹時血糖", unit: "mg/dL",
        normalMin: 70, normalMax: 110,
        cautionMin: 50, cautionMax: 200,
        description: "110未満が正常、126以上で糖尿病型"
    )

    static let hba1c = ReferenceRange(
        name: "HbA1c", unit: "%",
        normalMin: 4.6, normalMax: 6.2,
        cautionMin: nil, cautionMax: 10.0,
        description: "6.5%以上で糖尿病型、治療目標は7.0%未満"
    )

    static let casualGlucose = ReferenceRange(
        name: "随時血糖", unit: "mg/dL",
        normalMin: 70, normalMax: 140,
        cautionMin: 50, cautionMax: 300,
        description: "200以上で糖尿病型"
    )

    // MARK: - 脂質
    static let ldlCholesterol = ReferenceRange(
        name: "LDL-C", unit: "mg/dL",
        normalMin: nil, normalMax: 140,
        cautionMin: nil, cautionMax: 180,
        description: "140未満が基準値、リスクに応じて目標値は異なる"
    )

    static let hdlCholesterol = ReferenceRange(
        name: "HDL-C", unit: "mg/dL",
        normalMin: 40, normalMax: nil,
        cautionMin: 30, cautionMax: nil,
        description: "40以上が基準値"
    )

    static let triglycerides = ReferenceRange(
        name: "中性脂肪", unit: "mg/dL",
        normalMin: nil, normalMax: 150,
        cautionMin: nil, cautionMax: 500,
        description: "150未満が基準値（空腹時）"
    )

    static let totalCholesterol = ReferenceRange(
        name: "総コレステロール", unit: "mg/dL",
        normalMin: nil, normalMax: 220,
        cautionMin: nil, cautionMax: 280,
        description: "220未満が基準値"
    )

    static let nonHDLCholesterol = ReferenceRange(
        name: "Non-HDL-C", unit: "mg/dL",
        normalMin: nil, normalMax: 170,
        cautionMin: nil, cautionMax: 210,
        description: "170未満が基準値"
    )

    // MARK: - 肝機能
    static let ast = ReferenceRange(
        name: "AST", unit: "U/L",
        normalMin: 10, normalMax: 35,
        cautionMin: nil, cautionMax: 100,
        description: "基準値 10〜35"
    )

    static let alt = ReferenceRange(
        name: "ALT", unit: "U/L",
        normalMin: 5, normalMax: 35,
        cautionMin: nil, cautionMax: 100,
        description: "基準値 5〜35"
    )

    static let gammaGTP = ReferenceRange(
        name: "γ-GTP", unit: "U/L",
        normalMin: nil, normalMax: 50,
        cautionMin: nil, cautionMax: 100,
        description: "基準値 50以下"
    )

    // MARK: - 腎機能
    static let bun = ReferenceRange(
        name: "BUN", unit: "mg/dL",
        normalMin: 8, normalMax: 20,
        cautionMin: nil, cautionMax: 40,
        description: "基準値 8〜20"
    )

    static let creatinine = ReferenceRange(
        name: "Cr", unit: "mg/dL",
        normalMin: nil, normalMax: 1.1,
        cautionMin: nil, cautionMax: 2.0,
        description: "基準値 男性1.1以下、女性0.8以下"
    )

    static let eGFR = ReferenceRange(
        name: "eGFR", unit: "mL/min/1.73m²",
        normalMin: 60, normalMax: nil,
        cautionMin: 30, cautionMax: nil,
        description: "60以上が正常、CKDステージ分類に対応"
    )

    static let uricAcid = ReferenceRange(
        name: "尿酸", unit: "mg/dL",
        normalMin: 2.0, normalMax: 7.0,
        cautionMin: nil, cautionMax: 9.0,
        description: "基準値 2.0〜7.0"
    )

    // MARK: - 血算
    static let wbc = ReferenceRange(
        name: "WBC", unit: "×10³/μL",
        normalMin: 3.5, normalMax: 9.0,
        cautionMin: 2.0, cautionMax: 15.0,
        description: "基準値 3500〜9000"
    )

    static let hemoglobin = ReferenceRange(
        name: "Hb", unit: "g/dL",
        normalMin: 12.0, normalMax: 17.0,
        cautionMin: 8.0, cautionMax: 20.0,
        description: "基準値 男性13.5〜17.0、女性12.0〜15.0"
    )

    static let platelets = ReferenceRange(
        name: "Plt", unit: "×10⁴/μL",
        normalMin: 15.0, normalMax: 35.0,
        cautionMin: 10.0, cautionMax: 50.0,
        description: "基準値 15〜35万"
    )

    // MARK: - 尿検査判定ヘルパー
    static func evaluateUrineQualitative(_ value: String?) -> Evaluation {
        guard let v = value else { return .normal }
        switch v {
        case "-": return .normal
        case "±": return .caution
        default: return .abnormal  // +, 2+, 3+
        }
    }

    // MARK: - CKDステージ判定
    static func ckdStage(eGFR: Double) -> String {
        switch eGFR {
        case 90...: return "G1（正常または高値）"
        case 60..<90: return "G2（正常または軽度低下）"
        case 45..<60: return "G3a（軽度〜中等度低下）"
        case 30..<45: return "G3b（中等度〜高度低下）"
        case 15..<30: return "G4（高度低下）"
        default: return "G5（末期腎不全）"
        }
    }

    // MARK: - 糖尿病治療目標
    static func diabetesControl(hba1c: Double) -> String {
        switch hba1c {
        case ..<6.0: return "正常域"
        case 6.0..<7.0: return "合併症予防の目標値内"
        case 7.0..<8.0: return "治療強化が必要"
        default: return "コントロール不良"
        }
    }

    // MARK: - 高血圧分類
    static func bpClassification(systolic: Int, diastolic: Int) -> String {
        if systolic < 120 && diastolic < 80 { return "正常血圧" }
        if systolic < 130 && diastolic < 80 { return "正常高値血圧" }
        if systolic < 140 && diastolic < 90 { return "高値血圧" }
        if systolic < 160 && diastolic < 100 { return "Ⅰ度高血圧" }
        if systolic < 180 && diastolic < 110 { return "Ⅱ度高血圧" }
        return "Ⅲ度高血圧"
    }
}
