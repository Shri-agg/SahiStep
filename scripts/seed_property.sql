-- =========================================================
-- SITUATION 3: Police took my phone/property
-- =========================================================

INSERT INTO situations (situation_id, title, icon, display_order)
VALUES ('property_seizure', 'Police took my phone/property', 'smartphone', 3)
ON CONFLICT (situation_id) DO NOTHING;

-- PROP_Q001: Did they show a warrant or written order?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('PROP_Q001', 'property_seizure', 'Did the police show a warrant or written order for the seizure?', 1)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('PROP_Q001_yes', 'PROP_Q001', 'Yes', 'yes', 1),
    ('PROP_Q001_no', 'PROP_Q001', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- PROP_Q002: Did you receive a seizure memo/receipt?
INSERT INTO questions (question_id, situation_id, question_text, display_order)
VALUES ('PROP_Q002', 'property_seizure', 'Did you receive a seizure memo or receipt for the item taken?', 2)
ON CONFLICT (question_id) DO NOTHING;

INSERT INTO question_options (option_id, question_id, option_label, option_value, display_order)
VALUES
    ('PROP_Q002_yes', 'PROP_Q002', 'Yes', 'yes', 1),
    ('PROP_Q002_no', 'PROP_Q002', 'No', 'no', 2)
ON CONFLICT (option_id) DO NOTHING;

-- LEAVES
INSERT INTO leaf_responses
    (leaf_id, situation_id, your_rights, what_to_do_now, where_to_complain, sources, is_verified, created_from)
VALUES
    ('property_seized_no_warrant', 'property_seizure', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('property_seized_with_receipt', 'property_seizure', '[]', '[]', '[]', '[]', FALSE, 'manual'),
    ('property_seized_no_receipt', 'property_seizure', '[]', '[]', '[]', '[]', FALSE, 'manual')
ON CONFLICT (leaf_id) DO NOTHING;

-- EDGES
INSERT INTO tree_edges (option_id, next_node_type, next_node_id) VALUES
    ('PROP_Q001_yes', 'question', 'PROP_Q002'),
    ('PROP_Q001_no',  'leaf', 'property_seized_no_warrant'),

    ('PROP_Q002_yes', 'leaf', 'property_seized_with_receipt'),
    ('PROP_Q002_no',  'leaf', 'property_seized_no_receipt')
ON CONFLICT DO NOTHING;
