import Foundation

// MARK: - 検査スケジュール生成サービス
// 日本の健康診断ガイドラインに基づいてスケジュールを生成
class ScheduleGenerator {

    private let riskCalculator = RiskCalculator()

    // MARK: - スケジュール生成
    func generateSchedule(for patient: Patient) -> ScreeningSchedule {
        let riskAssessment = riskCalculator.calculateRiskAssessment(for: patient)
        var screeningItems: [ScreeningItem] = []

        // 基本健康診断（全員必須）
        screeningItems.append(contentsOf: generateBasicScreenings(for: patient))

        // 生活習慣病関連検査
        screeningItems.append(contentsOf: generateLifestyleDiseaseScreenings(for: patient, assessment: riskAssessment))

        // がん検診
        screeningItems.append(contentsOf: generateCancerScreenings(for: patient, assessment: riskAssessment))

        // 追加検査（リスクに応じて）
        screeningItems.append(contentsOf: generateAdditionalScreenings(for: patient, assessment: riskAssessment))

        return ScreeningSchedule(
            createdDate: Date(),
            patient: patient,
            riskAssessment: riskAssessment,
            screeningItems: screeningItems
        )
    }

    // MARK: - 基本健康診断
    private func generateBasicScreenings(for patient: Patient) -> [ScreeningItem] {
        var items: [ScreeningItem] = []
        let calendar = Calendar.current
        let now = Date()

        // 一般健康診断（年1回）
        items.append(ScreeningItem(
            type: .generalCheckup,
            frequency: .annually,
            priority: .essential,
            reason: "労働安全衛生法に基づく定期健康診断",
            nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
        ))

        // 血液検査（年1回、40歳以上は必須）
        let bloodTestPriority: ScreeningItem.Priority = patient.age >= 40 ? .essential : .recommended
        items.append(ScreeningItem(
            type: .bloodTest,
            frequency: .annually,
            priority: bloodTestPriority,
            reason: "生活習慣病のスクリーニング",
            nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
        ))

        // 尿検査（年1回）
        items.append(ScreeningItem(
            type: .urineTest,
            frequency: .annually,
            priority: .essential,
            reason: "腎機能・糖尿病のスクリーニング",
            nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
        ))

        // 血圧測定
        var bpFrequency: ScreeningFrequency = .annually
        var bpPriority: ScreeningItem.Priority = .recommended
        var bpReason = "高血圧のスクリーニング"

        if patient.medicalHistory.hasHypertension {
            bpFrequency = .monthly
            bpPriority = .essential
            bpReason = "高血圧の管理"
        } else if patient.age >= 40 || patient.bmi >= 25 {
            bpFrequency = .quarterly
            bpPriority = .recommended
            bpReason = "高血圧リスクがあるため定期的な測定が必要"
        }

        items.append(ScreeningItem(
            type: .bloodPressure,
            frequency: bpFrequency,
            priority: bpPriority,
            reason: bpReason,
            nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
        ))

        return items
    }

    // MARK: - 生活習慣病関連検査
    private func generateLifestyleDiseaseScreenings(for patient: Patient, assessment: RiskAssessment) -> [ScreeningItem] {
        var items: [ScreeningItem] = []
        let calendar = Calendar.current
        let now = Date()

        // 糖尿病関連検査
        if assessment.diabetesRisk.riskLevel >= .moderate || patient.medicalHistory.hasDiabetes {
            var hba1cFrequency: ScreeningFrequency = .annually
            var hba1cPriority: ScreeningItem.Priority = .recommended

            if patient.medicalHistory.hasDiabetes {
                hba1cFrequency = .quarterly
                hba1cPriority = .essential
            } else if assessment.diabetesRisk.riskLevel >= .high {
                hba1cFrequency = .biannually
                hba1cPriority = .essential
            }

            items.append(ScreeningItem(
                type: .hba1c,
                frequency: hba1cFrequency,
                priority: hba1cPriority,
                reason: "糖尿病リスク：\(assessment.diabetesRisk.riskLevel.rawValue)",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 脂質検査
        if assessment.dyslipidemiaRisk.riskLevel >= .low || patient.age >= 40 {
            var lipidFrequency: ScreeningFrequency = .annually
            var lipidPriority: ScreeningItem.Priority = .recommended

            if patient.medicalHistory.hasDyslipidemia || assessment.dyslipidemiaRisk.riskLevel >= .high {
                lipidFrequency = .biannually
                lipidPriority = .essential
            }

            items.append(ScreeningItem(
                type: .lipidPanel,
                frequency: lipidFrequency,
                priority: lipidPriority,
                reason: "脂質異常症リスク：\(assessment.dyslipidemiaRisk.riskLevel.rawValue)",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 肝機能検査
        if assessment.liverDiseaseRisk.riskLevel >= .low ||
           patient.drinkingHabit == .daily ||
           patient.drinkingHabit == .regularly ||
           patient.bmi >= 25 {

            var liverFrequency: ScreeningFrequency = .annually
            var liverPriority: ScreeningItem.Priority = .recommended

            if patient.medicalHistory.hasLiverDisease || assessment.liverDiseaseRisk.riskLevel >= .high {
                liverFrequency = .biannually
                liverPriority = .essential
            }

            items.append(ScreeningItem(
                type: .liverFunction,
                frequency: liverFrequency,
                priority: liverPriority,
                reason: "肝疾患リスク：\(assessment.liverDiseaseRisk.riskLevel.rawValue)",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 腎機能検査
        if patient.age >= 40 || patient.medicalHistory.hasDiabetes || patient.medicalHistory.hasHypertension {
            var kidneyFrequency: ScreeningFrequency = .annually
            var kidneyPriority: ScreeningItem.Priority = .recommended

            if patient.medicalHistory.hasKidneyDisease {
                kidneyFrequency = .quarterly
                kidneyPriority = .essential
            }

            items.append(ScreeningItem(
                type: .kidneyFunction,
                frequency: kidneyFrequency,
                priority: kidneyPriority,
                reason: "腎機能の定期的評価",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 心電図検査
        if patient.age >= 40 || assessment.heartDiseaseRisk.riskLevel >= .moderate {
            var ecgFrequency: ScreeningFrequency = .annually
            var ecgPriority: ScreeningItem.Priority = .recommended

            if patient.medicalHistory.hasHeartDisease {
                ecgFrequency = .biannually
                ecgPriority = .essential
            }

            items.append(ScreeningItem(
                type: .ecg,
                frequency: ecgFrequency,
                priority: ecgPriority,
                reason: "心疾患リスク：\(assessment.heartDiseaseRisk.riskLevel.rawValue)",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        return items
    }

    // MARK: - がん検診
    // 日本のがん検診ガイドラインに基づく
    private func generateCancerScreenings(for patient: Patient, assessment: RiskAssessment) -> [ScreeningItem] {
        var items: [ScreeningItem] = []
        let calendar = Calendar.current
        let now = Date()

        // 肺がん検診（40歳以上、喫煙者は特に重要）
        if patient.age >= 40 {
            var lungPriority: ScreeningItem.Priority = .recommended
            var lungReason = "40歳以上の肺がんスクリーニング"

            if patient.smokingHabit == .current || patient.smokingHabit == .former {
                lungPriority = .essential
                lungReason = "喫煙歴があるため肺がん検診が重要"
            }

            items.append(ScreeningItem(
                type: .lungCancerScreening,
                frequency: .annually,
                priority: lungPriority,
                reason: lungReason,
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 胃がん検診（50歳以上、日本人に特に重要）
        if patient.age >= 50 {
            items.append(ScreeningItem(
                type: .stomachCancerScreening,
                frequency: .biennial,
                priority: .recommended,
                reason: "日本人に多い胃がんのスクリーニング（50歳以上推奨）",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        } else if patient.age >= 40 {
            items.append(ScreeningItem(
                type: .stomachCancerScreening,
                frequency: .triennial,
                priority: .optional,
                reason: "胃がん早期発見のため",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 大腸がん検診（40歳以上）
        if patient.age >= 40 {
            var colonPriority: ScreeningItem.Priority = .recommended
            var colonReason = "40歳以上の大腸がんスクリーニング"

            if patient.familyHistory.cancerInFamily || patient.age >= 50 {
                colonPriority = .essential
                colonReason = "大腸がんリスクが高いため定期検診が重要"
            }

            items.append(ScreeningItem(
                type: .colonCancerScreening,
                frequency: .annually,
                priority: colonPriority,
                reason: colonReason,
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 性別特有のがん検診
        if patient.gender == .male {
            // 前立腺がん検診（50歳以上）
            if patient.age >= 50 {
                items.append(ScreeningItem(
                    type: .prostateCancerScreening,
                    frequency: .annually,
                    priority: .recommended,
                    reason: "50歳以上男性の前立腺がんスクリーニング",
                    nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
                ))
            }
        } else {
            // 乳がん検診（40歳以上）
            if patient.age >= 40 {
                var breastPriority: ScreeningItem.Priority = .recommended
                if patient.familyHistory.cancerInFamily {
                    breastPriority = .essential
                }

                items.append(ScreeningItem(
                    type: .breastCancerScreening,
                    frequency: .biennial,
                    priority: breastPriority,
                    reason: "40歳以上女性の乳がんスクリーニング",
                    nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
                ))
            }

            // 子宮頸がん検診（20歳以上）
            if patient.age >= 20 {
                items.append(ScreeningItem(
                    type: .cervicalCancerScreening,
                    frequency: .biennial,
                    priority: .recommended,
                    reason: "20歳以上女性の子宮頸がんスクリーニング",
                    nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
                ))
            }
        }

        return items
    }

    // MARK: - 追加検査
    private func generateAdditionalScreenings(for patient: Patient, assessment: RiskAssessment) -> [ScreeningItem] {
        var items: [ScreeningItem] = []
        let calendar = Calendar.current
        let now = Date()

        // 腹部超音波検査
        if patient.bmi >= 25 ||
           patient.drinkingHabit == .daily ||
           patient.medicalHistory.hasLiverDisease ||
           assessment.liverDiseaseRisk.riskLevel >= .moderate {

            var abdominalPriority: ScreeningItem.Priority = .recommended
            if patient.medicalHistory.hasLiverDisease {
                abdominalPriority = .essential
            }

            items.append(ScreeningItem(
                type: .abdominalUltrasound,
                frequency: .annually,
                priority: abdominalPriority,
                reason: "肝臓・胆嚢・膵臓の画像評価",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 頸動脈超音波検査
        if assessment.heartDiseaseRisk.riskLevel >= .moderate ||
           assessment.strokeRisk.riskLevel >= .moderate ||
           patient.age >= 50 {

            var carotidPriority: ScreeningItem.Priority = .optional
            var carotidFrequency: ScreeningFrequency = .biennial

            if patient.medicalHistory.hasHeartDisease || patient.medicalHistory.hasStroke {
                carotidPriority = .essential
                carotidFrequency = .annually
            } else if assessment.strokeRisk.riskLevel >= .high {
                carotidPriority = .recommended
            }

            items.append(ScreeningItem(
                type: .carotidUltrasound,
                frequency: carotidFrequency,
                priority: carotidPriority,
                reason: "動脈硬化の進行度評価",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 心臓超音波検査
        if patient.medicalHistory.hasHeartDisease || assessment.heartDiseaseRisk.riskLevel >= .high {
            items.append(ScreeningItem(
                type: .echocardiogram,
                frequency: .annually,
                priority: patient.medicalHistory.hasHeartDisease ? .essential : .recommended,
                reason: "心機能の詳細評価",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 眼底検査
        if patient.medicalHistory.hasDiabetes || patient.medicalHistory.hasHypertension || patient.age >= 40 {
            var eyePriority: ScreeningItem.Priority = .optional
            var eyeFrequency: ScreeningFrequency = .biennial

            if patient.medicalHistory.hasDiabetes {
                eyePriority = .essential
                eyeFrequency = .annually
            }

            items.append(ScreeningItem(
                type: .eyeExam,
                frequency: eyeFrequency,
                priority: eyePriority,
                reason: "糖尿病網膜症・緑内障のスクリーニング",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        // 骨密度検査（女性50歳以上、男性70歳以上）
        if (patient.gender == .female && patient.age >= 50) ||
           (patient.gender == .male && patient.age >= 70) {

            var bonePriority: ScreeningItem.Priority = .optional
            if patient.gender == .female && patient.age >= 65 {
                bonePriority = .recommended
            }

            items.append(ScreeningItem(
                type: .boneDensity,
                frequency: .biennial,
                priority: bonePriority,
                reason: "骨粗しょう症のスクリーニング",
                nextScheduledDate: calendar.date(byAdding: .month, value: 0, to: now)
            ))
        }

        return items
    }
}
