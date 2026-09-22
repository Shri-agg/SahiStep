-- =========================================================
-- SITUATION 7: Someone I know was arrested
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('known_person_arrested', 'Someone I know was arrested', 'people', 7)
ON CONFLICT (situation_id) DO NOTHING;

-- KNOWN_Q001: Do you know which police station they are held at?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('KNOWN_Q001', 'known_person_arrested', 'Do you know which police station they are being held at?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('KNOWN_Q001_yes', 'KNOWN_Q001', 'Yes', 'yes', 1),
    ('KNOWN_Q001_no', 'KNOWN_Q001', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- KNOWN_Q002: Are you a family member or their lawyer?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('KNOWN_Q002', 'known_person_arrested', 'Are you a family member or their lawyer?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('KNOWN_Q002_yes', 'KNOWN_Q002', 'Yes', 'yes', 1),
    ('KNOWN_Q002_no', 'KNOWN_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('known_arrest_station_unknown', 'known_person_arrested', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('known_arrest_family_lawyer', 'known_person_arrested', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('known_arrest_other_person', 'known_person_arrested', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('KNOWN_Q001_yes', 'question', 'KNOWN_Q002'),
    ('KNOWN_Q001_no',  'leaf', 'known_arrest_station_unknown'),

    ('KNOWN_Q002_yes', 'leaf', 'known_arrest_family_lawyer'),
    ('KNOWN_Q002_no',  'leaf', 'known_arrest_other_person')
ON CONFLICT DO NOTHING;
