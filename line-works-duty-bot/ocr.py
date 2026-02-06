"""OCR処理モジュール (Google Cloud Vision API)"""

import io
from google.cloud import vision


def extract_text_from_image(image_bytes):
    """画像バイトデータからテキストを抽出する

    Args:
        image_bytes: 画像のバイナリデータ

    Returns:
        抽出されたテキスト文字列
    """
    client = vision.ImageAnnotatorClient()
    image = vision.Image(content=image_bytes)

    # 日本語テキスト検出に document_text_detection を使用
    response = client.document_text_detection(
        image=image,
        image_context=vision.ImageContext(
            language_hints=["ja"],
        ),
    )

    if response.error.message:
        raise RuntimeError(f"Vision API エラー: {response.error.message}")

    if not response.full_text_annotation.text:
        return ""

    return response.full_text_annotation.text
