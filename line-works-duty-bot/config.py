import os
from dotenv import load_dotenv

load_dotenv()


class Config:
    # LINE WORKS API 2.0
    CLIENT_ID = os.getenv("LINEWORKS_CLIENT_ID")
    CLIENT_SECRET = os.getenv("LINEWORKS_CLIENT_SECRET")
    SERVICE_ACCOUNT = os.getenv("LINEWORKS_SERVICE_ACCOUNT")
    PRIVATE_KEY_PATH = os.getenv("LINEWORKS_PRIVATE_KEY_PATH", "./private_key.pem")

    BOT_ID = os.getenv("LINEWORKS_BOT_ID")
    SOURCE_CHANNEL_ID = os.getenv("SOURCE_CHANNEL_ID")
    TARGET_CALENDAR_ID = os.getenv("TARGET_CALENDAR_ID")

    WEBHOOK_VERIFICATION_TOKEN = os.getenv("WEBHOOK_VERIFICATION_TOKEN")

    # Google Cloud Vision
    GOOGLE_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

    # LINE WORKS API endpoints
    AUTH_URL = "https://auth.worksmobile.com/oauth2/v2.0/token"
    API_BASE = "https://www.worksapis.com/v1.0"

    # Flask
    PORT = int(os.getenv("FLASK_PORT", 8443))
    DEBUG = os.getenv("FLASK_DEBUG", "false").lower() == "true"
