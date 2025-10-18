# Research Paper Digestor — README

A reproducible, low-code stack that:

* fetches and stores research papers,
* chunks & embeds content into **Postgres + pgvector**,
* finds **top-K** most relevant papers for a user topic via **Langflow**,
* summarizes each paper with your local **Ollama** LLM,
* (optionally) delivers digests via **n8n** automations through Telegram bot.

This guide takes you **from zero to running** on a single machine using Docker.

---

## 0) What’s inside

* **Postgres (pgvector)** — stores papers, chunks, summaries, and vector index
* **Ollama** — local LLMs for generation & embeddings (e.g., `qwen3:8b`, `qwen3:8b-emb`)
* **Langflow** — visual pipelines (flows) for Top-K search & summarization
* **n8n** — automations

---

## 1) Prerequisites

* Docker & Docker Compose
* (Optional but recommended) **GPU** with NVIDIA drivers for faster LLMs via Ollama
* 6+ GB RAM recommended for 8B models; use smaller models if needed

---


## 2) Configure environment

Copy `infra/.env_example` and fill in missing params


## 3) Docker Compose

Bring the stack up:

```bash
cd infra
docker compose up -d
```

## 4) Initialize the database schema

```bash
docker exec -i $(docker ps -qf name=postgres) psql -U app -d digestor < migrations.sql
```


## 5) Pull models with Ollama

Inside the `ollama` container:

```bash
docker compose exec -T ollama ollama pull qwen3:8b
docker compose exec -T ollama ollama pull qwen3:8b-emb
```


## 6) Import Langflow flows

1. Open **Langflow UI** at `http://localhost:${LANGFLOW_PORT}`.
2. Import `flows/Make Embs.json`, `flows/TopK.json` and `flows/Summary.json`.
3. In the **PGVector** node(s), set **connection string**:
   ```
   postgresql+psycopg2://app:app@postgres:5432/digestor
   ```
4. Save each flow and copy their **Flow IDs** (you can find it by clicking share/API access); paste them into `.env` as `EMBS_FLOW_ID`, `FIND_FLOW_ID` and `SUMMARY_FLOW_ID`.


## 7) n8n “file-trigger → digest” workflow
You have to set up three Credentials inside of n8n 

1) Header Auth Account 
with name x-api-key and your langflow api key as a value (create it on the same bar as you used to find flow's id)

2) Postgres Account (fill it the same as you did in your env)

3) Telegram Account 
create your own bot via Telegram BotFather and paste token  


## 8) ngrok 

To make local n8n work with Telegram, you have to make a tunnel via ngrok (or its analog)

You can find instructions on how to use it in ngrok repo

After installation, run
 
**ngrok http 5678**

Then go to your subdomain/domain and start Telegram flow (toggle active bar)
and make the same at localhost:5678 for Ingestor flow 

IMPORTANT: if you run Ingestor flow from ngrok link, it wouldn't work 


## 10) Last step

run **python setup_flow_ids.py**


### That’s it!

You now have a local, reproducible AI digest system that runs **entirely on your machine**, with flows you can tweak visually in **Langflow** and orchestration in **n8n**.

