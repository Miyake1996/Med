#!/bin/bash
# ===========================================
# Google Cloud Run デプロイスクリプト
# ===========================================
#
# 【事前準備】
# 1. Google Cloud SDK (gcloud) をインストール
#    https://cloud.google.com/sdk/docs/install?hl=ja
#
# 2. 以下の変数を自分の値に書き換えてください
#
# ===========================================

# --- ここを書き換えてください ---
PROJECT_ID="your-gcp-project-id"
REGION="asia-northeast1"           # 東京リージョン
SERVICE_NAME="duty-roster-bot"
# --- ここまで ---

set -e

echo "=== 1. GCPプロジェクトを設定 ==="
gcloud config set project "$PROJECT_ID"

echo ""
echo "=== 2. 必要なAPIを有効化 ==="
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  vision.googleapis.com \
  artifactregistry.googleapis.com

echo ""
echo "=== 3. Dockerイメージをビルド＆プッシュ ==="
gcloud builds submit --tag "gcr.io/$PROJECT_ID/$SERVICE_NAME"

echo ""
echo "=== 4. Cloud Run にデプロイ ==="
echo ""
echo "【重要】以下のコマンドの環境変数を .env の値に書き換えて実行してください:"
echo ""
cat << 'DEPLOY_CMD'
gcloud run deploy duty-roster-bot \
  --image gcr.io/YOUR_PROJECT_ID/duty-roster-bot \
  --region asia-northeast1 \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars "\
LINEWORKS_CLIENT_ID=あなたのClient ID,\
LINEWORKS_CLIENT_SECRET=あなたのClient Secret,\
LINEWORKS_SERVICE_ACCOUNT=あなたのService Account ID,\
LINEWORKS_BOT_ID=あなたのBot ID,\
SOURCE_CHANNEL_ID=あなたのチャンネルID,\
TARGET_CALENDAR_ID=あなたのカレンダーID" \
  --set-env-vars "LINEWORKS_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----\nMIIE...(秘密鍵の中身を改行を\\nに置換して貼り付け)...\n-----END RSA PRIVATE KEY-----"
DEPLOY_CMD

echo ""
echo "=== デプロイが完了すると、以下のようなURLが表示されます ==="
echo "  https://duty-roster-bot-xxxxxxx-an.a.run.app"
echo ""
echo "このURLの末尾に /callback を付けたものを"
echo "LINE WORKS Developer Console の Bot Callback URL に設定してください:"
echo "  https://duty-roster-bot-xxxxxxx-an.a.run.app/callback"
