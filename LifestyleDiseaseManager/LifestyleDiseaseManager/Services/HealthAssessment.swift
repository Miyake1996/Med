import Foundation
import SwiftUI

/// 健康評価サービス
class HealthAssessment: ObservableObject {

    /// 検査記録の総合評価を生成
    static func generateSummary(record: ExaminationRecord, patient: Patient) -> [AssessmentItem] {
        var items: [AssessmentItem] = []

        // BMI評価
        if let bmi = record.bmi {
            let eval = ReferenceDatabase.bmi.evaluate(bmi)
            items.append(AssessmentItem(
                category: "身体計測",
                name: "BMI",
                value: String(format: "%.1f", bmi),
                unit: "kg/m²",
                evaluation: eval,
                note: bmiCategory(bmi)
            ))
        }

        // 腹囲評価
        if let waist = record.waistCircumference {
            let ref = patient.gender == .male ? ReferenceDatabase.waistMale : ReferenceDatabase.waistFemale
            let eval = ref.evaluate(waist)
            items.append(AssessmentItem(
                category: "身体計測",
                name: "腹囲",
                value: String(format: "%.1f", waist),
                unit: "cm",
                evaluation: eval,
                note: nil
            ))
        }

        // 血圧評価
        if let sys = record.systolicBP, let dia = record.diastolicBP {
            let sysEval = ReferenceDatabase.systolicBP.evaluate(Double(sys))
            let diaEval = ReferenceDatabase.diastolicBP.evaluate(Double(dia))
            let eval = worse(sysEval, diaEval)
            items.append(AssessmentItem(
                category: "バイタルサイン",
                name: "血圧",
                value: "\(sys)/\(dia)",
                unit: "mmHg",
                evaluation: eval,
                note: ReferenceDatabase.bpClassification(systolic: sys, diastolic: dia)
            ))
        }

        // HbA1c評価
        if let hba1c = record.hba1c {
            let eval = ReferenceDatabase.hba1c.evaluate(hba1c)
            items.append(AssessmentItem(
                category: "血糖",
                name: "HbA1c",
                value: String(format: "%.1f", hba1c),
                unit: "%",
                evaluation: eval,
                note: ReferenceDatabase.diabetesControl(hba1c: hba1c)
            ))
        }

        // 空腹時血糖評価
        if let fg = record.fastingGlucose {
            let eval = ReferenceDatabase.fastingGlucose.evaluate(Double(fg))
            items.append(AssessmentItem(
                category: "血糖",
                name: "空腹時血糖",
                value: "\(fg)",
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // LDL-C評価
        if let ldl = record.ldlCholesterol {
            let eval = ReferenceDatabase.ldlCholesterol.evaluate(Double(ldl))
            items.append(AssessmentItem(
                category: "脂質",
                name: "LDL-C",
                value: "\(ldl)",
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // HDL-C評価
        if let hdl = record.hdlCholesterol {
            let eval = ReferenceDatabase.hdlCholesterol.evaluate(Double(hdl))
            items.append(AssessmentItem(
                category: "脂質",
                name: "HDL-C",
                value: "\(hdl)",
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // TG評価
        if let tg = record.triglycerides {
            let eval = ReferenceDatabase.triglycerides.evaluate(Double(tg))
            items.append(AssessmentItem(
                category: "脂質",
                name: "中性脂肪",
                value: "\(tg)",
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // Non-HDL-C評価
        if let nonHDL = record.calculatedNonHDL {
            let eval = ReferenceDatabase.nonHDLCholesterol.evaluate(Double(nonHDL))
            items.append(AssessmentItem(
                category: "脂質",
                name: "Non-HDL-C",
                value: "\(nonHDL)",
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // AST評価
        if let ast = record.ast {
            let eval = ReferenceDatabase.ast.evaluate(Double(ast))
            items.append(AssessmentItem(
                category: "肝機能",
                name: "AST",
                value: "\(ast)",
                unit: "U/L",
                evaluation: eval,
                note: nil
            ))
        }

        // ALT評価
        if let alt = record.alt {
            let eval = ReferenceDatabase.alt.evaluate(Double(alt))
            items.append(AssessmentItem(
                category: "肝機能",
                name: "ALT",
                value: "\(alt)",
                unit: "U/L",
                evaluation: eval,
                note: nil
            ))
        }

        // γ-GTP評価
        if let ggt = record.gammaGTP {
            let eval = ReferenceDatabase.gammaGTP.evaluate(Double(ggt))
            items.append(AssessmentItem(
                category: "肝機能",
                name: "γ-GTP",
                value: "\(ggt)",
                unit: "U/L",
                evaluation: eval,
                note: nil
            ))
        }

        // Cr評価
        if let cr = record.creatinine {
            let eval = ReferenceDatabase.creatinine.evaluate(cr)
            items.append(AssessmentItem(
                category: "腎機能",
                name: "Cr",
                value: String(format: "%.2f", cr),
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // eGFR評価
        if let egfr = record.calculatedEGFR(gender: patient.gender, age: patient.age) {
            let eval = ReferenceDatabase.eGFR.evaluate(egfr)
            items.append(AssessmentItem(
                category: "腎機能",
                name: "eGFR",
                value: String(format: "%.1f", egfr),
                unit: "mL/min/1.73m²",
                evaluation: eval,
                note: ReferenceDatabase.ckdStage(eGFR: egfr)
            ))
        }

        // 尿酸評価
        if let ua = record.uricAcid {
            let eval = ReferenceDatabase.uricAcid.evaluate(ua)
            items.append(AssessmentItem(
                category: "腎機能",
                name: "尿酸",
                value: String(format: "%.1f", ua),
                unit: "mg/dL",
                evaluation: eval,
                note: nil
            ))
        }

        // 尿検査
        if record.urineProtein != nil {
            let eval = ReferenceDatabase.evaluateUrineQualitative(record.urineProtein)
            items.append(AssessmentItem(
                category: "尿検査",
                name: "尿蛋白",
                value: record.urineProtein ?? "-",
                unit: "",
                evaluation: eval,
                note: nil
            ))
        }

        if record.urineGlucose != nil {
            let eval = ReferenceDatabase.evaluateUrineQualitative(record.urineGlucose)
            items.append(AssessmentItem(
                category: "尿検査",
                name: "尿糖",
                value: record.urineGlucose ?? "-",
                unit: "",
                evaluation: eval,
                note: nil
            ))
        }

        // Hb評価
        if let hb = record.hemoglobin {
            let eval = ReferenceDatabase.hemoglobin.evaluate(hb)
            items.append(AssessmentItem(
                category: "血算",
                name: "Hb",
                value: String(format: "%.1f", hb),
                unit: "g/dL",
                evaluation: eval,
                note: nil
            ))
        }

        return items
    }

    /// 前回との比較
    static func compareToPrevious(current: ExaminationRecord, previous: ExaminationRecord) -> [ComparisonItem] {
        var comparisons: [ComparisonItem] = []

        if let cw = current.weight, let pw = previous.weight {
            comparisons.append(ComparisonItem(name: "体重", current: cw, previous: pw, unit: "kg", format: "%.1f"))
        }
        if let cs = current.systolicBP, let ps = previous.systolicBP {
            comparisons.append(ComparisonItem(name: "収縮期血圧", current: Double(cs), previous: Double(ps), unit: "mmHg", format: "%.0f"))
        }
        if let ch = current.hba1c, let ph = previous.hba1c {
            comparisons.append(ComparisonItem(name: "HbA1c", current: ch, previous: ph, unit: "%", format: "%.1f"))
        }
        if let cl = current.ldlCholesterol, let pl = previous.ldlCholesterol {
            comparisons.append(ComparisonItem(name: "LDL-C", current: Double(cl), previous: Double(pl), unit: "mg/dL", format: "%.0f"))
        }
        if let ct = current.triglycerides, let pt = previous.triglycerides {
            comparisons.append(ComparisonItem(name: "TG", current: Double(ct), previous: Double(pt), unit: "mg/dL", format: "%.0f"))
        }
        if let ce = current.eGFR, let pe = previous.eGFR {
            comparisons.append(ComparisonItem(name: "eGFR", current: ce, previous: pe, unit: "mL/min", format: "%.1f"))
        }

        return comparisons
    }

    // MARK: - ヘルパー

    private static func bmiCategory(_ bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "低体重"
        case 18.5..<25.0: return "普通体重"
        case 25.0..<30.0: return "肥満(1度)"
        case 30.0..<35.0: return "肥満(2度)"
        case 35.0..<40.0: return "肥満(3度)"
        default: return "肥満(4度)"
        }
    }

    private static func worse(_ a: Evaluation, _ b: Evaluation) -> Evaluation {
        let order: [Evaluation] = [.normal, .caution, .abnormal]
        let aIndex = order.firstIndex(of: a) ?? 0
        let bIndex = order.firstIndex(of: b) ?? 0
        return order[max(aIndex, bIndex)]
    }
}

/// 評価項目
struct AssessmentItem: Identifiable {
    let id = UUID()
    let category: String
    let name: String
    let value: String
    let unit: String
    let evaluation: Evaluation
    let note: String?
}

/// 前回比較項目
struct ComparisonItem: Identifiable {
    let id = UUID()
    let name: String
    let current: Double
    let previous: Double
    let unit: String
    let format: String

    var difference: Double { current - previous }

    var trend: String {
        if abs(difference) < 0.01 { return "→" }
        return difference > 0 ? "↑" : "↓"
    }

    var formattedDifference: String {
        let sign = difference > 0 ? "+" : ""
        return "\(sign)\(String(format: format, difference))"
    }
}
