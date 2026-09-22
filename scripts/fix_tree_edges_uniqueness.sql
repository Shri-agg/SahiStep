-- =========================================================
-- FIX: tree_edges was missing a real uniqueness constraint,
-- causing re-running seed files to insert duplicate edges.
-- This script removes existing duplicates and adds the
-- constraint so it can never happen again.
-- =========================================================

-- Step 1: remove duplicate rows, keeping only the lowest edge_id per option_id
DELETE FROM tree_edges a
USING tree_edges b
WHERE a.option_id = b.option_id
  AND a.edge_id > b.edge_id;

-- Step 2: add the missing uniqueness constraint so this can't happen again
ALTER TABLE tree_edges
ADD CONSTRAINT tree_edges_option_id_unique UNIQUE (option_id);

-- Step 3: sanity check — every option_id should now appear exactly once
SELECT option_id, COUNT(*) 
FROM tree_edges 
GROUP BY option_id 
HAVING COUNT(*) > 1;
-- ^ this should return 0 rows if the fix worked