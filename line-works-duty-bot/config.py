import os
import tempfile
from dotenv import load_dotenv

load_dotenv()


class Config:
    # LINE WORKS API 2.0
    CLIENT_ID = os.getenv("LINEWORKS_CLIENT_ID")
    CLIENT_SECRET = os.getenv("LINEWORKS_CLIENT_SECRET")
    SERVICE_ACCOUNT = os.getenv("LINEWORKS_SERVICE_ACCOUNT")

    # 秘密鍵: ファイルパスまたは環境変数(Cloud Run用)のどちらかで指定
    PRIVATE_KEY_PATH = os.getenv("LINEWORKS_PRIVATE_KEY_PATH", "")
    PRIVATE_KEY_DATA = os.getenv("LINEWORKS_PRIVATE_KEY", "")

    BOT_ID = os.getenv("LINEWORKS_BOT_ID")
    SOURCE_CHANNEL_ID = os.getenv("SOURCE_CHANNEL_ID")
    TARGET_CALENDAR_ID = os.getenv("TARGET_CALENDAR_ID")

    WEBHOOK_VERIFICATION_TOKEN = os.getenv("WEBHOOK_VERIFICATION_TOKEN")

    # Google Cloud Vision
    # Cloud Runではプロジェクトに紐づくサービスアカウントが自動で使われるため
    # GOOGLE_APPLICATION_CREDENTIALS は不要
    GOOGLE_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "")

    # LINE WORKS API endpoints
    AUTH_URL = "https://auth.worksmobile.com/oauth2/v2.0/token"
    API_BASE = "https://www.worksapis.com/v1.0"

    # Cloud Run は PORT 環境変数でポートを指定する
    PORT = int(os.getenv("PORT", os.getenv("FLASK_PORT", "8080")))
    DEBUG = os.getenv("FLASK_DEBUG", "false").lower() == "true"

    @classmethod
    def get_private_key(cls):
        """秘密鍵を取得する (ファイルまたは環境変数から)"""
        if cls.PRIVATE_KEY_DATA:
            return cls.PRIVATE_KEY_DATA.replace("\\n", "\n")
        if cls.PRIVATE_KEY_PATH:
            with open(cls.PRIVATE_KEY_PATH, "r") as f:
                return f.read()
        raise ValueError(
            "秘密鍵が設定されていません。"
            "LINEWORKS_PRIVATE_KEY または LINEWORKS_PRIVATE_KEY_PATH を設定してください。"
        )
