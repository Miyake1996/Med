FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Cloud Run は PORT 環境変数でポートを指定する
ENV PORT=8080

CMD exec gunicorn app:app --bind 0.0.0.0:$PORT --workers 1 --threads 2 --timeout 120
