-- pgvector for semantic search (fallback path only) — OPTIONAL.
-- Skipped for now since it requires a separate install on Windows.
-- Uncomment once pgvector is installed on your system:
-- CREATE EXTENSION IF NOT EXISTS vector;

-- =========================================================
-- 1. DECISION TREE STRUCTURE
-- =========================================================

CREATE TABLE IF NOT EXISTS situations (
    situation_id    TEXT PRIMARY KEY,
    title           TEXT NOT NULL,
    icon            TEXT,
    display_order   INT DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS questions (
    question_id     TEXT PRIMARY KEY,
    situation_id    TEXT REFERENCES situations(situation_id),
    question_text   TEXT NOT NULL,
    question_type   TEXT DEFAULT 'single_choice',
    display_order   INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS question_options (
    option_id       TEXT PRIMARY KEY,
    question_id     TEXT REFERENCES questions(question_id),
    option_label    TEXT NOT NULL,
    option_value    TEXT NOT NULL,
    display_order   INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS tree_edges (
    edge_id         SERIAL PRIMARY KEY,
    option_id       TEXT REFERENCES question_options(option_id),
    next_node_type  TEXT CHECK (next_node_type IN ('question','leaf')),
    next_node_id    TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_edges_option ON tree_edges(option_id);
CREATE INDEX IF NOT EXISTS idx_questions_situation ON questions(situation_id);
CREATE INDEX IF NOT EXISTS idx_options_question ON question_options(question_id);

-- =========================================================
-- 2. PRE-VERIFIED LEAF RESPONSES (the fast path)
-- =========================================================

CREATE TABLE IF NOT EXISTS leaf_responses (
    leaf_id             TEXT PRIMARY KEY,
    situation_id        TEXT REFERENCES situations(situation_id),

    your_rights          JSONB NOT NULL,
    what_to_do_now         JSONB NOT NULL,
    where_to_complain    JSONB,

    sources               JSONB NOT NULL,

    is_verified           BOOLEAN DEFAULT FALSE,
    verified_by            TEXT,
    verified_at             TIMESTAMP,
    state_specific          TEXT,
    last_reviewed_at         TIMESTAMP,
    created_from           TEXT DEFAULT 'manual'
);

CREATE INDEX IF NOT EXISTS idx_leaf_situation ON leaf_responses(situation_id);
CREATE INDEX IF NOT EXISTS idx_leaf_verified ON leaf_responses(is_verified);

-- =========================================================
-- 3. LEGAL CORPUS (fallback path only)
-- =========================================================

CREATE TABLE IF NOT EXISTS legal_documents (
    doc_id          SERIAL PRIMARY KEY,
    document        TEXT NOT NULL,
    section         TEXT,
    subsection      TEXT,
    state           TEXT,
    authority       TEXT,
    source_url      TEXT NOT NULL,
    effective_date  DATE,
    last_verified   DATE,
    content         TEXT NOT NULL
    -- embedding    VECTOR(384)  -- uncomment once pgvector is installed
);

CREATE INDEX IF NOT EXISTS idx_legal_fts ON legal_documents
    USING GIN (to_tsvector('english', content));

-- Uncomment once pgvector is installed and the embedding column above is restored:
-- CREATE INDEX IF NOT EXISTS idx_legal_embedding ON legal_documents
--     USING ivfflat (embedding vector_cosine_ops);

-- =========================================================
-- 4. SESSIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS sessions (
    session_id        TEXT PRIMARY KEY,
    situation_id       TEXT REFERENCES situations(situation_id),
    started_at          TIMESTAMP DEFAULT now(),
    answers             JSONB DEFAULT '[]',
    resolved_leaf_id      TEXT,
    resolution_path       TEXT,
    response_time_ms       INT
);

-- =========================================================
-- 5. CHATBOT / FALLBACK LOGS
-- =========================================================

CREATE TABLE IF NOT EXISTS chatbot_queries (
    query_id                  SERIAL PRIMARY KEY,
    session_id                  TEXT REFERENCES sessions(session_id),
    raw_text                     TEXT NOT NULL,
    entry_point                   TEXT,
    matched_leaf_id                TEXT REFERENCES leaf_responses(leaf_id),
    classification_confidence      FLOAT,
    fell_back_to_llm              BOOLEAN DEFAULT FALSE,
    llm_generated_response          JSONB,
    flagged_for_review             BOOLEAN DEFAULT TRUE,
    created_at                      TIMESTAMP DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chatbot_flagged ON chatbot_queries(flagged_for_review);
