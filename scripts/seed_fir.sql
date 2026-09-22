-- =========================================================
-- SITUATION 5: Police refused to register my complaint/FIR
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('fir_refused', 'Police refused to register my complaint/FIR', 'document', 5)
ON CONFLICT (situation_id) DO NOTHING;

-- FIR_Q001: Is this a serious/cognizable offence?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('FIR_Q001', 'fir_refused', 'Is this a serious (cognizable) offence, such as theft, assault, or similar?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('FIR_Q001_yes', 'FIR_Q001', 'Yes', 'yes', 1),
    ('FIR_Q001_no', 'FIR_Q001', 'No / Not sure', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- FIR_Q002: Did they give a reason for refusing?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('FIR_Q002', 'fir_refused', 'Did the police give you any reason for refusing to file the FIR?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('FIR_Q002_yes', 'FIR_Q002', 'Yes', 'yes', 1),
    ('FIR_Q002_no', 'FIR_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('fir_non_cognizable', 'fir_refused', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('fir_refused_with_reason', 'fir_refused', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('fir_refused_no_reason', 'fir_refused', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('FIR_Q001_yes', 'question', 'FIR_Q002'),
    ('FIR_Q001_no',  'leaf', 'fir_non_cognizable'),

    ('FIR_Q002_yes', 'leaf', 'fir_refused_with_reason'),
    ('FIR_Q002_no',  'leaf', 'fir_refused_no_reason')
ON CONFLICT DO NOTHING;
