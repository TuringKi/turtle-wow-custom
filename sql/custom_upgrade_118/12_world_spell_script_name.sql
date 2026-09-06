-- Startup compatibility: add the script-name field required by ScriptMgr.
-- Preserve all existing spell fields and rows. Do not import upstream spell overrides.
SET @custom_upgrade_statement = IF(
  EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='spell_template' AND COLUMN_NAME='script_name'),
  'SELECT ''spell_template.script_name already exists; preserved''',
  'ALTER TABLE `spell_template` ADD COLUMN `script_name` VARCHAR(64) NOT NULL DEFAULT '''' AFTER `customFlags`'
);
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;
