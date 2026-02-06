"""当直表パーサー: OCRテキストから当直スケジュールを抽出する"""

import re
from datetime import datetime, date


def parse_duty_schedule(ocr_text):
    """OCRで抽出したテキストから当直スケジュールを解析する

    対応フォーマット:
    - "1月5日 山田太郎" / "1/5 山田太郎"
    - "2025年1月5日(月) 山田" / "2025/1/5 山田"
    - 表形式: 日付と名前が行ごとに並ぶパターン

    Returns:
        list[dict]: 各要素は {"date": date, "name": str, "role": str}
    """
    entries = []
    lines = ocr_text.strip().split("\n")

    # 年の検出 (テキスト全体から)
    year = _detect_year(ocr_text)
    # 月の検出 (テキスト全体から)
    month = _detect_month(ocr_text)

    for line in lines:
        line = line.strip()
        if not line:
            continue

        parsed = _parse_line(line, year, month)
        if parsed:
            entries.extend(parsed)

    # 日付でソート
    entries.sort(key=lambda e: e["date"])

    return entries


def _detect_year(text):
    """テキストから年を検出する"""
    # "2025年" パターン
    m = re.search(r"(20\d{2})\s*年", text)
    if m:
        return int(m.group(1))

    # "2025/" パターン
    m = re.search(r"(20\d{2})/", text)
    if m:
        return int(m.group(1))

    # "R7" (令和) パターン
    m = re.search(r"[Rr令和]\s*(\d{1,2})", text)
    if m:
        reiwa_year = int(m.group(1))
        return 2018 + reiwa_year

    # デフォルトは現在の年
    return datetime.now().year


def _detect_month(text):
    """テキストから月を検出する"""
    # "1月" "12月" パターン
    m = re.search(r"(\d{1,2})\s*月", text)
    if m:
        return int(m.group(1))
    return None


def _parse_line(line, default_year, default_month):
    """1行から日付と担当者名を解析する"""
    results = []

    # パターン1: "2025年1月5日(月) 山田太郎" or "2025/1/5 山田太郎"
    m = re.match(
        r"(20\d{2})\s*[年/]\s*(\d{1,2})\s*[月/]\s*(\d{1,2})\s*日?"
        r"\s*(?:[（(][月火水木金土日][）)])?\s*(.+)",
        line,
    )
    if m:
        y, mo, d, name_part = int(m.group(1)), int(m.group(2)), int(m.group(3)), m.group(4)
        names = _split_names(name_part)
        for name, role in names:
            results.append({
                "date": date(y, mo, d),
                "name": name,
                "role": role,
            })
        return results

    # パターン2: "1月5日(月) 山田太郎" or "1/5 山田太郎"
    m = re.match(
        r"(\d{1,2})\s*[月/]\s*(\d{1,2})\s*日?"
        r"\s*(?:[（(][月火水木金土日][）)])?\s*(.+)",
        line,
    )
    if m:
        mo, d, name_part = int(m.group(1)), int(m.group(2)), m.group(3)
        year = default_year
        names = _split_names(name_part)
        for name, role in names:
            results.append({
                "date": date(year, mo, d),
                "name": name,
                "role": role,
            })
        return results

    # パターン3: "5日 山田太郎" (月がヘッダーにある場合)
    if default_month:
        m = re.match(
            r"(\d{1,2})\s*日\s*(?:[（(][月火水木金土日][）)])?\s*(.+)",
            line,
        )
        if m:
            d, name_part = int(m.group(1)), m.group(2)
            names = _split_names(name_part)
            for name, role in names:
                results.append({
                    "date": date(default_year, default_month, d),
                    "name": name,
                    "role": role,
                })
            return results

    # パターン4: タブ/スペース区切りの表形式 "5  山田  内科"
    if default_month:
        m = re.match(r"(\d{1,2})\s{2,}(.+)", line)
        if m:
            d, name_part = int(m.group(1)), m.group(2)
            if 1 <= d <= 31:
                names = _split_names(name_part)
                for name, role in names:
                    results.append({
                        "date": date(default_year, default_month, d),
                        "name": name,
                        "role": role,
                    })
                return results

    return None


def _split_names(name_part):
    """名前部分を分割し、(名前, 役割) のリストを返す

    対応パターン:
    - "山田太郎"
    - "山田太郎 内科"
    - "山田太郎/佐藤次郎"
    - "山田(内科) 佐藤(外科)"
    """
    name_part = name_part.strip()
    results = []

    # スラッシュや "・" で複数人の場合
    parts = re.split(r"[/／・、,]", name_part)

    for part in parts:
        part = part.strip()
        if not part:
            continue

        # "山田(内科)" パターン
        m = re.match(r"(.+?)\s*[（(](.+?)[）)]", part)
        if m:
            results.append((m.group(1).strip(), m.group(2).strip()))
            continue

        # "山田 内科" パターン (2つのトークン)
        tokens = part.split()
        if len(tokens) >= 2:
            name = tokens[0]
            role = " ".join(tokens[1:])
            # 役割らしき文字列かチェック (科が含まれるか等)
            if re.search(r"[科部室担当]", role) or role in ("1st", "2nd", "主", "副"):
                results.append((name, role))
            else:
                # 姓名の可能性 (全体を名前として扱う)
                results.append((part, "当直"))
        else:
            results.append((part, "当直"))

    return results


def format_schedule_text(entries):
    """解析した当直スケジュールを整形テキストにする"""
    if not entries:
        return "当直スケジュールを読み取れませんでした。"

    lines = ["当直スケジュール:"]
    current_month = None

    for entry in entries:
        d = entry["date"]
        if current_month != d.month:
            current_month = d.month
            lines.append(f"\n--- {d.year}年{d.month}月 ---")

        weekday = "月火水木金土日"[d.weekday()]
        role_str = f" ({entry['role']})" if entry["role"] != "当直" else ""
        lines.append(f"  {d.month}/{d.day}({weekday}) {entry['name']}{role_str}")

    lines.append(f"\n合計: {len(entries)}件")
    return "\n".join(lines)
