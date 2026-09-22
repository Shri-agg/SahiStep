import json
import uuid
from app.db.connection import database


async def create_session(situation_id: str | None) -> str:
    session_id = str(uuid.uuid4())
    await database.execute(
        """
        INSERT INTO sessions (session_id, situation_id, answers)
        VALUES (:session_id, :situation_id, '[]')
        """,
        {"session_id": session_id, "situation_id": situation_id},
    )
    return session_id


async def get_first_question(situation_id: str) -> dict | None:
    question = await database.fetch_one(
        """
        SELECT question_id, question_text, question_type
        FROM questions
        WHERE situation_id = :situation_id
        ORDER BY display_order ASC
        LIMIT 1
        """,
        {"situation_id": situation_id},
    )
    if not question:
        return None
    return await _attach_options(dict(question))


async def get_question_with_options(question_id: str) -> dict | None:
    question = await database.fetch_one(
        """
        SELECT question_id, question_text, question_type
        FROM questions WHERE question_id = :qid
        """,
        {"qid": question_id},
    )
    if not question:
        return None
    return await _attach_options(dict(question))


async def _attach_options(question: dict) -> dict:
    options = await database.fetch_all(
        """
        SELECT option_id, option_label, option_value
        FROM question_options
        WHERE question_id = :qid
        ORDER BY display_order ASC
        """,
        {"qid": question["question_id"]},
    )
    question["options"] = [dict(o) for o in options]
    return question


async def save_answer(session_id: str, question_id: str, option_id: str):
    session = await database.fetch_one(
        "SELECT answers FROM sessions WHERE session_id = :sid",
        {"sid": session_id},
    )
    answers = json.loads(session["answers"]) if session and session["answers"] else []
    answers.append({"question_id": question_id, "option_id": option_id})

    await database.execute(
        "UPDATE sessions SET answers = :answers WHERE session_id = :sid",
        {"answers": json.dumps(answers), "sid": session_id},
    )


async def get_next_node(option_id: str) -> dict | None:
    """
    The core of the whole tree engine. Given the option the user picked,
    find out whether the next step is another question or a final leaf.
    This single lookup works identically for every situation's tree.
    """
    edge = await database.fetch_one(
        """
        SELECT next_node_type, next_node_id
        FROM tree_edges WHERE option_id = :oid
        """,
        {"oid": option_id},
    )
    return dict(edge) if edge else None


async def get_leaf_response(leaf_id: str) -> dict | None:
    leaf = await database.fetch_one(
        """
        SELECT leaf_id, your_rights, what_to_do_now, where_to_complain,
               sources, is_verified, state_specific
        FROM leaf_responses
        WHERE leaf_id = :leaf_id
        """,
        {"leaf_id": leaf_id},
    )
    if not leaf:
        return None

    leaf = dict(leaf)
    # JSONB columns come back as strings via asyncpg in some drivers; normalize
    for field in ("your_rights", "what_to_do_now", "where_to_complain", "sources"):
        if isinstance(leaf[field], str):
            leaf[field] = json.loads(leaf[field])
    return leaf


async def mark_session_resolved(
    session_id: str, leaf_id: str, resolution_path: str, response_time_ms: int
):
    await database.execute(
        """
        UPDATE sessions
        SET resolved_leaf_id = :leaf_id,
            resolution_path = :resolution_path,
            response_time_ms = :response_time_ms
        WHERE session_id = :session_id
        """,
        {
            "leaf_id": leaf_id,
            "resolution_path": resolution_path,
            "response_time_ms": response_time_ms,
            "session_id": session_id,
        },
    )
