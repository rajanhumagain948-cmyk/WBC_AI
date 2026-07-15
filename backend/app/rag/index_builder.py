from llama_index.core import StorageContext, VectorStoreIndex

from app.rag.settings import *
from app.rag.vector_store import vector_store
from app.rag.pdf_loader import load_pdfs

# PDFを1ページ=1ドキュメントで読み込む
documents = load_pdfs()

storage_context = StorageContext.from_defaults(
    vector_store=vector_store
)

index = VectorStoreIndex.from_documents(
    documents,
    storage_context=storage_context,
    show_progress=True,  # 進捗バーを表示
)

print("================================")
print("WBC AI")
print("PDFのインデックス作成完了")
print(f"読み込みページ数：{len(documents)}")
print("================================")