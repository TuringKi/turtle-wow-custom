-- WORLD only. Reviewed and applied on 2026-09-06.
-- Source: database_updates/world/20260721013813_world.sql (two bindings only).
-- Preserve existing custom bindings; verify empty or expected values first.
-- Requires world-server restart to register and load the spell scripts.
-- 46096 restores normal toy learning, which consumes the item when used.
START TRANSACTION;
UPDATE spell_template SET script_name=CASE entry WHEN 46001 THEN 'spell_item_summon_utility_object' WHEN 46096 THEN 'spell_turtle_toy_collection' END WHERE entry IN (46001,46096) AND script_name='';
SELECT ROW_COUNT() AS updated_rows;
COMMIT;
