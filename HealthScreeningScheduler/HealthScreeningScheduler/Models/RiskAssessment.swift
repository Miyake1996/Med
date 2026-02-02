import Foundation

// MARK: - リスクレベル
enum RiskLevel: String, CaseIterable, Comparable {
    case low = "低リスク"
    case moderate = "中リスク"
    case high = "高リスク"
    case veryHigh = "非常に高リスク"

    var colorName: String {
        switch self {
        case .low: return "green"
        case .moderate: return "yellow"
        case .high: return "orange"
        case .veryHigh: return "red"
        }
    }

    var description: String {
        switch self {
        case .low:
            return "現時点でのリスクは低いですが、定期的な検診を継続してください。"
        case .moderate:
            return "いくつかのリスク因子があります。生活習慣の改善を検討してください。"
        case .high:
            return "リスクが高い状態です。医療機関での精密検査をお勧めします。"
        case .veryHigh:
            return "リスクが非常に高い状態です。早急に医療機関を受診してください。"
        }
    }

    static func < (lhs: RiskLevel, rhs: RiskLevel) -> Bool {
        let order: [RiskLevel] = [.low, .moderate, .high, .veryHigh]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}

// MARK: - 疾患リスク
struct DiseaseRisk: Identifiable {
    let id = UUID()
    let diseaseName: String
    let riskLevel: RiskLevel
    let riskScore: Double          // 0.0 - 1.0
    let riskFactors: [String]      // リスク因子のリスト
    let recommendations: [String]  // 推奨事項

    var riskPercentage: Int {
        return Int(riskScore * 100)
    }
}

// MARK: - 総合リスク評価
struct RiskAssessment: Identifiable {
    let id = UUID()
    let evaluationDate: Date
    let patient: Patient

    // 各疾患のリスク
    var diabetesRisk: DiseaseRisk
    var hypertensionRisk: DiseaseRisk
    var dyslipidemiaRisk: DiseaseRisk
    var heartDiseaseRisk: DiseaseRisk
    var strokeRisk: DiseaseRisk
    var liverDiseaseRisk: DiseaseRisk
    var lungDiseaseRisk: DiseaseRisk
    var cancerRisks: [DiseaseRisk]  // がんリスク（複数）

    // 総合リスクレベル
    var overallRiskLevel: RiskLevel {
        let allRisks = [
            diabetesRisk.riskLevel,
            hypertensionRisk.riskLevel,
            dyslipidemiaRisk.riskLevel,
            heartDiseaseRisk.riskLevel,
            strokeRisk.riskLevel,
            liverDiseaseRisk.riskLevel,
            lungDiseaseRisk.riskLevel
        ] + cancerRisks.map { $0.riskLevel }

        if allRisks.contains(.veryHigh) {
            return .veryHigh
        } else if allRisks.contains(.high) {
            return .high
        } else if allRisks.contains(.moderate) {
            return .moderate
        } else {
            return .low
        }
    }

    // 全疾患リスクリスト
    var allDiseaseRisks: [DiseaseRisk] {
        var risks = [
            diabetesRisk,
            hypertensionRisk,
            dyslipidemiaRisk,
            heartDiseaseRisk,
            strokeRisk,
            liverDiseaseRisk,
            lungDiseaseRisk
        ]
        risks.append(contentsOf: cancerRisks)
        return risks.sorted { $0.riskScore > $1.riskScore }
    }

    // 高リスク疾患
    var highRiskDiseases: [DiseaseRisk] {
        return allDiseaseRisks.filter { $0.riskLevel >= .high }
    }

    // 主要な推奨事項
    var mainRecommendations: [String] {
        var recommendations: Set<String> = []

        for risk in allDiseaseRisks {
            for recommendation in risk.recommendations {
                recommendations.insert(recommendation)
            }
        }

        return Array(recommendations).sorted()
    }
}
