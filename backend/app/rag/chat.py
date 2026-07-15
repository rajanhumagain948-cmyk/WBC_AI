import chromadb
from llama_index.core import VectorStoreIndex
from llama_index.vector_stores.chroma import ChromaVectorStore

# settings.py を読み込む(qwen3:8b と bge-m3 の設定)
from app.rag import settings  # noqa: F401

# 保存済みのChromaDBを開く
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("wbc_school_ai")
vector_store = ChromaVectorStore(chroma_collection=collection)

# インデックスを読み込む
index = VectorStoreIndex.from_vector_store(vector_store)

# 質問応答エンジン
query_engine = index.as_query_engine(
    similarity_top_k=3,
)

print("=" * 40)
print("WBC AI チャット(終了は q)")
print("=" * 40)

while True:
    question = input("\n質問> ")
    if question.strip().lower() == "q":
        print("終了します。")
        break

    response = query_engine.query(question)

    print("\n【回答】")
    print(response.response)

    print("\n【出典】")
    for node in response.source_nodes:
        meta = node.metadata
        print(f"- {meta.get('file_name', '不明')} / ページ {meta.get('page_label', '?')}")