import fitz
from pathlib import Path
from llama_index.core import Document

PDF_FOLDER = Path("pdfs")

def load_pdfs():
    documents = []

    for pdf_file in PDF_FOLDER.glob("*.pdf"):
        print(f"読み込み中: {pdf_file.name}")

        doc = fitz.open(pdf_file)

        for page_num, page in enumerate(doc, start=1):
            text = page.get_text()

            # 空白ページはスキップ
            if not text.strip():
                continue

            documents.append(
                Document(
                    text=text,
                    metadata={
                        "file_name": pdf_file.name,
                        "page_label": str(page_num),
                    },
                )
            )

        doc.close()

    print(f"{len(documents)}ページ分のドキュメントを作成しました。")
    return documents


if __name__ == "__main__":
    docs = load_pdfs()
    print(f"合計: {len(docs)}ページ")
    # 最初のページの中身を確認
    if docs:
        print(docs[0].metadata)
        print(docs[0].text[:300])