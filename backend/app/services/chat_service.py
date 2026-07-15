import chromadb
from llama_index.core import VectorStoreIndex
from llama_index.vector_stores.chroma import ChromaVectorStore

# qwen3:8b と bge-m3 の設定を読み込む
from app.rag import settings  # noqa: F401

# ChromaDBを開く(起動時に1回だけ)
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("wbc_school_ai")
vector_store = ChromaVectorStore(chroma_collection=collection)

index = VectorStoreIndex.from_vector_store(vector_store)

query_engine = index.as_query_engine(
    similarity_top_k=3,
)


def ask(question: str) -> dict:
    """質問を受け取り、回答と出典を返す"""
    response = query_engine.query(question)

    sources = []
    for node in response.source_nodes:
        meta = node.metadata
        sources.append({
            "file": meta.get("file_name", "不明"),
            "page": meta.get("page_label", "?"),
        })

    return {
        "answer": response.response,
        "sources": sources,
    }