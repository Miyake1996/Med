"""LINE WORKS API 2.0 認証モジュール (Service Account JWT方式)"""

import time
import jwt
import requests
from config import Config

_access_token = None
_token_expires_at = 0


def _load_private_key():
    return Config.get_private_key()


def _create_jwt():
    """Service Account 認証用の JWT アサーションを生成する"""
    now = int(time.time())
    payload = {
        "iss": Config.CLIENT_ID,
        "sub": Config.SERVICE_ACCOUNT,
        "iat": now,
        "exp": now + 3600,
    }
    private_key = _load_private_key()
    return jwt.encode(payload, private_key, algorithm="RS256")


def get_access_token():
    """アクセストークンを取得する (キャッシュあり)"""
    global _access_token, _token_expires_at

    if _access_token and time.time() < _token_expires_at - 60:
        return _access_token

    assertion = _create_jwt()
    resp = requests.post(
        Config.AUTH_URL,
        data={
            "assertion": assertion,
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "client_id": Config.CLIENT_ID,
            "client_secret": Config.CLIENT_SECRET,
            "scope": "bot calendar",
        },
    )
    resp.raise_for_status()
    data = resp.json()

    _access_token = data["access_token"]
    _token_expires_at = time.time() + data.get("expires_in", 3600)

    return _access_token


def get_auth_headers():
    """認証ヘッダーを返す"""
    token = get_access_token()
    return {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    }
