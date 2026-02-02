import SwiftUI

struct ResultView: View {
    let schedule: ScreeningSchedule
    let onBack: () -> Void

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // タブセレクター
            Picker("表示", selection: $selectedTab) {
                Text("リスク評価").tag(0)
                Text("検査スケジュール").tag(1)
                Text("推奨事項").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            // コンテンツ
            TabView(selection: $selectedTab) {
                RiskAssessmentView(assessment: schedule.riskAssessment)
                    .tag(0)

                ScreeningScheduleView(schedule: schedule)
                    .tag(1)

                RecommendationsView(schedule: schedule)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // 戻るボタン
            Button(action: onBack) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text("入力画面に戻る")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

// MARK: - リスク評価ビュー
struct RiskAssessmentView: View {
    let assessment: RiskAssessment

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 総合リスクカード
                OverallRiskCard(riskLevel: assessment.overallRiskLevel)

                // 患者情報サマリー
                PatientSummaryCard(patient: assessment.patient)

                // 各疾患リスク
                ForEach(assessment.allDiseaseRisks) { risk in
                    DiseaseRiskCard(risk: risk)
                }
            }
            .padding()
        }
    }
}

// MARK: - 総合リスクカード
struct OverallRiskCard: View {
    let riskLevel: RiskLevel

    var body: some View {
        VStack(spacing: 12) {
            Text("総合リスク評価")
                .font(.headline)
                .foregroundColor(.secondary)

            Text(riskLevel.rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(riskColor)

            Text(riskLevel.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(riskColor.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(riskColor, lineWidth: 2)
        )
    }

    private var riskColor: Color {
        switch riskLevel {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - 患者情報サマリーカード
struct PatientSummaryCard: View {
    let patient: Patient

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("患者情報")
                .font(.headline)

            HStack {
                InfoItem(label: "年齢", value: "\(patient.age)歳")
                InfoItem(label: "性別", value: patient.gender.rawValue)
                InfoItem(label: "BMI", value: String(format: "%.1f", patient.bmi))
            }

            HStack {
                InfoItem(label: "飲酒", value: patient.drinkingHabit.rawValue)
            }

            HStack {
                InfoItem(label: "喫煙", value: patient.smokingHabit.rawValue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct InfoItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 疾患リスクカード
struct DiseaseRiskCard: View {
    let risk: DiseaseRisk
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Circle()
                        .fill(riskColor)
                        .frame(width: 12, height: 12)

                    Text(risk.diseaseName)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(risk.riskLevel.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(riskColor)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }

            // リスクバー
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(riskColor)
                        .frame(width: geometry.size.width * risk.riskScore, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            Text("リスクスコア: \(risk.riskPercentage)%")
                .font(.caption)
                .foregroundColor(.secondary)

            // 展開時の詳細
            if isExpanded {
                Divider()

                if !risk.riskFactors.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("リスク因子")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(risk.riskFactors, id: \.self) { factor in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.caption)
                                Text(factor)
                                    .font(.caption)
                            }
                        }
                    }
                }

                if !risk.recommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("推奨事項")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)

                        ForEach(risk.recommendations, id: \.self) { recommendation in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                                Text(recommendation)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var riskColor: Color {
        switch risk.riskLevel {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - 検査スケジュールビュー
struct ScreeningScheduleView: View {
    let schedule: ScreeningSchedule

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 必須検査
                if !schedule.essentialItems.isEmpty {
                    ScreeningCategorySection(
                        title: "必須検査",
                        icon: "exclamationmark.circle.fill",
                        color: .red,
                        items: schedule.essentialItems
                    )
                }

                // 推奨検査
                if !schedule.recommendedItems.isEmpty {
                    ScreeningCategorySection(
                        title: "推奨検査",
                        icon: "star.fill",
                        color: .orange,
                        items: schedule.recommendedItems
                    )
                }

                // 任意検査
                if !schedule.optionalItems.isEmpty {
                    ScreeningCategorySection(
                        title: "任意検査",
                        icon: "info.circle.fill",
                        color: .blue,
                        items: schedule.optionalItems
                    )
                }
            }
            .padding()
        }
    }
}

struct ScreeningCategorySection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [ScreeningItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                Text("(\(items.count)件)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ForEach(items) { item in
                ScreeningItemRow(item: item)
            }
        }
    }
}

struct ScreeningItemRow: View {
    let item: ScreeningItem
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text(item.frequency.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    PriorityBadge(priority: item.priority)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.type.description)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("理由: \(item.reason)")
                            .font(.caption)
                    }

                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.purple)
                            .font(.caption)
                        Text("カテゴリ: \(item.type.category)")
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct PriorityBadge: View {
    let priority: ScreeningItem.Priority

    var body: some View {
        Text(priority.rawValue)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(4)
    }

    private var backgroundColor: Color {
        switch priority {
        case .essential: return .red.opacity(0.2)
        case .recommended: return .orange.opacity(0.2)
        case .optional: return .blue.opacity(0.2)
        }
    }

    private var textColor: Color {
        switch priority {
        case .essential: return .red
        case .recommended: return .orange
        case .optional: return .blue
        }
    }
}

// MARK: - 推奨事項ビュー
struct RecommendationsView: View {
    let schedule: ScreeningSchedule

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 全般的な推奨事項
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("生活習慣の改善ポイント")
                            .font(.headline)
                    }

                    ForEach(schedule.riskAssessment.mainRecommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(recommendation)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)

                // 高リスク疾患への注意
                if !schedule.riskAssessment.highRiskDiseases.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("特に注意が必要な疾患")
                                .font(.headline)
                        }

                        ForEach(schedule.riskAssessment.highRiskDiseases) { risk in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(risk.diseaseName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                ForEach(risk.recommendations, id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("・")
                                        Text(recommendation)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }

                // 年間スケジュールサマリー
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("検査スケジュールサマリー")
                            .font(.headline)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        SummaryRow(label: "必須検査", count: schedule.essentialItems.count, color: .red)
                        SummaryRow(label: "推奨検査", count: schedule.recommendedItems.count, color: .orange)
                        SummaryRow(label: "任意検査", count: schedule.optionalItems.count, color: .blue)
                    }

                    Divider()

                    Text("合計 \(schedule.screeningItems.count) 件の検査が計画されています")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                // 免責事項
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("ご注意")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text("このアプリの結果は参考情報であり、医療診断ではありません。実際の検査や治療については、必ず医療機関にご相談ください。")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
        }
    }
}

struct SummaryRow: View {
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(count)件")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    let patient = Patient(
        age: 55,
        gender: .male,
        heightCm: 172,
        weightKg: 78,
        drinkingHabit: .regularly,
        smokingHabit: .current
    )
    let generator = ScheduleGenerator()
    let schedule = generator.generateSchedule(for: patient)

    return NavigationStack {
        ResultView(schedule: schedule, onBack: {})
            .navigationTitle("検査スケジュール")
    }
}
