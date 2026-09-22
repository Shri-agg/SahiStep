from typing import Optional, Literal
from pydantic import BaseModel


class InteractRequest(BaseModel):
    action: Literal["start", "answer", "chatbot"]
    session_id: Optional[str] = None
    situation_id: Optional[str] = None
    question_id: Optional[str] = None
    option_id: Optional[str] = None
    text: Optional[str] = None
    # entry_point distinguishes homescreen chatbot use vs mid-tree stuck fallback
    entry_point: Optional[Literal["homescreen", "mid_tree_stuck"]] = None


class InteractResponse(BaseModel):
    session_id: str
    type: Literal["question", "leaf", "error"]
    data: dict
    resolution_path: Optional[str] = None
    is_verified: Optional[bool] = None
