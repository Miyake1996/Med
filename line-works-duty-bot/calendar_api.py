"""LINE WORKS カレンダーAPI連携モジュール"""

import requests
from config import Config
from auth import get_auth_headers


def create_calendar_event(calendar_id, title, event_date, description=""):
    """カレンダーに終日イベントを作成する

    Args:
        calendar_id: カレンダーID
        title: イベントタイトル (例: "当直: 山田太郎")
        event_date: date オブジェクト
        description: イベントの説明

    Returns:
        作成されたイベントの情報
    """
    url = f"{Config.API_BASE}/calendar/v1/calendars/{calendar_id}/events"
    headers = get_auth_headers()

    date_str = event_date.strftime("%Y-%m-%d")

    body = {
        "eventComponents": {
            "summary": title,
            "description": description,
            "start": {
                "date": date_str,
            },
            "end": {
                "date": date_str,
            },
            "isAllDay": True,
        }
    }

    resp = requests.post(url, headers=headers, json=body)
    resp.raise_for_status()
    return resp.json()


def register_duty_schedule(entries):
    """当直スケジュールをカレンダーに一括登録する

    Args:
        entries: parser.parse_duty_schedule() の戻り値

    Returns:
        (成功件数, 失敗件数, エラーリスト)
    """
    calendar_id = Config.TARGET_CALENDAR_ID
    success_count = 0
    fail_count = 0
    errors = []

    for entry in entries:
        title = f"当直: {entry['name']}"
        if entry["role"] and entry["role"] != "当直":
            title += f" ({entry['role']})"

        description = (
            f"担当者: {entry['name']}\n"
            f"役割: {entry['role']}\n"
            f"日付: {entry['date'].strftime('%Y年%m月%d日')}"
        )

        try:
            create_calendar_event(
                calendar_id=calendar_id,
                title=title,
                event_date=entry["date"],
                description=description,
            )
            success_count += 1
        except Exception as e:
            fail_count += 1
            errors.append(f"{entry['date']} {entry['name']}: {e}")

    return success_count, fail_count, errors
