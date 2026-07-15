from llama_index.core import Settings
from llama_index.llms.ollama import Ollama
from llama_index.embeddings.ollama import OllamaEmbedding

# 回答AI(無料・ローカル)
Settings.llm = Ollama(
    model="qwen3:8b",
    request_timeout=300.0,
)

# Embedding(無料・ローカル)
Settings.embed_model = OllamaEmbedding(
    model_name="bge-m3",
)