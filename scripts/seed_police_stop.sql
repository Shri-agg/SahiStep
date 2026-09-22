-- =========================================================
-- SITUATION 1: Police stopped/questioned me
-- Full tree + one fully-formed example leaf.
-- Remaining leaves left as is_verified = FALSE placeholders
-- until legal content is reviewed.
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('police_stop', 'Police stopped/questioned me', 'police-car', 1)
ON CONFLICT (situation_id) DO NOTHING;

-- Q001: Were you arrested or detained?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('Q001', 'police_stop', 'Were you arrested or detained?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('Q001_yes', 'Q001', 'Yes', 'yes', 1),
    ('Q001_no', 'Q001', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- Q002: Were you asked to show ID/documents?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('Q002', 'police_stop', 'Were you asked to show ID or documents?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('Q002_yes', 'Q002', 'Yes', 'yes', 1),
    ('Q002_no', 'Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- Q003: Did you have valid ID/documents with you?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('Q003', 'police_stop', 'Did you have valid ID or documents with you?', 3)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('Q003_yes', 'Q003', 'Yes', 'yes', 1),
    ('Q003_no', 'Q003', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- Q004: Was this a vehicle/traffic stop?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('Q004', 'police_stop', 'Was this a vehicle or traffic stop?', 4)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('Q004_yes', 'Q004', 'Yes', 'yes', 1),
    ('Q004_no', 'Q004', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- Q005: Were you asked to pay a fine on the spot?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('Q005', 'police_stop', 'Were you asked to pay a fine on the spot?', 5)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('Q005_yes', 'Q005', 'Yes', 'yes', 1),
    ('Q005_no', 'Q005', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- =========================================================
-- LEAVES (placeholders — is_verified stays FALSE until legal review)
-- =========================================================

INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    (
        'police_stop_no_id_no_arrest',
        'police_stop',
        '["You cannot be arrested merely for not carrying ID, in most circumstances.",
          "You have the right to know the reason you are being questioned.",
          "You are not obligated to answer questions beyond basic identification unless lawfully detained."]',
        '["Stay calm and avoid confrontation or sudden movements.",
          "Politely ask the officer name and the reason for the stop.",
          "Ask whether you are being detained/arrested or if this is voluntary.",
          "Note the time, place, and officer details if possible."]',
        '["State Human Rights Commission", "Local police complaints authority", "Superintendent of Police (written complaint)"]',
        '[{"document": "BNSS", "section": "TBD - verify exact section", "url": "TBD"},
          {"document": "Constitution of India", "section": "Article 22", "url": "TBD"}]',
        FALSE,
        'manual'
    ),
    ('police_stop_id_shown_no_arrest', 'police_stop', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('police_stop_questioning_no_id_ask', 'police_stop', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('police_stop_traffic_spot_fine', 'police_stop', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('police_stop_traffic_general', 'police_stop', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- =========================================================
-- TREE EDGES (wiring it all together)
-- =========================================================

INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    -- Q001: arrested?
    ('Q001_yes', 'leaf', 'police_stop_id_shown_no_arrest'), -- placeholder: should route to Situation 2 tree once built
    ('Q001_no',  'question', 'Q002'),

    -- Q002: asked for ID?
    ('Q002_yes', 'question', 'Q003'),
    ('Q002_no',  'question', 'Q004'),

    -- Q003: had valid ID?
    ('Q003_yes', 'leaf', 'police_stop_id_shown_no_arrest'),
    ('Q003_no',  'leaf', 'police_stop_no_id_no_arrest'),

    -- Q004: traffic stop?
    ('Q004_yes', 'question', 'Q005'),
    ('Q004_no',  'leaf', 'police_stop_questioning_no_id_ask'),

    -- Q005: spot fine?
    ('Q005_yes', 'leaf', 'police_stop_traffic_spot_fine'),
    ('Q005_no',  'leaf', 'police_stop_traffic_general')
ON CONFLICT DO NOTHING;
