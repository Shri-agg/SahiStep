import time
from fastapi import APIRouter, HTTPException
from app.models import InteractRequest, InteractResponse
from app.db.connection import database
from app.services import tree_engine, chatbot, fallback_service

router = APIRouter()


@router.get("/api/situations")
async def list_situations():
    """Home screen cards. Read-only, cheap, cacheable."""
    rows = await database.fetch_all(
        """
        SELECT situation_id, title, icon, display_order
        FROM situations
        WHERE is_active = TRUE
        ORDER BY display_order ASC
        """
    )
    return {"situations": [dict(r) for r in rows]}


@router.post("/api/interact", response_model=InteractResponse)
async def interact(payload: InteractRequest):
    start_time = time.perf_counter()

    # -----------------------------------------------------------
    # ACTION: start  — user tapped a situation card
    # -----------------------------------------------------------
    if payload.action == "start":
        if not payload.situation_id:
            raise HTTPException(400, "situation_id required for 'start'")

        session_id = await tree_engine.create_session(payload.situation_id)
        question = await tree_engine.get_first_question(payload.situation_id)

        if not question:
            raise HTTPException(404, "No questions configured for this situation")

        return InteractResponse(session_id=session_id, type="question", data=question)

    # -----------------------------------------------------------
    # ACTION: answer  — user answered a tree question
    # -----------------------------------------------------------
    elif payload.action == "answer":
        if not (payload.session_id and payload.question_id and payload.option_id):
            raise HTTPException(400, "session_id, question_id, option_id required")

        await tree_engine.save_answer(
            payload.session_id, payload.question_id, payload.option_id
        )
        edge = await tree_engine.get_next_node(payload.option_id)

        if not edge:
            # No edge defined for this option = tree dead-end.
            # Frontend should now offer the "describe your situation" chatbot.
            return InteractResponse(
                session_id=payload.session_id,
                type="error",
                data={"reason": "no_matching_path", "suggest_chatbot": True},
            )

        if edge["next_node_type"] == "question":
            next_question = await tree_engine.get_question_with_options(
                edge["next_node_id"]
            )
            return InteractResponse(
                session_id=payload.session_id, type="question", data=next_question
            )

        else:  # leaf reached — the fast path payoff
            leaf = await tree_engine.get_leaf_response(edge["next_node_id"])
            if not leaf or not leaf["is_verified"]:
                # Safety net: never serve an unverified leaf as if final.
                return InteractResponse(
                    session_id=payload.session_id,
                    type="error",
                    data={"reason": "leaf_unverified", "suggest_chatbot": True},
                )

            elapsed_ms = int((time.perf_counter() - start_time) * 1000)
            await tree_engine.mark_session_resolved(
                payload.session_id, leaf["leaf_id"], "tree", elapsed_ms
            )
            return InteractResponse(
                session_id=payload.session_id,
                type="leaf",
                data=leaf,
                resolution_path="tree",
                is_verified=True,
            )

    # -----------------------------------------------------------
    # ACTION: chatbot  — free text, either homescreen or mid-tree stuck
    # -----------------------------------------------------------
    elif payload.action == "chatbot":
        if not payload.text:
            raise HTTPException(400, "text required for 'chatbot'")

        session_id = payload.session_id or await tree_engine.create_session(None)

        classification = await chatbot.classify_text(
            payload.text, situation_id=payload.situation_id
        )

        await chatbot.log_chatbot_query(
            session_id=session_id,
            raw_text=payload.text,
            entry_point=payload.entry_point or "homescreen",
            matched_leaf_id=classification.get("leaf_id"),
            confidence=classification["confidence"],
            fell_back=not classification["matched"],
        )

        if classification["matched"]:
            leaf = await tree_engine.get_leaf_response(classification["leaf_id"])
            elapsed_ms = int((time.perf_counter() - start_time) * 1000)
            await tree_engine.mark_session_resolved(
                session_id, leaf["leaf_id"], "chatbot_matched", elapsed_ms
            )
            return InteractResponse(
                session_id=session_id,
                type="leaf",
                data=leaf,
                resolution_path="chatbot_matched",
                is_verified=True,
            )

        else:
            # Slow path — genuinely novel situation
            result = await fallback_service.run_fallback(session_id, payload.text)
            elapsed_ms = int((time.perf_counter() - start_time) * 1000)
            await tree_engine.mark_session_resolved(
                session_id, "unresolved_fallback", "chatbot_fallback", elapsed_ms
            )
            return InteractResponse(
                session_id=session_id,
                type="leaf",
                data=result,
                resolution_path="chatbot_fallback",
                is_verified=False,
            )

    raise HTTPException(400, "Unknown action")
