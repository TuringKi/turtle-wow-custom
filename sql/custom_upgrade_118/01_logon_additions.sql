-- Legacy schemas contain zero-date defaults. Relax only the zero-date checks
-- for this session; keep strict conversion checks and restore the original mode.
SET @custom_upgrade_saved_sql_mode = @@SESSION.sql_mode;
SET SESSION sql_mode = REPLACE(REPLACE(@@SESSION.sql_mode, 'NO_ZERO_IN_DATE', ''), 'NO_ZERO_DATE', '');

-- Additive upgrade from the custom 1.17.1 schema to the merged 1.18.1 core.
-- Select the correct existing database before executing this file.
-- Existing columns and all existing rows are preserved.
-- Review 00_preflight.sql and docs/integration/sql-upgrade-118.md first.

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'account' AND COLUMN_NAME = 'active'),
  'SELECT ''account.active already exists; definition unchanged''',
  'ALTER TABLE `account` ADD COLUMN `active` tinyint(3) unsigned NOT NULL DEFAULT 1'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'shop_logs' AND COLUMN_NAME = 'realm_id'),
  'SELECT ''shop_logs.realm_id already exists; definition unchanged''',
  'ALTER TABLE `shop_logs` ADD COLUMN `realm_id` int(10) unsigned NOT NULL DEFAULT 0'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'uptime' AND COLUMN_NAME = 'queue'),
  'SELECT ''uptime.queue already exists; definition unchanged''',
  'ALTER TABLE `uptime` ADD COLUMN `queue` smallint(5) unsigned NOT NULL DEFAULT 0'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'uptime' AND COLUMN_NAME = 'maxqueue'),
  'SELECT ''uptime.maxqueue already exists; definition unchanged''',
  'ALTER TABLE `uptime` ADD COLUMN `maxqueue` smallint(5) unsigned NOT NULL DEFAULT 0'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;

SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'world_config' AND COLUMN_NAME = 'dynamic_scaling_pop'),
  'SELECT ''world_config.dynamic_scaling_pop already exists; definition unchanged''',
  'ALTER TABLE `world_config` ADD COLUMN `dynamic_scaling_pop` int(10) unsigned NOT NULL DEFAULT 0 AFTER `max_item_stack_transferred`'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;


SET SESSION sql_mode = @custom_upgrade_saved_sql_mode;
