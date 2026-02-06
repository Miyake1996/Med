"""LINE WORKS Bot メッセージ送受信モジュール"""

import requests
from config import Config
from auth import get_auth_headers


def download_image(file_id):
    """Bot が受信した画像ファイルをダウンロードする"""
    url = f"{Config.API_BASE}/bots/{Config.BOT_ID}/attachments/{file_id}"
    headers = get_auth_headers()
    headers.pop("Content-Type", None)

    resp = requests.get(url, headers=headers)
    resp.raise_for_status()
    return resp.content


def send_message_to_channel(channel_id, text):
    """指定チャンネルにテキストメッセージを送信する"""
    url = f"{Config.API_BASE}/bots/{Config.BOT_ID}/channels/{channel_id}/messages"
    headers = get_auth_headers()
    body = {
        "content": {
            "type": "text",
            "text": text,
        }
    }

    resp = requests.post(url, headers=headers, json=body)
    resp.raise_for_status()
    return resp.json()


def send_message_to_user(user_id, text):
    """指定ユーザーにテキストメッセージを送信する"""
    url = f"{Config.API_BASE}/bots/{Config.BOT_ID}/users/{user_id}/messages"
    headers = get_auth_headers()
    body = {
        "content": {
            "type": "text",
            "text": text,
        }
    }

    resp = requests.post(url, headers=headers, json=body)
    resp.raise_for_status()
    return resp.json()


def reply_message(user_id, text):
    """ユーザーに返信メッセージを送る (1:1トークの場合)"""
    return send_message_to_user(user_id, text)
