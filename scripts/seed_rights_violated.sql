-- =========================================================
-- SITUATION 6: I believe police violated my rights
-- Demonstrates a question with more than 2 options — the
-- schema/engine supports this natively, not just yes/no.
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('rights_violated', 'I believe police violated my rights', 'shield-alert', 6)
ON CONFLICT (situation_id) DO NOTHING;

-- RIGHTS_Q001: What type of violation?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('RIGHTS_Q001', 'rights_violated', 'What type of violation are you facing?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('RIGHTS_Q001_custodial', 'RIGHTS_Q001', 'Mistreatment in custody', 'custodial_abuse', 1),
    ('RIGHTS_Q001_search', 'RIGHTS_Q001', 'Search of my home/person without proper process', 'illegal_search', 2),
    ('RIGHTS_Q001_other', 'RIGHTS_Q001', 'Something else', 'other', 3)
ON CONFLICT (option_id) DO NOTHING;

-- RIGHTS_Q002: Was the search conducted without a warrant?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('RIGHTS_Q002', 'rights_violated', 'Was the search conducted without a warrant?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('RIGHTS_Q002_yes', 'RIGHTS_Q002', 'Yes', 'yes', 1),
    ('RIGHTS_Q002_no', 'RIGHTS_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('rights_custodial_abuse', 'rights_violated', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('rights_other', 'rights_violated', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('rights_illegal_search_no_warrant', 'rights_violated', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('rights_search_with_warrant', 'rights_violated', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('RIGHTS_Q001_custodial', 'leaf', 'rights_custodial_abuse'),
    ('RIGHTS_Q001_search',    'question', 'RIGHTS_Q002'),
    ('RIGHTS_Q001_other',     'leaf', 'rights_other'),

    ('RIGHTS_Q002_yes', 'leaf', 'rights_illegal_search_no_warrant'),
    ('RIGHTS_Q002_no',  'leaf', 'rights_search_with_warrant')
ON CONFLICT DO NOTHING;
