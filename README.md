# Police Rights Navigator — Backend

## Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # fill in DATABASE_URL and LLM_API_KEY
```

## Database setup

```bash
psql $DATABASE_URL -f app/db/schema.sql
psql $DATABASE_URL -f scripts/seed_police_stop.sql
```

## Run

```bash
uvicorn app.main:app --reload
```

Visit http://localhost:8000/docs for interactive API docs.

## API surface (intentionally minimal — 2 endpoints)

- `GET /api/situations` — home screen cards
- `POST /api/interact` — everything else (start tree, answer question, chatbot),
  routed internally via the `action` field: `"start" | "answer" | "chatbot"`

## Project layout

```
app/
  main.py              # FastAPI app entrypoint
  models.py            # request/response schemas
  db/
    schema.sql         # full Postgres schema
    connection.py       # async DB pool
  routes/
    interact.py         # the 2 consolidated endpoints
  services/
    tree_engine.py       # generic decision-tree traversal (data-driven, not hardcoded)
    chatbot.py            # free-text -> existing leaf classifier
    fallback_service.py    # slow path: retrieval + LLM synthesis for novel cases
scripts/
  seed_police_stop.sql   # situation 1, fully wired, as the template for the other 6
```

## Important: before launch

Every leaf in `leaf_responses` MUST have `is_verified = TRUE` set only after
a human reviews the `your_rights` / `what_to_do_now` / `sources` content
against actual current law. The seed script ships with placeholders and
`is_verified = FALSE` deliberately — the app will never serve an unverified
leaf as a final answer (see the safety check in routes/interact.py).
