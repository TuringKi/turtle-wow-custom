-- Candidate only. Run in the existing character database after review.
-- No existing rows or column definitions are changed.


SET @custom_upgrade_statement = IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ai_playerbot_equip_cache' AND COLUMN_NAME='spec'), 'SELECT 1', 'ALTER TABLE `ai_playerbot_equip_cache` ADD COLUMN `spec` mediumint(8) NOT NULL DEFAULT 0');
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;


SET @custom_upgrade_statement = IF(EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ai_playerbot_db_store' AND COLUMN_NAME='preset'), 'SELECT 1', 'ALTER TABLE `ai_playerbot_db_store` ADD COLUMN `preset` varchar(32) NOT NULL DEFAULT ''''');
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;


CREATE TABLE IF NOT EXISTS `ai_playerbot_tele_cache` (
  `id` mediumint(8) auto_increment,
  `level` mediumint(8) NOT NULL,
  `map_id` mediumint(8) NOT NULL,
  `x` float(8) NOT NULL,
  `y` float(8) NOT NULL,
  `z` float(8) NOT NULL,
PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED COMMENT='PlayerbotAI Tele Cache';

CREATE TABLE IF NOT EXISTS `ai_playerbot_arena_team_names` (
  `name_id` mediumint(8) NOT NULL AUTO_INCREMENT UNIQUE,
  `name` varchar(24) NOT NULL UNIQUE,
  `type` TINYINT(3) NOT NULL,
  PRIMARY KEY (`name_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED COMMENT='PlayerbotAI arena team names';

CREATE TABLE IF NOT EXISTS `character_inventory_copy` LIKE `character_inventory`;

SET @custom_upgrade_statement = IF(EXISTS (SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ai_playerbot_random_bots' AND INDEX_NAME='idx_owner_bot_event'), 'SELECT 1', 'ALTER TABLE `ai_playerbot_random_bots` ADD INDEX `idx_owner_bot_event` (`owner`, `bot`, `event`)');
PREPARE custom_upgrade_statement FROM @custom_upgrade_statement;
EXECUTE custom_upgrade_statement;
DEALLOCATE PREPARE custom_upgrade_statement;
