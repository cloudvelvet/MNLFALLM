"""Run the low-cost MAPS LLM-DIF pilot with OpenAI if an API key is set.

This script is intentionally conservative:
- It defaults to a tiny `--limit 3` pilot.
- It requires OPENAI_API_KEY.
- It writes raw JSONL results for reproducibility.

Usage:
  python maps_llm_openai_pilot_runner.py --limit 3
  python maps_llm_openai_pilot_runner.py --limit 30
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from pathlib import Path
from urllib import request, error


ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT / "llm_dif_output"
PROMPTS = OUT_DIR / "maps_llm_pilot_prompts_30.jsonl"


def call_openai(api_key: str, model: str, messages: list[dict[str, str]]) -> dict:
    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0,
        "response_format": {"type": "json_object"},
    }
    data = json.dumps(payload).encode("utf-8")
    req = request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=data,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with request.urlopen(req, timeout=120) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--limit", type=int, default=3)
    parser.add_argument("--model", default=os.environ.get("OPENAI_MODEL", "gpt-4o-mini"))
    parser.add_argument("--sleep", type=float, default=0.25)
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY is not set; no paid API call was made.", file=sys.stderr)
        return 2

    if not PROMPTS.exists():
        print(f"Missing prompt file: {PROMPTS}", file=sys.stderr)
        return 1

    OUT_DIR.mkdir(exist_ok=True)
    out_path = OUT_DIR / f"maps_llm_openai_pilot_results_{args.model}_n{args.limit}.jsonl"

    rows = []
    with PROMPTS.open("r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                rows.append(json.loads(line))
    rows = rows[: args.limit]

    with out_path.open("w", encoding="utf-8") as out:
        for i, row in enumerate(rows, start=1):
            try:
                result = call_openai(api_key, args.model, row["messages"])
                content = result["choices"][0]["message"]["content"]
                record = {
                    "custom_id": row["custom_id"],
                    "model": args.model,
                    "raw_response": result,
                    "content": content,
                }
                print(f"[{i}/{len(rows)}] ok {row['custom_id']}")
            except error.HTTPError as exc:
                body = exc.read().decode("utf-8", errors="replace")
                record = {
                    "custom_id": row["custom_id"],
                    "model": args.model,
                    "error": f"HTTP {exc.code}",
                    "body": body,
                }
                print(f"[{i}/{len(rows)}] error {row['custom_id']}: HTTP {exc.code}")
            except Exception as exc:  # noqa: BLE001
                record = {
                    "custom_id": row["custom_id"],
                    "model": args.model,
                    "error": type(exc).__name__,
                    "body": str(exc),
                }
                print(f"[{i}/{len(rows)}] error {row['custom_id']}: {exc}")

            out.write(json.dumps(record, ensure_ascii=False) + "\n")
            out.flush()
            time.sleep(args.sleep)

    print(f"Saved: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

