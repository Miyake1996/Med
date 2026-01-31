import Foundation

/// 日本の小児薬用量ガイドに基づく薬剤データベース
struct DrugDatabase {
    static let drugs: [Drug] = [
        // MARK: - 解熱鎮痛薬

        Drug(
            genericName: "アセトアミノフェン",
            brandName: "カロナール",
            category: .antipyretic,
            dosageForm: .syrup,
            concentration: 20,  // 20mg/mL (2%)
            concentrationUnit: "mg/mL",
            calculationType: .perKgRange(minMgPerKg: 10, maxMgPerKg: 15, frequency: .perDose),
            maxDosePerDay: 60,  // mg/kg/日
            maxDosePerDose: 500,
            ageRestriction: .none,
            notes: "投与間隔は4-6時間以上。1日総量60mg/kg以下"
        ),

        Drug(
            genericName: "アセトアミノフェン",
            brandName: "カロナール細粒",
            category: .antipyretic,
            dosageForm: .powder,
            concentration: 200,  // 200mg/g (20%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 10, maxMgPerKg: 15, frequency: .perDose),
            maxDosePerDay: 60,
            maxDosePerDose: 500,
            ageRestriction: .none,
            notes: "投与間隔は4-6時間以上。1日総量60mg/kg以下"
        ),

        Drug(
            genericName: "アセトアミノフェン",
            brandName: "アンヒバ坐剤",
            category: .antipyretic,
            dosageForm: .suppository,
            concentration: nil,
            concentrationUnit: "mg/個",
            calculationType: .perKgRange(minMgPerKg: 10, maxMgPerKg: 15, frequency: .perDose),
            maxDosePerDay: 60,
            maxDosePerDose: 500,
            ageRestriction: .none,
            notes: "投与間隔は4-6時間以上。坐剤規格: 50mg, 100mg, 200mg"
        ),

        Drug(
            genericName: "イブプロフェン",
            brandName: "ブルフェン",
            category: .antipyretic,
            dosageForm: .syrup,
            concentration: 20,  // 20mg/mL (2%)
            concentrationUnit: "mg/mL",
            calculationType: .perKgRange(minMgPerKg: 5, maxMgPerKg: 10, frequency: .perDose),
            maxDosePerDay: 40,
            maxDosePerDose: 200,
            ageRestriction: .minimum(months: 6),
            notes: "6ヶ月未満には禁忌。1日3回まで"
        ),

        // MARK: - 抗菌薬

        Drug(
            genericName: "アモキシシリン",
            brandName: "サワシリン細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 20, maxMgPerKg: 40, frequency: .perDay),
            maxDosePerDay: 1500,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3-4回に分割投与。重症感染症では高用量"
        ),

        Drug(
            genericName: "アモキシシリン",
            brandName: "ワイドシリン細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 200,  // 200mg/g (20%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 20, maxMgPerKg: 40, frequency: .perDay),
            maxDosePerDay: 1500,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3-4回に分割投与"
        ),

        Drug(
            genericName: "クラブラン酸/アモキシシリン",
            brandName: "クラバモックス",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 64.29,  // AMPC 64.29mg/g相当
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 48.2, maxMgPerKg: 96.4, frequency: .perDay),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 3),
            notes: "1日2回分割投与。製剤量として0.75-1.5g/kg/日"
        ),

        Drug(
            genericName: "セフジニル",
            brandName: "セフゾン細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 9, maxMgPerKg: 18, frequency: .perDay),
            maxDosePerDay: 300,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "セフカペンピボキシル",
            brandName: "フロモックス小児用細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 9, frequency: .perDay),
            maxDosePerDay: 300,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "セフジトレンピボキシル",
            brandName: "メイアクトMS小児用細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 9, frequency: .perDay),
            maxDosePerDay: 300,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "セフポドキシムプロキセチル",
            brandName: "バナン細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 50,  // 50mg/g (5%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 6, maxMgPerKg: 12, frequency: .perDay),
            maxDosePerDay: 300,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "クラリスロマイシン",
            brandName: "クラリスドライシロップ",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 10, maxMgPerKg: 15, frequency: .perDay),
            maxDosePerDay: 400,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日2回に分割投与"
        ),

        Drug(
            genericName: "アジスロマイシン",
            brandName: "ジスロマック細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 10, frequency: .perDay),
            maxDosePerDay: 500,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日1回、3日間投与"
        ),

        Drug(
            genericName: "ホスホマイシン",
            brandName: "ホスミシンドライシロップ",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 400,  // 400mg/g (40%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 40, maxMgPerKg: 120, frequency: .perDay),
            maxDosePerDay: 3000,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3-4回に分割投与"
        ),

        Drug(
            genericName: "トスフロキサシン",
            brandName: "オゼックス細粒",
            category: .antibiotic,
            dosageForm: .powder,
            concentration: 150,  // 150mg/g (15%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 12, frequency: .perDay),
            maxDosePerDay: 360,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日2回に分割投与。キノロン系"
        ),

        // MARK: - 抗ウイルス薬

        Drug(
            genericName: "オセルタミビル",
            brandName: "タミフルドライシロップ",
            category: .antiviral,
            dosageForm: .powder,
            concentration: 30,  // 30mg/g (3%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 4, frequency: .perDay),
            maxDosePerDay: 150,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日2回、5日間投与。予防投与は1日1回"
        ),

        Drug(
            genericName: "ラニナミビル",
            brandName: "イナビル吸入粉末剤",
            category: .antiviral,
            dosageForm: .powder,
            concentration: nil,
            concentrationUnit: "mg/キット",
            calculationType: .byAge(thresholds: [
                (maxMonths: 120, dose: 20),   // 10歳未満: 20mg
                (maxMonths: 999, dose: 40)    // 10歳以上: 40mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "単回吸入。10歳未満は20mg(1容器)、10歳以上は40mg(2容器)"
        ),

        Drug(
            genericName: "アシクロビル",
            brandName: "ゾビラックス顆粒",
            category: .antiviral,
            dosageForm: .granule,
            concentration: 400,  // 400mg/g (40%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 40, maxMgPerKg: 80, frequency: .perDay),
            maxDosePerDay: 4000,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日4-5回に分割投与。水痘には80mg/kg/日"
        ),

        // MARK: - 制吐薬

        Drug(
            genericName: "ドンペリドン",
            brandName: "ナウゼリンドライシロップ",
            category: .antiemetic,
            dosageForm: .powder,
            concentration: 10,  // 10mg/g (1%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 1, maxMgPerKg: 2, frequency: .perDay),
            maxDosePerDay: 30,
            maxDosePerDose: 10,
            ageRestriction: .none,
            notes: "1日3回に分割投与、食前投与"
        ),

        Drug(
            genericName: "ドンペリドン",
            brandName: "ナウゼリン坐剤",
            category: .antiemetic,
            dosageForm: .suppository,
            concentration: nil,
            concentrationUnit: "mg/個",
            calculationType: .perKgRange(minMgPerKg: 1, maxMgPerKg: 2, frequency: .perDay),
            maxDosePerDay: 30,
            maxDosePerDose: 10,
            ageRestriction: .none,
            notes: "坐剤規格: 10mg, 30mg"
        ),

        Drug(
            genericName: "メトクロプラミド",
            brandName: "プリンペランシロップ",
            category: .antiemetic,
            dosageForm: .syrup,
            concentration: 1,  // 1mg/mL (0.1%)
            concentrationUnit: "mg/mL",
            calculationType: .perKg(mgPerKg: 0.5, frequency: .perDay),
            maxDosePerDay: 10,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 1),
            notes: "1日2-3回に分割投与。錐体外路症状に注意"
        ),

        // MARK: - 気管支拡張薬

        Drug(
            genericName: "プロカテロール",
            brandName: "メプチンシロップ",
            category: .bronchodilator,
            dosageForm: .syrup,
            concentration: 0.005,  // 5μg/mL = 0.005mg/mL
            concentrationUnit: "μg/mL",
            calculationType: .perKg(mgPerKg: 0.0025, frequency: .perDay),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日2-3回に分割投与。μg表示注意: 2.5μg/kg/日"
        ),

        Drug(
            genericName: "プロカテロール",
            brandName: "メプチンドライシロップ",
            category: .bronchodilator,
            dosageForm: .powder,
            concentration: 0.05,  // 50μg/g = 0.05mg/g
            concentrationUnit: "μg/g",
            calculationType: .perKg(mgPerKg: 0.0025, frequency: .perDay),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日2回に分割投与。μg表示注意: 2.5μg/kg/日"
        ),

        Drug(
            genericName: "ツロブテロール",
            brandName: "ホクナリンテープ",
            category: .bronchodilator,
            dosageForm: .tape,
            concentration: nil,
            concentrationUnit: "mg/枚",
            calculationType: .byAge(thresholds: [
                (maxMonths: 24, dose: 0.5),    // 0-2歳: 0.5mg
                (maxMonths: 72, dose: 1.0),    // 3-6歳: 1mg
                (maxMonths: 108, dose: 1.5),   // 6-9歳: 1.5mg
                (maxMonths: 999, dose: 2.0)    // 9歳以上: 2mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日1回貼付。規格: 0.5mg, 1mg, 2mg"
        ),

        Drug(
            genericName: "サルブタモール",
            brandName: "ベネトリンシロップ",
            category: .bronchodilator,
            dosageForm: .syrup,
            concentration: 0.4,  // 0.4mg/mL
            concentrationUnit: "mg/mL",
            calculationType: .perKg(mgPerKg: 0.3, frequency: .perDay),
            maxDosePerDay: 8,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        // MARK: - 抗アレルギー薬

        Drug(
            genericName: "ケトチフェン",
            brandName: "ザジテンシロップ",
            category: .antiallergic,
            dosageForm: .syrup,
            concentration: 0.2,  // 0.2mg/mL (0.02%)
            concentrationUnit: "mg/mL",
            calculationType: .perKg(mgPerKg: 0.06, frequency: .perDay),
            maxDosePerDay: 2,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日2回に分割投与"
        ),

        Drug(
            genericName: "ケトチフェン",
            brandName: "ザジテンドライシロップ",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 1,  // 1mg/g (0.1%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 0.06, frequency: .perDay),
            maxDosePerDay: 2,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日2回に分割投与"
        ),

        Drug(
            genericName: "エピナスチン",
            brandName: "アレジオンドライシロップ",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 10,  // 10mg/g (1%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 0.5, frequency: .perDay),
            maxDosePerDay: 20,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 36),
            notes: "1日1回投与"
        ),

        Drug(
            genericName: "セチリジン",
            brandName: "ジルテックドライシロップ",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 12.5,  // 12.5mg/g (1.25%)
            concentrationUnit: "mg/g",
            calculationType: .byAge(thresholds: [
                (maxMonths: 84, dose: 5),     // 2-7歳: 5mg
                (maxMonths: 180, dose: 10)    // 7-15歳: 10mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 24),
            notes: "1日1回就寝前または1日2回朝・就寝前"
        ),

        Drug(
            genericName: "レボセチリジン",
            brandName: "ザイザルシロップ",
            category: .antiallergic,
            dosageForm: .syrup,
            concentration: 0.5,  // 0.5mg/mL (0.05%)
            concentrationUnit: "mg/mL",
            calculationType: .byAge(thresholds: [
                (maxMonths: 84, dose: 2.5),   // 6ヶ月-7歳: 2.5mg
                (maxMonths: 180, dose: 5)     // 7-15歳: 5mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日1回就寝前"
        ),

        Drug(
            genericName: "ロラタジン",
            brandName: "クラリチンドライシロップ",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 10,  // 10mg/g (1%)
            concentrationUnit: "mg/g",
            calculationType: .byAge(thresholds: [
                (maxMonths: 84, dose: 5),     // 3-7歳: 5mg
                (maxMonths: 180, dose: 10)    // 7歳以上: 10mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 36),
            notes: "1日1回食後"
        ),

        Drug(
            genericName: "フェキソフェナジン",
            brandName: "アレグラドライシロップ",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 50,  // 50mg/g (5%)
            concentrationUnit: "mg/g",
            calculationType: .byAge(thresholds: [
                (maxMonths: 144, dose: 30),    // 6ヶ月-12歳: 30mg×2回
                (maxMonths: 999, dose: 60)     // 12歳以上: 60mg×2回
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日2回朝・夕"
        ),

        Drug(
            genericName: "モンテルカスト",
            brandName: "キプレス・シングレア細粒",
            category: .antiallergic,
            dosageForm: .powder,
            concentration: 40,  // 4mg/包
            concentrationUnit: "mg/包",
            calculationType: .byAge(thresholds: [
                (maxMonths: 72, dose: 4),     // 1-6歳: 4mg
                (maxMonths: 180, dose: 5)     // 6-15歳: 5mg
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 12),
            notes: "1日1回就寝前。チュアブル錠もあり"
        ),

        // MARK: - ステロイド

        Drug(
            genericName: "プレドニゾロン",
            brandName: "プレドニン散",
            category: .steroid,
            dosageForm: .powder,
            concentration: 10,  // 10mg/g (1%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 0.5, maxMgPerKg: 2, frequency: .perDay),
            maxDosePerDay: 60,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "適応・重症度により用量調整。漸減投与"
        ),

        Drug(
            genericName: "プレドニゾロン",
            brandName: "プレドニゾロン散「タケダ」",
            category: .steroid,
            dosageForm: .powder,
            concentration: 10,  // 10mg/g (1%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 0.5, maxMgPerKg: 2, frequency: .perDay),
            maxDosePerDay: 60,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "クループ、喘息発作等。急性期は高用量"
        ),

        Drug(
            genericName: "ベタメタゾン",
            brandName: "リンデロンシロップ",
            category: .steroid,
            dosageForm: .syrup,
            concentration: 0.1,  // 0.1mg/mL (0.01%)
            concentrationUnit: "mg/mL",
            calculationType: .perKgRange(minMgPerKg: 0.03, maxMgPerKg: 0.1, frequency: .perDay),
            maxDosePerDay: 2,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日1-4回分割。プレドニゾロンの約6倍の力価"
        ),

        Drug(
            genericName: "デキサメタゾン",
            brandName: "デカドロンエリキシル",
            category: .steroid,
            dosageForm: .syrup,
            concentration: 0.1,  // 0.1mg/mL (0.01%)
            concentrationUnit: "mg/mL",
            calculationType: .perKgRange(minMgPerKg: 0.04, maxMgPerKg: 0.15, frequency: .perDay),
            maxDosePerDay: 4,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日1-4回分割。プレドニゾロンの約7.5倍の力価"
        ),

        // MARK: - 鎮咳薬

        Drug(
            genericName: "デキストロメトルファン",
            brandName: "メジコン散",
            category: .antitussive,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 1, maxMgPerKg: 2, frequency: .perDay),
            maxDosePerDay: 60,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日1-4回に分割投与"
        ),

        Drug(
            genericName: "チペピジン",
            brandName: "アスベリンシロップ",
            category: .antitussive,
            dosageForm: .syrup,
            concentration: 5,  // 5mg/mL (0.5%)
            concentrationUnit: "mg/mL",
            calculationType: .perKgRange(minMgPerKg: 1, maxMgPerKg: 1.5, frequency: .perDay),
            maxDosePerDay: 50,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "チペピジン",
            brandName: "アスベリン散",
            category: .antitussive,
            dosageForm: .powder,
            concentration: 100,  // 100mg/g (10%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 1, maxMgPerKg: 1.5, frequency: .perDay),
            maxDosePerDay: 50,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        // MARK: - 去痰薬

        Drug(
            genericName: "カルボシステイン",
            brandName: "ムコダインシロップ",
            category: .expectorant,
            dosageForm: .syrup,
            concentration: 50,  // 50mg/mL (5%)
            concentrationUnit: "mg/mL",
            calculationType: .perKg(mgPerKg: 30, frequency: .perDay),
            maxDosePerDay: 1500,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "カルボシステイン",
            brandName: "ムコダインDS",
            category: .expectorant,
            dosageForm: .powder,
            concentration: 500,  // 500mg/g (50%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 30, frequency: .perDay),
            maxDosePerDay: 1500,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "アンブロキソール",
            brandName: "ムコソルバンシロップ",
            category: .expectorant,
            dosageForm: .syrup,
            concentration: 3,  // 3mg/mL (0.3%)
            concentrationUnit: "mg/mL",
            calculationType: .perKg(mgPerKg: 0.9, frequency: .perDay),
            maxDosePerDay: 45,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "アンブロキソール",
            brandName: "ムコソルバンDS",
            category: .expectorant,
            dosageForm: .powder,
            concentration: 15,  // 15mg/g (1.5%)
            concentrationUnit: "mg/g",
            calculationType: .perKg(mgPerKg: 0.9, frequency: .perDay),
            maxDosePerDay: 45,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        // MARK: - 整腸・止瀉薬

        Drug(
            genericName: "ビオフェルミン配合散",
            brandName: "ビオフェルミン",
            category: .antidiarrheal,
            dosageForm: .powder,
            concentration: nil,
            concentrationUnit: "g",
            calculationType: .byAge(thresholds: [
                (maxMonths: 36, dose: 1),     // 3歳未満: 1g
                (maxMonths: 108, dose: 2),    // 3-9歳: 2g
                (maxMonths: 999, dose: 3)     // 9歳以上: 3g
            ]),
            maxDosePerDay: nil,
            maxDosePerDose: nil,
            ageRestriction: .none,
            notes: "1日3回に分割投与"
        ),

        Drug(
            genericName: "ロペラミド",
            brandName: "ロペミン小児用細粒",
            category: .antidiarrheal,
            dosageForm: .powder,
            concentration: 0.5,  // 0.5mg/g (0.05%)
            concentrationUnit: "mg/g",
            calculationType: .perKgRange(minMgPerKg: 0.04, maxMgPerKg: 0.08, frequency: .perDay),
            maxDosePerDay: 0.96,
            maxDosePerDose: nil,
            ageRestriction: .minimum(months: 6),
            notes: "1日2-3回に分割投与。感染性腸炎には原則禁忌"
        ),
    ]

    /// カテゴリ別に薬剤を取得
    static func drugs(for category: DrugCategory) -> [Drug] {
        drugs.filter { $0.category == category }
    }

    /// 名前で薬剤を検索
    static func search(query: String) -> [Drug] {
        let lowercasedQuery = query.lowercased()
        return drugs.filter { drug in
            drug.genericName.lowercased().contains(lowercasedQuery) ||
            drug.brandName.lowercased().contains(lowercasedQuery)
        }
    }
}
