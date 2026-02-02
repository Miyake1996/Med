import Foundation

// MARK: - 検査種別
enum ScreeningType: String, CaseIterable, Identifiable {
    // 一般検査
    case generalCheckup = "一般健康診断"
    case bloodTest = "血液検査"
    case urineTest = "尿検査"
    case bloodPressure = "血圧測定"

    // 糖尿病関連
    case hba1c = "HbA1c検査"
    case glucoseTolerance = "糖負荷試験"

    // 脂質関連
    case lipidPanel = "脂質検査"

    // 肝機能
    case liverFunction = "肝機能検査"
    case abdominalUltrasound = "腹部超音波検査"

    // 腎機能
    case kidneyFunction = "腎機能検査"

    // 心血管系
    case ecg = "心電図検査"
    case echocardiogram = "心臓超音波検査"
    case carotidUltrasound = "頸動脈超音波検査"

    // がん検診
    case lungCancerScreening = "肺がん検診"
    case stomachCancerScreening = "胃がん検診"
    case colonCancerScreening = "大腸がん検診"
    case breastCancerScreening = "乳がん検診"
    case cervicalCancerScreening = "子宮頸がん検診"
    case prostateCancerScreening = "前立腺がん検診"

    // 眼科
    case eyeExam = "眼底検査"

    // その他
    case boneDensity = "骨密度検査"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .generalCheckup:
            return "身体測定、視力・聴力検査を含む基本的な健康診断"
        case .bloodTest:
            return "血球数、生化学検査などの総合的な血液検査"
        case .urineTest:
            return "尿糖、尿蛋白、尿潜血などの検査"
        case .bloodPressure:
            return "高血圧のスクリーニング"
        case .hba1c:
            return "過去1-2ヶ月の平均血糖値を反映する検査"
        case .glucoseTolerance:
            return "糖尿病の確定診断のための検査"
        case .lipidPanel:
            return "総コレステロール、LDL、HDL、中性脂肪の検査"
        case .liverFunction:
            return "AST、ALT、γ-GTPなどの肝機能指標"
        case .abdominalUltrasound:
            return "肝臓、胆嚢、膵臓、腎臓などの画像検査"
        case .kidneyFunction:
            return "クレアチニン、eGFRなどの腎機能指標"
        case .ecg:
            return "不整脈、虚血性心疾患のスクリーニング"
        case .echocardiogram:
            return "心臓の構造と機能を評価する超音波検査"
        case .carotidUltrasound:
            return "動脈硬化の進行度を評価"
        case .lungCancerScreening:
            return "胸部X線検査、喀痰細胞診"
        case .stomachCancerScreening:
            return "胃X線検査または胃内視鏡検査"
        case .colonCancerScreening:
            return "便潜血検査、大腸内視鏡検査"
        case .breastCancerScreening:
            return "マンモグラフィー、乳房超音波検査"
        case .cervicalCancerScreening:
            return "子宮頸部細胞診"
        case .prostateCancerScreening:
            return "PSA（前立腺特異抗原）検査"
        case .eyeExam:
            return "糖尿病網膜症、緑内障のスクリーニング"
        case .boneDensity:
            return "骨粗しょう症のスクリーニング"
        }
    }

    var category: String {
        switch self {
        case .generalCheckup, .bloodTest, .urineTest, .bloodPressure:
            return "一般検査"
        case .hba1c, .glucoseTolerance:
            return "糖尿病関連"
        case .lipidPanel:
            return "脂質関連"
        case .liverFunction, .abdominalUltrasound:
            return "肝臓関連"
        case .kidneyFunction:
            return "腎臓関連"
        case .ecg, .echocardiogram, .carotidUltrasound:
            return "心血管系"
        case .lungCancerScreening, .stomachCancerScreening, .colonCancerScreening,
             .breastCancerScreening, .cervicalCancerScreening, .prostateCancerScreening:
            return "がん検診"
        case .eyeExam:
            return "眼科"
        case .boneDensity:
            return "骨代謝"
        }
    }
}

// MARK: - 検査頻度
enum ScreeningFrequency: String, CaseIterable {
    case monthly = "毎月"
    case quarterly = "3ヶ月ごと"
    case biannually = "6ヶ月ごと"
    case annually = "年1回"
    case biennial = "2年に1回"
    case triennial = "3年に1回"
    case asNeeded = "必要時"

    var monthsInterval: Int {
        switch self {
        case .monthly: return 1
        case .quarterly: return 3
        case .biannually: return 6
        case .annually: return 12
        case .biennial: return 24
        case .triennial: return 36
        case .asNeeded: return 0
        }
    }
}

// MARK: - 検査項目
struct ScreeningItem: Identifiable {
    let id = UUID()
    let type: ScreeningType
    let frequency: ScreeningFrequency
    let priority: Priority
    let reason: String              // この検査が必要な理由
    let nextScheduledDate: Date?    // 次回予定日

    enum Priority: String, CaseIterable, Comparable {
        case essential = "必須"
        case recommended = "推奨"
        case optional = "任意"

        static func < (lhs: Priority, rhs: Priority) -> Bool {
            let order: [Priority] = [.essential, .recommended, .optional]
            guard let lhsIndex = order.firstIndex(of: lhs),
                  let rhsIndex = order.firstIndex(of: rhs) else {
                return false
            }
            return lhsIndex < rhsIndex
        }
    }
}

// MARK: - 検査スケジュール
struct ScreeningSchedule: Identifiable {
    let id = UUID()
    let createdDate: Date
    let patient: Patient
    let riskAssessment: RiskAssessment
    var screeningItems: [ScreeningItem]

    // カテゴリ別に検査項目をグループ化
    var itemsByCategory: [String: [ScreeningItem]] {
        Dictionary(grouping: screeningItems) { $0.type.category }
    }

    // 優先度別に検査項目をグループ化
    var itemsByPriority: [ScreeningItem.Priority: [ScreeningItem]] {
        Dictionary(grouping: screeningItems) { $0.priority }
    }

    // 必須検査項目
    var essentialItems: [ScreeningItem] {
        screeningItems.filter { $0.priority == .essential }
    }

    // 推奨検査項目
    var recommendedItems: [ScreeningItem] {
        screeningItems.filter { $0.priority == .recommended }
    }

    // 任意検査項目
    var optionalItems: [ScreeningItem] {
        screeningItems.filter { $0.priority == .optional }
    }

    // 今後12ヶ月の検査カレンダー
    var yearlyCalendar: [Int: [ScreeningItem]] {
        var calendar: [Int: [ScreeningItem]] = [:]
        let currentMonth = Calendar.current.component(.month, from: Date())

        for item in screeningItems {
            guard item.frequency != .asNeeded else { continue }

            let interval = item.frequency.monthsInterval
            var month = currentMonth

            while month <= currentMonth + 12 {
                if (month - currentMonth) % interval == 0 {
                    let adjustedMonth = ((month - 1) % 12) + 1
                    if calendar[adjustedMonth] == nil {
                        calendar[adjustedMonth] = []
                    }
                    calendar[adjustedMonth]?.append(item)
                }
                month += interval
            }
        }

        return calendar
    }
}
