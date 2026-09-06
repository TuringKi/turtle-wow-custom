-- Legacy schemas contain zero-date defaults. Relax only the zero-date checks
-- for this session; keep strict conversion checks and restore the original mode.
SET @custom_upgrade_saved_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = REPLACE(REPLACE(@@SESSION.sql_mode, 'NO_ZERO_IN_DATE', ''), 'NO_ZERO_DATE', '');

-- Additive upgrade from the custom 1.17.1 schema to the merged 1.18.1 core.
-- Select the correct existing database before executing this file.
-- Existing columns and all existing rows are preserved.
-- Review 00_preflight.sql and docs/integration/sql-upgrade-118.md first.

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'active'),
  'SELECT ''characters.active already exists; definition unchanged''',
  'ALTER TABLE `characters` ADD COLUMN `active` tinyint(3) unsigned NOT NULL DEFAULT 1'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'characters' AND COLUMN_NAME = 'extraBonusTalentCount'),
  'SELECT ''characters.extraBonusTalentCount already exists; definition unchanged''',
  'ALTER TABLE `characters` ADD COLUMN `extraBonusTalentCount` int(11) NOT NULL DEFAULT 0'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;


SET SESSION sql_mode = @custom_upgrade_saved_sql_mode;
