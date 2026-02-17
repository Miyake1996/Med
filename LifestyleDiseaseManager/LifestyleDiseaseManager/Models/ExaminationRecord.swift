import Foundation
import SwiftData

/// 検査記録モデル - 生活習慣病管理料に基づく検査項目
@Model
final class ExaminationRecord {
    var id: UUID
    var recordDate: Date
    var patient: Patient?

    // MARK: - 身体計測
    var height: Double?          // 身長 (cm)
    var weight: Double?          // 体重 (kg)
    var waistCircumference: Double?  // 腹囲 (cm)

    // MARK: - バイタルサイン
    var systolicBP: Int?         // 収縮期血圧 (mmHg)
    var diastolicBP: Int?        // 拡張期血圧 (mmHg)
    var heartRate: Int?          // 脈拍 (/min)

    // MARK: - 血糖関連
    var fastingGlucose: Int?     // 空腹時血糖 (mg/dL)
    var hba1c: Double?           // HbA1c (%)
    var casualGlucose: Int?      // 随時血糖 (mg/dL)
    var glycoalbumin: Double?    // グリコアルブミン (%)

    // MARK: - 脂質
    var totalCholesterol: Int?   // 総コレステロール (mg/dL)
    var ldlCholesterol: Int?     // LDL-C (mg/dL)
    var hdlCholesterol: Int?     // HDL-C (mg/dL)
    var triglycerides: Int?      // 中性脂肪 (mg/dL)
    var nonHDLCholesterol: Int?  // Non-HDL-C (mg/dL)

    // MARK: - 肝機能
    var ast: Int?                // AST (U/L)
    var alt: Int?                // ALT (U/L)
    var gammaGTP: Int?           // γ-GTP (U/L)

    // MARK: - 腎機能
    var bun: Double?             // BUN (mg/dL)
    var creatinine: Double?      // Cr (mg/dL)
    var eGFR: Double?            // eGFR (mL/min/1.73m²)
    var uricAcid: Double?        // 尿酸 (mg/dL)

    // MARK: - 尿検査
    var urineProtein: String?    // 尿蛋白 (-, ±, +, 2+, 3+)
    var urineGlucose: String?    // 尿糖 (-, ±, +, 2+, 3+)
    var urineOccultBlood: String? // 尿潜血 (-, ±, +, 2+, 3+)
    var urineAlbumin: Double?    // 尿アルブミン (mg/gCr)

    // MARK: - 血算
    var wbc: Double?             // 白血球 (×10³/μL)
    var rbc: Double?             // 赤血球 (×10⁴/μL)
    var hemoglobin: Double?      // ヘモグロビン (g/dL)
    var hematocrit: Double?      // ヘマトクリット (%)
    var platelets: Double?       // 血小板 (×10⁴/μL)

    // MARK: - 心電図
    var ecgFindings: String?     // 心電図所見
    var ecgNormal: Bool?         // 心電図正常

    // MARK: - 生活習慣
    var smokingStatus: SmokingStatus?
    var drinkingFrequency: DrinkingFrequency?
    var exerciseFrequency: ExerciseFrequency?
    var sleepHours: Double?      // 睡眠時間 (時間)

    // MARK: - メモ・所見
    var clinicalNotes: String?   // 診察所見・メモ
    var treatmentPlan: String?   // 治療方針

    init(patient: Patient? = nil, recordDate: Date = Date()) {
        self.id = UUID()
        self.recordDate = recordDate
        self.patient = patient
    }

    /// BMIを計算
    var bmi: Double? {
        guard let h = height, let w = weight, h > 0 else { return nil }
        let heightM = h / 100.0
        return w / (heightM * heightM)
    }

    /// Non-HDL-Cを計算（入力がない場合）
    var calculatedNonHDL: Int? {
        if let nonHDL = nonHDLCholesterol { return nonHDL }
        guard let tc = totalCholesterol, let hdl = hdlCholesterol else { return nil }
        return tc - hdl
    }

    /// eGFRを計算（入力がない場合、日本人向けGFR推算式）
    func calculatedEGFR(gender: Gender, age: Int) -> Double? {
        if let egfr = eGFR { return egfr }
        guard let cr = creatinine, cr > 0 else { return nil }
        // 日本腎臓学会のeGFR推算式
        let base = 194.0 * pow(cr, -1.094) * pow(Double(age), -0.287)
        return gender == .female ? base * 0.739 : base
    }
}

// MARK: - 生活習慣の列挙型

enum SmokingStatus: String, Codable, CaseIterable {
    case never = "非喫煙"
    case former = "禁煙中"
    case current = "喫煙中"
}

enum DrinkingFrequency: String, Codable, CaseIterable {
    case none = "飲酒なし"
    case occasional = "機会飲酒"
    case moderate = "適量飲酒"
    case heavy = "多量飲酒"
}

enum ExerciseFrequency: String, Codable, CaseIterable {
    case none = "運動習慣なし"
    case light = "週1-2回"
    case moderate = "週3-4回"
    case active = "週5回以上"
}
