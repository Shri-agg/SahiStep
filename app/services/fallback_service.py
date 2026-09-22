"""
Slow fallback path: triggered only when the chatbot classifier finds no
matching existing leaf. Does hybrid retrieval over the legal corpus, then
asks the LLM to synthesize an answer STRICTLY from retrieved sources.

The output of this path is always marked is_verified = False and flagged
for human review before it can ever be promoted into leaf_responses.
It is shown to the user with a visible "less common situation" notice.
"""

import json
import os
import httpx
from app.db.connection import database

LLM_API_KEY = os.getenv("LLM_API_KEY", "")
LLM_API_URL = "https://api.anthropic.com/v1/messages"

SYSTEM_PROMPT = """You are a legal-information assistant for a police-rights
navigator app in India. You must answer ONLY using the provided source
excerpts. Do not use outside knowledge. If the sources do not clearly
answer the question, say so explicitly rather than guessing.

Respond ONLY as JSON with this exact shape:
{
  "your_rights": ["...", "..."],
  "what_to_do_now": ["...", "..."],
  "where_to_complain": ["...", "..."],
  "sources": [{"document": "...", "section": "...", "url": "..."}]
}
"""


async def keyword_search(query_text: str, limit: int = 5) -> list[dict]:
    rows = await database.fetch_all(
        """
        SELECT doc_id, document, section, source_url, content
        FROM legal_documents
        WHERE to_tsvector('english', content) @@ plainto_tsquery('english', :q)
        LIMIT :limit
        """,
        {"q": query_text, "limit": limit},
    )
    return [dict(r) for r in rows]


async def semantic_search(query_embedding: list[float], limit: int = 5) -> list[dict]:
    """Requires query_embedding to be precomputed via sentence-transformers."""
    rows = await database.fetch_all(
        """
        SELECT doc_id, document, section, source_url, content,
               embedding <-> :qembed AS distance
        FROM legal_documents
        ORDER BY distance ASC
        LIMIT :limit
        """,
        {"qembed": str(query_embedding), "limit": limit},
    )
    return [dict(r) for r in rows]


async def synthesize_answer(user_text: str, retrieved_docs: list[dict]) -> dict:
    sources_block = "\n\n".join(
        f"[{d['document']} {d.get('section', '')}] {d['content']}"
        for d in retrieved_docs
    )

    prompt = f"""User's situation: "{user_text}"

Source excerpts:
{sources_block}

Produce the structured JSON response now."""

    async with httpx.AsyncClient(timeout=25.0) as client:
        response = await client.post(
            LLM_API_URL,
            headers={
                "x-api-key": LLM_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": "claude-3-5-sonnet-20240620",
                "max_tokens": 1000,
                "system": SYSTEM_PROMPT,
                "messages": [{"role": "user", "content": prompt}],
            },
        )
        result = response.json()
        
    if "content" not in result:
        print(f"LLM API Error: {result}")
        raw_text = "{}" # This will force the JSONDecodeError fallback
    else:
        raw_text = result["content"][0]["text"]
    try:
        parsed = json.loads(raw_text.strip().strip("```json").strip("```"))
    except json.JSONDecodeError:
        parsed = {
            "your_rights": [],
            "what_to_do_now": [
                "We could not confidently determine specific guidance for this "
                "situation. Please consult a legal aid service directly."
            ],
            "where_to_complain": [],
            "sources": [],
        }

    parsed["is_verified"] = False
    return parsed


async def run_fallback(session_id: str, user_text: str) -> dict:
    docs = await keyword_search(user_text)
    # semantic_search would be merged in here once embeddings are wired up
    result = await synthesize_answer(user_text, docs)

    await database.execute(
        """
        UPDATE chatbot_queries
        SET llm_generated_response = :resp, fell_back_to_llm = TRUE,
            flagged_for_review = TRUE
        WHERE query_id = (
            SELECT query_id FROM chatbot_queries
            WHERE session_id = :sid
            ORDER BY query_id DESC LIMIT 1
        )
        """,
        {"resp": json.dumps(result), "sid": session_id},
    )

    return result
