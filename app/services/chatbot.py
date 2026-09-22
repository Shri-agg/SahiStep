"""
Chatbot classification service.

Job: take free text from the user and either
  (a) map it to an EXISTING verified leaf_id (fast path), or
  (b) signal that nothing matches, triggering the slow retrieval+LLM
      fallback in fallback_service.py

This file intentionally keeps the classification prompt strict: it may only
choose from leaf_ids that actually exist in the database. It must never
invent a leaf_id, and it must never write legal content itself.
"""

import json
import os
import httpx
from app.db.connection import database

LLM_API_KEY = os.getenv("LLM_API_KEY", "")
LLM_API_URL = "https://api.anthropic.com/v1/messages"

CONFIDENCE_THRESHOLD = 0.6


async def _get_available_leaves(situation_id: str | None = None) -> list[dict]:
    """Pull the list of existing verified leaves the classifier is allowed to pick from."""
    if situation_id:
        rows = await database.fetch_all(
            """
            SELECT leaf_id, situation_id FROM leaf_responses
            WHERE is_verified = TRUE AND situation_id = :sid
            """,
            {"sid": situation_id},
        )
    else:
        rows = await database.fetch_all(
            "SELECT leaf_id, situation_id FROM leaf_responses WHERE is_verified = TRUE"
        )
    return [dict(r) for r in rows]


async def classify_text(
    text: str, situation_id: str | None = None, partial_answers: list | None = None
) -> dict:
    """
    Returns:
      {"matched": True, "leaf_id": "...", "confidence": 0.83}
      or
      {"matched": False, "confidence": 0.2}
    """
    candidates = await _get_available_leaves(situation_id)
    if not candidates:
        return {"matched": False, "confidence": 0.0}

    leaf_id_list = [c["leaf_id"] for c in candidates]

    prompt = f"""You are a strict classifier for a police-rights navigator app.
Given the user's free-text description of their situation, choose the SINGLE
best matching leaf_id from this exact list, or respond with "NO_MATCH" if
none genuinely fit. Do not invent leaf_ids.

Available leaf_ids:
{json.dumps(leaf_id_list)}

Context so far (partial answers, if any): {json.dumps(partial_answers or [])}

User's description: "{text}"

Respond ONLY with JSON: {{"leaf_id": "<id or NO_MATCH>", "confidence": <0-1 float>}}
"""

    async with httpx.AsyncClient(timeout=15.0) as client:
        response = await client.post(
            LLM_API_URL,
            headers={
                "x-api-key": LLM_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json",
            },
            json={
                "model": "claude-sonnet-4-6",
                "max_tokens": 200,
                "messages": [{"role": "user", "content": prompt}],
            },
        )
        result = response.json()

    try:
        raw_text = result["content"][0]["text"]
        parsed = json.loads(raw_text.strip().strip("```json").strip("```"))
    except (KeyError, IndexError, json.JSONDecodeError):
        return {"matched": False, "confidence": 0.0}

    leaf_id = parsed.get("leaf_id")
    confidence = float(parsed.get("confidence", 0))

    if leaf_id and leaf_id != "NO_MATCH" and leaf_id in leaf_id_list and confidence >= CONFIDENCE_THRESHOLD:
        return {"matched": True, "leaf_id": leaf_id, "confidence": confidence}

    return {"matched": False, "confidence": confidence}


async def log_chatbot_query(
    session_id: str,
    raw_text: str,
    entry_point: str,
    matched_leaf_id: str | None,
    confidence: float,
    fell_back: bool,
):
    await database.execute(
        """
        INSERT INTO chatbot_queries
            (session_id, raw_text, entry_point, matched_leaf_id,
             classification_confidence, fell_back_to_llm, flagged_for_review)
        VALUES
            (:session_id, :raw_text, :entry_point, :matched_leaf_id,
             :confidence, :fell_back, :flagged)
        """,
        {
            "session_id": session_id,
            "raw_text": raw_text,
            "entry_point": entry_point,
            "matched_leaf_id": matched_leaf_id,
            "confidence": confidence,
            "fell_back": fell_back,
            # Even matched queries get flagged for periodic review;
            # fallback ones are the priority though (handled downstream).
            "flagged": fell_back,
        },
    )
