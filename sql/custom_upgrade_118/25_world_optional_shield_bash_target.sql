-- WORLD ONLY. A non-top-threat target is optional for Scarshield Legionnaire's Shield Bash.
-- Preserve SF_GENERAL_ABORT_ON_FAILURE (8); add SF_GENERAL_SKIP_MISSING_TARGETS (16).
-- No target-selection, spell, cooldown, account, or character changes.
UPDATE creature_ai_scripts
SET data_flags = 24
WHERE id = 909702 AND delay = 0 AND priority = 0
  AND command = 15 AND datalong = 11972 AND datalong2 = 0
  AND datalong3 = 0 AND datalong4 = 0
  AND target_type = 5 AND target_param1 = 0 AND target_param2 = 0
  AND condition_id = 0 AND data_flags = 8;
