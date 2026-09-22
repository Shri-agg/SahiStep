-- =========================================================
-- SITUATION 4: Police asked me to come to the station
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('station_notice', 'Police asked me to come to the station', 'notice', 4)
ON CONFLICT (situation_id) DO NOTHING;

-- STATION_Q001: Was this a written notice or a verbal request?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('STATION_Q001', 'station_notice', 'Did you receive this as a written notice, or was it a verbal request?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('STATION_Q001_written', 'STATION_Q001', 'Written notice', 'written', 1),
    ('STATION_Q001_verbal', 'STATION_Q001', 'Verbal request', 'verbal', 2)
ON CONFLICT (option_id) DO NOTHING;

-- STATION_Q002: Does the notice mention a specific reason/section?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('STATION_Q002', 'station_notice', 'Does the notice mention a specific reason or legal section?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('STATION_Q002_yes', 'STATION_Q002', 'Yes', 'yes', 1),
    ('STATION_Q002_no', 'STATION_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('station_verbal_request', 'station_notice', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('station_notice_with_reason', 'station_notice', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('station_notice_no_reason', 'station_notice', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('STATION_Q001_written', 'question', 'STATION_Q002'),
    ('STATION_Q001_verbal',  'leaf', 'station_verbal_request'),

    ('STATION_Q002_yes', 'leaf', 'station_notice_with_reason'),
    ('STATION_Q002_no',  'leaf', 'station_notice_no_reason')
ON CONFLICT DO NOTHING;
