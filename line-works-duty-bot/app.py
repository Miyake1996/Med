"""LINE WORKS 当直表管理 Bot - メインアプリケーション

当直表の写真をトークルームに投稿すると:
1. OCRでテキストを抽出
2. 当直スケジュールを解析
3. 指定カレンダーに登録
4. 結果をトークルームに通知
"""

import json
import logging
import traceback

from flask import Flask, request, jsonify

from config import Config
from bot_api import download_image, send_message_to_channel, reply_message
from ocr import extract_text_from_image
from parser import parse_duty_schedule, format_schedule_text
from calendar_api import register_duty_schedule

app = Flask(__name__)
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)


@app.route("/callback", methods=["POST"])
def callback():
    """LINE WORKS Bot Webhook コールバック"""
    body = request.get_json()
    logger.info("Webhook received: %s", json.dumps(body, ensure_ascii=False)[:500])

    # Webhook 検証リクエスト
    if body.get("type") == "verification":
        return jsonify({"token": body.get("token", "")})

    event_type = body.get("type")

    if event_type == "message":
        _handle_message(body)
    else:
        logger.info("未対応のイベントタイプ: %s", event_type)

    return jsonify({"status": "ok"})


def _handle_message(body):
    """メッセージイベントを処理する"""
    content = body.get("content", {})
    message_type = content.get("type")
    source = body.get("source", {})
    user_id = source.get("userId")
    channel_id = source.get("channelId")

    if message_type == "image":
        _handle_image_message(body, user_id, channel_id)
    elif message_type == "text":
        text = content.get("text", "")
        if text.strip() in ("ヘルプ", "help", "使い方"):
            _send_help(user_id, channel_id)
        else:
            logger.info("テキストメッセージ受信 (処理なし): %s", text[:100])
    else:
        logger.info("未対応のメッセージタイプ: %s", message_type)


def _handle_image_message(body, user_id, channel_id):
    """画像メッセージを処理して当直表を登録する"""
    content = body.get("content", {})
    file_id = content.get("fileId")

    if not file_id:
        logger.error("画像メッセージに fileId がありません")
        return

    # 処理開始を通知
    _notify(user_id, channel_id, "当直表の画像を受信しました。解析中...")

    try:
        # 1. 画像をダウンロード
        logger.info("画像ダウンロード中: fileId=%s", file_id)
        image_bytes = download_image(file_id)

        # 2. OCRでテキスト抽出
        logger.info("OCR処理中...")
        ocr_text = extract_text_from_image(image_bytes)
        logger.info("OCR結果:\n%s", ocr_text[:500])

        if not ocr_text.strip():
            _notify(user_id, channel_id, "画像からテキストを読み取れませんでした。鮮明な画像で再度お試しください。")
            return

        # 3. 当直スケジュールを解析
        logger.info("スケジュール解析中...")
        entries = parse_duty_schedule(ocr_text)

        if not entries:
            _notify(
                user_id,
                channel_id,
                f"当直スケジュールを解析できませんでした。\n\n"
                f"【読み取ったテキスト】\n{ocr_text[:300]}",
            )
            return

        # 4. 解析結果を通知
        schedule_text = format_schedule_text(entries)
        _notify(user_id, channel_id, f"以下のスケジュールを検出しました:\n\n{schedule_text}\n\nカレンダーに登録中...")

        # 5. カレンダーに登録
        logger.info("カレンダー登録中: %d件", len(entries))
        success, fail, errors = register_duty_schedule(entries)

        # 6. 結果を通知
        result_msg = f"カレンダー登録完了\n成功: {success}件"
        if fail > 0:
            result_msg += f"\n失敗: {fail}件"
            for err in errors[:5]:
                result_msg += f"\n  - {err}"

        _notify(user_id, channel_id, result_msg)

        # ターゲットチャンネルにも通知
        if Config.TARGET_CALENDAR_ID and channel_id != Config.SOURCE_CHANNEL_ID:
            try:
                send_message_to_channel(
                    Config.SOURCE_CHANNEL_ID,
                    f"当直表がカレンダーに登録されました ({success}件)",
                )
            except Exception:
                pass

    except Exception as e:
        logger.error("当直表処理エラー: %s\n%s", e, traceback.format_exc())
        _notify(
            user_id,
            channel_id,
            f"処理中にエラーが発生しました:\n{str(e)[:200]}\n\n画像を確認して再度お試しください。",
        )


def _notify(user_id, channel_id, text):
    """ユーザーまたはチャンネルに通知する"""
    try:
        if channel_id:
            send_message_to_channel(channel_id, text)
        elif user_id:
            reply_message(user_id, text)
    except Exception as e:
        logger.error("通知送信失敗: %s", e)


def _send_help(user_id, channel_id):
    """ヘルプメッセージを送信する"""
    help_text = (
        "【当直表管理Bot 使い方】\n\n"
        "1. このトークルームに当直表の写真を送信してください\n"
        "2. Bot が自動で日付と担当者を読み取ります\n"
        "3. 読み取った内容をカレンダーに登録します\n\n"
        "【対応フォーマット】\n"
        "- 1月5日 山田太郎\n"
        "- 1/5 山田太郎\n"
        "- 5日 山田(内科)\n"
        "- 表形式の当直表\n\n"
        "※ 鮮明な画像を使用してください\n"
        "※ 日付と名前が読み取れる形式に対応しています"
    )
    _notify(user_id, channel_id, help_text)


@app.route("/health", methods=["GET"])
def health():
    """ヘルスチェック"""
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    logger.info("LINE WORKS 当直表管理 Bot を起動します (port=%d)", Config.PORT)
    app.run(host="0.0.0.0", port=Config.PORT, debug=Config.DEBUG)
