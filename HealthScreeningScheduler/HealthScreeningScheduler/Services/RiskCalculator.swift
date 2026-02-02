import Foundation

// MARK: - リスク計算サービス
// 日本人の疫学データに基づいたリスク評価を行います
class RiskCalculator {

    // MARK: - 総合リスク評価
    func calculateRiskAssessment(for patient: Patient) -> RiskAssessment {
        return RiskAssessment(
            evaluationDate: Date(),
            patient: patient,
            diabetesRisk: calculateDiabetesRisk(for: patient),
            hypertensionRisk: calculateHypertensionRisk(for: patient),
            dyslipidemiaRisk: calculateDyslipidemiaRisk(for: patient),
            heartDiseaseRisk: calculateHeartDiseaseRisk(for: patient),
            strokeRisk: calculateStrokeRisk(for: patient),
            liverDiseaseRisk: calculateLiverDiseaseRisk(for: patient),
            lungDiseaseRisk: calculateLungDiseaseRisk(for: patient),
            cancerRisks: calculateCancerRisks(for: patient)
        )
    }

    // MARK: - 糖尿病リスク評価
    // 日本人の糖尿病リスク評価（JDST等を参考）
    private func calculateDiabetesRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢リスク（40歳以上でリスク上昇）
        if patient.age >= 40 && patient.age < 50 {
            score += 0.1
            factors.append("40歳以上")
        } else if patient.age >= 50 && patient.age < 60 {
            score += 0.15
            factors.append("50歳以上")
        } else if patient.age >= 60 {
            score += 0.2
            factors.append("60歳以上")
        }

        // BMIリスク（日本人は25以上で糖尿病リスク上昇）
        if patient.bmi >= 25 && patient.bmi < 30 {
            score += 0.2
            factors.append("BMI 25以上（肥満）")
            recommendations.append("適正体重の維持を目指してください")
        } else if patient.bmi >= 30 {
            score += 0.35
            factors.append("BMI 30以上（高度肥満）")
            recommendations.append("減量プログラムへの参加を検討してください")
        }

        // 腹囲（メタボリックシンドローム基準）
        if patient.isWaistCircumferenceHigh {
            score += 0.15
            factors.append("腹囲高値（内臓脂肪型肥満の疑い）")
            recommendations.append("内臓脂肪を減らす運動を心がけてください")
        }

        // 家族歴
        if patient.familyHistory.diabetesInFamily {
            score += 0.2
            factors.append("糖尿病の家族歴あり")
        }

        // 既往歴
        if patient.medicalHistory.hasDiabetes {
            score += 0.4
            factors.append("糖尿病の既往あり")
            recommendations.append("定期的な血糖コントロールの確認が必要です")
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.1
            factors.append("喫煙習慣あり")
            recommendations.append("禁煙をお勧めします")
        }

        // 飲酒
        if patient.drinkingHabit == .daily || patient.drinkingHabit == .regularly {
            score += 0.05
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("バランスの良い食事と適度な運動を継続してください")
        }

        return DiseaseRisk(
            diseaseName: "糖尿病",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 高血圧リスク評価
    private func calculateHypertensionRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢リスク
        if patient.age >= 40 && patient.age < 50 {
            score += 0.1
        } else if patient.age >= 50 && patient.age < 60 {
            score += 0.2
            factors.append("50歳以上")
        } else if patient.age >= 60 {
            score += 0.3
            factors.append("60歳以上")
        }

        // BMIリスク
        if patient.bmi >= 25 {
            score += 0.15
            factors.append("肥満")
            recommendations.append("減塩と適正体重の維持を心がけてください")
        }

        // 家族歴
        if patient.familyHistory.hypertensionInFamily {
            score += 0.15
            factors.append("高血圧の家族歴あり")
        }

        // 既往歴
        if patient.medicalHistory.hasHypertension {
            score += 0.4
            factors.append("高血圧の既往あり")
            recommendations.append("降圧薬の継続と定期的な血圧測定が必要です")
        }

        // 飲酒（日本人は飲酒による血圧上昇リスクが高い）
        if patient.drinkingHabit == .daily {
            score += 0.15
            factors.append("毎日の飲酒習慣")
            recommendations.append("節酒を心がけてください（1日エタノール20g以下）")
        } else if patient.drinkingHabit == .regularly {
            score += 0.1
            factors.append("習慣的な飲酒")
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.1
            factors.append("喫煙習慣あり")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("減塩食と定期的な血圧測定を続けてください")
        }

        return DiseaseRisk(
            diseaseName: "高血圧",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 脂質異常症リスク評価
    private func calculateDyslipidemiaRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢リスク（男性40歳以上、女性50歳以上でリスク上昇）
        if patient.gender == .male && patient.age >= 40 {
            score += 0.15
            factors.append("40歳以上の男性")
        } else if patient.gender == .female && patient.age >= 50 {
            score += 0.15
            factors.append("50歳以上の女性（閉経後）")
        }

        // BMIリスク
        if patient.bmi >= 25 {
            score += 0.2
            factors.append("肥満")
            recommendations.append("脂肪分を控えた食事を心がけてください")
        }

        // 既往歴
        if patient.medicalHistory.hasDyslipidemia {
            score += 0.35
            factors.append("脂質異常症の既往あり")
            recommendations.append("定期的な脂質検査を継続してください")
        }

        // 飲酒（中性脂肪上昇リスク）
        if patient.drinkingHabit == .daily {
            score += 0.15
            factors.append("毎日の飲酒習慣（中性脂肪上昇リスク）")
        }

        // 喫煙（HDL低下リスク）
        if patient.smokingHabit == .current {
            score += 0.1
            factors.append("喫煙習慣あり（HDLコレステロール低下リスク）")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("バランスの良い食事と運動習慣を維持してください")
        }

        return DiseaseRisk(
            diseaseName: "脂質異常症",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 心疾患リスク評価
    // 吹田スコアなど日本人向けリスク評価を参考
    private func calculateHeartDiseaseRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢リスク
        if patient.age >= 45 && patient.age < 55 {
            score += 0.1
        } else if patient.age >= 55 && patient.age < 65 {
            score += 0.2
            factors.append("55歳以上")
        } else if patient.age >= 65 {
            score += 0.3
            factors.append("65歳以上")
        }

        // 性別リスク（日本人男性はリスク高い）
        if patient.gender == .male {
            score += 0.1
            factors.append("男性")
        }

        // BMIリスク
        if patient.bmi >= 25 {
            score += 0.1
            factors.append("肥満")
        }

        // 家族歴
        if patient.familyHistory.heartDiseaseInFamily {
            score += 0.2
            factors.append("心疾患の家族歴あり")
        }

        // 既往歴
        if patient.medicalHistory.hasHeartDisease {
            score += 0.4
            factors.append("心疾患の既往あり")
            recommendations.append("循環器内科での定期フォローが必須です")
        }

        if patient.medicalHistory.hasDiabetes {
            score += 0.15
            factors.append("糖尿病あり")
        }

        if patient.medicalHistory.hasHypertension {
            score += 0.15
            factors.append("高血圧あり")
        }

        if patient.medicalHistory.hasDyslipidemia {
            score += 0.1
            factors.append("脂質異常症あり")
        }

        // 喫煙（心血管リスクの主要因子）
        if patient.smokingHabit == .current {
            score += 0.2
            factors.append("喫煙習慣あり")
            recommendations.append("禁煙は心疾患リスク低減に最も効果的です")
        } else if patient.smokingHabit == .former {
            score += 0.05
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("禁煙、減塩、適度な運動を心がけてください")
        }

        return DiseaseRisk(
            diseaseName: "心疾患（虚血性心疾患）",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 脳卒中リスク評価
    private func calculateStrokeRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢リスク（日本人の脳卒中は高齢でリスク急増）
        if patient.age >= 50 && patient.age < 60 {
            score += 0.1
        } else if patient.age >= 60 && patient.age < 70 {
            score += 0.2
            factors.append("60歳以上")
        } else if patient.age >= 70 {
            score += 0.35
            factors.append("70歳以上")
        }

        // 家族歴
        if patient.familyHistory.strokeInFamily {
            score += 0.15
            factors.append("脳卒中の家族歴あり")
        }

        // 既往歴
        if patient.medicalHistory.hasStroke {
            score += 0.4
            factors.append("脳卒中の既往あり")
            recommendations.append("脳神経内科での定期フォローが必須です")
        }

        if patient.medicalHistory.hasHypertension {
            score += 0.25
            factors.append("高血圧あり（脳卒中の最大リスク因子）")
            recommendations.append("血圧管理が脳卒中予防の鍵です")
        }

        if patient.medicalHistory.hasDiabetes {
            score += 0.1
            factors.append("糖尿病あり")
        }

        if patient.medicalHistory.hasHeartDisease {
            score += 0.15
            factors.append("心疾患あり（心原性脳塞栓のリスク）")
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.15
            factors.append("喫煙習慣あり")
        }

        // 飲酒（大量飲酒は脳出血リスク上昇）
        if patient.drinkingHabit == .daily {
            score += 0.1
            factors.append("毎日の飲酒習慣")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("血圧管理と禁煙・節酒を心がけてください")
        }

        return DiseaseRisk(
            diseaseName: "脳卒中",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 肝疾患リスク評価
    private func calculateLiverDiseaseRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // BMIリスク（脂肪肝リスク）
        if patient.bmi >= 25 && patient.bmi < 30 {
            score += 0.2
            factors.append("肥満（脂肪肝リスク）")
            recommendations.append("減量により脂肪肝が改善することがあります")
        } else if patient.bmi >= 30 {
            score += 0.35
            factors.append("高度肥満（非アルコール性脂肪肝疾患のリスク高）")
        }

        // 飲酒（アルコール性肝障害）
        let dailyAlcohol = patient.drinkingHabit.estimatedDailyAlcohol
        if dailyAlcohol >= 60 {
            score += 0.4
            factors.append("大量飲酒（1日エタノール60g以上）")
            recommendations.append("アルコール性肝障害のリスクが高いです。節酒・断酒を強くお勧めします")
        } else if dailyAlcohol >= 40 {
            score += 0.25
            factors.append("習慣的飲酒（1日エタノール40g以上）")
            recommendations.append("肝機能への影響を定期的に確認してください")
        } else if dailyAlcohol >= 20 {
            score += 0.1
            factors.append("飲酒習慣あり")
        }

        // 既往歴
        if patient.medicalHistory.hasLiverDisease {
            score += 0.35
            factors.append("肝疾患の既往あり")
            recommendations.append("消化器内科での定期フォローが必要です")
        }

        if patient.medicalHistory.hasDiabetes {
            score += 0.1
            factors.append("糖尿病あり（NAFLD/NASHリスク）")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("適正体重の維持と節酒を心がけてください")
        }

        return DiseaseRisk(
            diseaseName: "肝疾患",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 肺疾患リスク評価
    private func calculateLungDiseaseRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 喫煙（COPD、肺がんの主要リスク因子）
        if patient.smokingHabit == .current {
            score += 0.4
            factors.append("現在喫煙中")
            recommendations.append("禁煙外来の受診をお勧めします")
            recommendations.append("COPD（慢性閉塞性肺疾患）のリスクが高いです")
        } else if patient.smokingHabit == .former {
            score += 0.2
            factors.append("過去の喫煙歴あり")
            recommendations.append("禁煙後も定期的な肺機能検査をお勧めします")
        }

        // 年齢リスク
        if patient.age >= 40 && patient.smokingHabit != .never {
            score += 0.1
            factors.append("40歳以上の喫煙経験者")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("禁煙を継続し、受動喫煙も避けてください")
        }

        return DiseaseRisk(
            diseaseName: "肺疾患（COPD等）",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - がんリスク評価
    private func calculateCancerRisks(for patient: Patient) -> [DiseaseRisk] {
        var cancerRisks: [DiseaseRisk] = []

        // 肺がんリスク
        cancerRisks.append(calculateLungCancerRisk(for: patient))

        // 胃がんリスク（日本人に多い）
        cancerRisks.append(calculateStomachCancerRisk(for: patient))

        // 大腸がんリスク
        cancerRisks.append(calculateColorectalCancerRisk(for: patient))

        // 性別特有のがん
        if patient.gender == .male {
            cancerRisks.append(calculateProstateCancerRisk(for: patient))
        } else {
            cancerRisks.append(calculateBreastCancerRisk(for: patient))
            cancerRisks.append(calculateCervicalCancerRisk(for: patient))
        }

        return cancerRisks
    }

    // MARK: - 肺がんリスク
    private func calculateLungCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.5
            factors.append("現在喫煙中")
            recommendations.append("禁煙により肺がんリスクは徐々に低下します")
        } else if patient.smokingHabit == .former {
            score += 0.25
            factors.append("過去の喫煙歴あり")
        }

        // 年齢
        if patient.age >= 50 {
            score += 0.1
            factors.append("50歳以上")
        }

        // 家族歴
        if patient.familyHistory.cancerInFamily {
            score += 0.1
            factors.append("がんの家族歴あり")
        }

        score = min(score, 1.0)

        if recommendations.isEmpty {
            recommendations.append("禁煙と受動喫煙の回避を続けてください")
        }
        recommendations.append("40歳以上は年1回の肺がん検診をお勧めします")

        return DiseaseRisk(
            diseaseName: "肺がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 胃がんリスク（日本人に特徴的）
    private func calculateStomachCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢（50歳以上でリスク上昇）
        if patient.age >= 50 && patient.age < 60 {
            score += 0.15
            factors.append("50歳以上")
        } else if patient.age >= 60 {
            score += 0.25
            factors.append("60歳以上")
        }

        // 性別（男性でリスク高い）
        if patient.gender == .male {
            score += 0.1
            factors.append("男性")
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.15
            factors.append("喫煙習慣あり")
        }

        // 飲酒
        if patient.drinkingHabit == .daily {
            score += 0.1
            factors.append("毎日の飲酒習慣")
        }

        // 家族歴
        if patient.familyHistory.cancerInFamily {
            score += 0.1
            factors.append("がんの家族歴あり")
        }

        score = min(score, 1.0)

        recommendations.append("50歳以上は胃内視鏡検査をお勧めします")
        recommendations.append("ピロリ菌検査・除菌をご検討ください")

        return DiseaseRisk(
            diseaseName: "胃がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 大腸がんリスク
    private func calculateColorectalCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢
        if patient.age >= 40 && patient.age < 50 {
            score += 0.1
        } else if patient.age >= 50 {
            score += 0.2
            factors.append("50歳以上")
        }

        // BMI（肥満でリスク上昇）
        if patient.bmi >= 25 {
            score += 0.1
            factors.append("肥満")
        }

        // 飲酒
        if patient.drinkingHabit == .daily || patient.drinkingHabit == .regularly {
            score += 0.1
            factors.append("習慣的な飲酒")
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.1
            factors.append("喫煙習慣あり")
        }

        // 家族歴
        if patient.familyHistory.cancerInFamily {
            score += 0.15
            factors.append("がんの家族歴あり")
        }

        score = min(score, 1.0)

        recommendations.append("40歳以上は年1回の便潜血検査をお勧めします")
        recommendations.append("50歳以上は大腸内視鏡検査を検討してください")

        return DiseaseRisk(
            diseaseName: "大腸がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 前立腺がんリスク（男性）
    private func calculateProstateCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢（50歳以上でリスク上昇）
        if patient.age >= 50 && patient.age < 60 {
            score += 0.15
            factors.append("50歳以上")
        } else if patient.age >= 60 && patient.age < 70 {
            score += 0.25
            factors.append("60歳以上")
        } else if patient.age >= 70 {
            score += 0.35
            factors.append("70歳以上")
        }

        // 家族歴
        if patient.familyHistory.cancerInFamily {
            score += 0.15
            factors.append("がんの家族歴あり")
        }

        score = min(score, 1.0)

        recommendations.append("50歳以上はPSA検査を検討してください")

        return DiseaseRisk(
            diseaseName: "前立腺がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 乳がんリスク（女性）
    private func calculateBreastCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢
        if patient.age >= 40 && patient.age < 50 {
            score += 0.15
            factors.append("40歳以上")
        } else if patient.age >= 50 {
            score += 0.2
            factors.append("50歳以上")
        }

        // BMI（閉経後の肥満でリスク上昇）
        if patient.age >= 50 && patient.bmi >= 25 {
            score += 0.1
            factors.append("閉経後の肥満")
        }

        // 飲酒
        if patient.drinkingHabit == .daily {
            score += 0.1
            factors.append("毎日の飲酒習慣")
        }

        // 家族歴
        if patient.familyHistory.cancerInFamily {
            score += 0.2
            factors.append("がんの家族歴あり")
        }

        score = min(score, 1.0)

        recommendations.append("40歳以上は2年に1回のマンモグラフィー検査をお勧めします")
        recommendations.append("定期的な自己検診も有効です")

        return DiseaseRisk(
            diseaseName: "乳がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - 子宮頸がんリスク（女性）
    private func calculateCervicalCancerRisk(for patient: Patient) -> DiseaseRisk {
        var score: Double = 0.0
        var factors: [String] = []
        var recommendations: [String] = []

        // 年齢（20-40代でピーク）
        if patient.age >= 20 && patient.age < 40 {
            score += 0.15
            factors.append("20-40代")
        } else if patient.age >= 40 && patient.age < 60 {
            score += 0.1
        }

        // 喫煙
        if patient.smokingHabit == .current {
            score += 0.1
            factors.append("喫煙習慣あり")
        }

        score = min(score, 1.0)

        recommendations.append("20歳以上は2年に1回の子宮頸がん検診をお勧めします")
        recommendations.append("HPVワクチン接種について医師にご相談ください")

        return DiseaseRisk(
            diseaseName: "子宮頸がん",
            riskLevel: determineRiskLevel(score: score),
            riskScore: score,
            riskFactors: factors,
            recommendations: recommendations
        )
    }

    // MARK: - ヘルパー関数
    private func determineRiskLevel(score: Double) -> RiskLevel {
        switch score {
        case ..<0.2:
            return .low
        case 0.2..<0.4:
            return .moderate
        case 0.4..<0.6:
            return .high
        default:
            return .veryHigh
        }
    }
}
