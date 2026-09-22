-- =========================================================
-- SITUATION 2: I've been arrested
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('arrest', 'I have been arrested', 'handcuffs', 2)
ON CONFLICT (situation_id) DO NOTHING;

-- ARREST_Q001: Were you informed of the grounds of arrest?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('ARREST_Q001', 'arrest', 'Were you informed of the reason/grounds for your arrest?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('ARREST_Q001_yes', 'ARREST_Q001', 'Yes', 'yes', 1),
    ('ARREST_Q001_no', 'ARREST_Q001', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- ARREST_Q002: Has a family member/friend been informed?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('ARREST_Q002', 'arrest', 'Has a family member or friend been informed of your arrest?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('ARREST_Q002_yes', 'ARREST_Q002', 'Yes', 'yes', 1),
    ('ARREST_Q002_no', 'ARREST_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- ARREST_Q003: Do you have access to a lawyer?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('ARREST_Q003', 'arrest', 'Do you currently have access to a lawyer?', 3)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('ARREST_Q003_yes', 'ARREST_Q003', 'Yes', 'yes', 1),
    ('ARREST_Q003_no', 'ARREST_Q003', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES (placeholders — content pending legal review)
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('arrest_not_informed_grounds', 'arrest', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('arrest_family_not_informed', 'arrest', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('arrest_no_lawyer_access', 'arrest', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('arrest_general_with_lawyer', 'arrest', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('ARREST_Q001_yes', 'question', 'ARREST_Q002'),
    ('ARREST_Q001_no',  'leaf', 'arrest_not_informed_grounds'),

    ('ARREST_Q002_yes', 'question', 'ARREST_Q003'),
    ('ARREST_Q002_no',  'leaf', 'arrest_family_not_informed'),

    ('ARREST_Q003_yes', 'leaf', 'arrest_general_with_lawyer'),
    ('ARREST_Q003_no',  'leaf', 'arrest_no_lawyer_access')
ON CONFLICT DO NOTHING;

-- =========================================================
-- FIX: route Situation 1's "arrested = yes" branch into
-- Situation 2's real arrest tree, now that it exists.
-- =========================================================

UPDATE tree_edges
SET next_node_type = 'question', next_node_id = 'ARREST_Q001'
WHERE option_id = 'Q001_yes';
