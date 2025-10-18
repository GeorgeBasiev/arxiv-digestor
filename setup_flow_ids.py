import json
import re
import os
from dotenv import load_dotenv

load_dotenv("infra/.env")

EMBS_FLOW_ID = os.getenv("EMBS_FLOW_ID")
SUMMARY_FLOW_ID = os.getenv("SUMMARY_FLOW_ID")
FIND_FLOW_ID = os.getenv("FIND_FLOW_ID")

ingestor_path = "n8n/workflows/ingestor.json"

with open(ingestor_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for node in data.get("nodes", []):
    params = node.get("parameters", {})
    method = params.get("method")
    url = params.get("url")

    if method == "POST" and url and "langflow" in url:
        new_url = f"http://langflow:7860/api/v1/run/{EMBS_FLOW_ID}?stream=false"
        node["parameters"]["url"] = new_url

with open(ingestor_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)


telegram_path = "n8n/workflows/telegram.json"

with open(telegram_path, "r", encoding="utf-8") as f:
    data = json.load(f)

for node in data.get("nodes", []):
    params = node.get("parameters", {})
    method = params.get("method")
    url = params.get("url")

    if method == "POST" and url and "TopKID" in url:
        new_url = f"http://langflow:7860/api/v1/run/{FIND_FLOW_ID}?stream=false"
        node["parameters"]["url"] = new_url

with open(telegram_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

for node in data.get("nodes", []):
    params = node.get("parameters", {})
    method = params.get("method")
    url = params.get("url")

    if method == "POST" and url and "SummaryID" in url:
        new_url = f"http://langflow:7860/api/v1/run/{SUMMARY_FLOW_ID}?stream=false"
        node["parameters"]["url"] = new_url

with open(telegram_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
