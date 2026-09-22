-- =========================================================
-- MASTER SEED SCRIPT
-- Runs every situation's tree in the correct order.
-- Run this instead of the individual files one by one.
--
-- Order matters: seed_police_stop.sql must run BEFORE
-- seed_arrest.sql, because seed_arrest.sql patches Situation 1's
-- "arrested = yes" edge to point into Situation 2's real tree.
-- =========================================================

\i scripts/seed_police_stop.sql
\i scripts/seed_arrest.sql
\i scripts/seed_property.sql
\i scripts/seed_station.sql
\i scripts/seed_fir.sql
\i scripts/seed_rights_violated.sql
\i scripts/seed_known_arrest.sql

-- Quick sanity check at the end
SELECT situation_id, title FROM situations ORDER BY display_order;
