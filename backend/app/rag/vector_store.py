import chromadb

from llama_index.vector_stores.chroma import ChromaVectorStore

client = chromadb.PersistentClient(
    path="./chroma_db"
)

collection = client.get_or_create_collection(
    "wbc_school_ai"
)

vector_store = ChromaVectorStore(
    chroma_collection=collection
)