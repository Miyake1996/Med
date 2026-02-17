import Foundation
import SwiftData

/// 生活習慣病の種別
enum DiseaseType: String, Codable, CaseIterable, Identifiable {
    case diabetes = "糖尿病"
    case hypertension = "高血圧症"
    case dyslipidemia = "脂質異常症"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .diabetes: return "drop.fill"
        case .hypertension: return "heart.fill"
        case .dyslipidemia: return "chart.bar.fill"
        }
    }
}

/// 性別
enum Gender: String, Codable, CaseIterable {
    case male = "男性"
    case female = "女性"
}

/// 患者モデル
@Model
final class Patient {
    var id: UUID
    var name: String
    var kanaName: String
    var birthDate: Date
    var gender: Gender
    var diseases: [DiseaseType]
    var medicalRecordNumber: String
    var memo: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ExaminationRecord.patient)
    var records: [ExaminationRecord] = []

    init(
        name: String,
        kanaName: String = "",
        birthDate: Date,
        gender: Gender,
        diseases: [DiseaseType] = [],
        medicalRecordNumber: String = "",
        memo: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.kanaName = kanaName
        self.birthDate = birthDate
        self.gender = gender
        self.diseases = diseases
        self.medicalRecordNumber = medicalRecordNumber
        self.memo = memo
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    /// 年齢を計算
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    /// 最新の記録を取得
    var latestRecord: ExaminationRecord? {
        records.sorted { $0.recordDate > $1.recordDate }.first
    }
}
