-- CHARACTER database only. Expand capacity; no row writes or deletion.
-- Verified current schema: nullable utf8/utf8_general_ci VARCHAR(255), no default value.
-- Skip if already at least 4000; preserve the existing character set and collation.
SET @strategy_ddl = (SELECT IF(DATA_TYPE='varchar' AND CHARACTER_MAXIMUM_LENGTH<4000 AND IS_NULLABLE='YES' AND COLUMN_DEFAULT IS NULL,
 CONCAT('ALTER TABLE ai_playerbot_db_store MODIFY COLUMN value VARCHAR(4000) CHARACTER SET ',CHARACTER_SET_NAME,' COLLATE ',COLLATION_NAME,' NULL DEFAULT NULL'),
 'SELECT 1') FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='ai_playerbot_db_store' AND COLUMN_NAME='value');
PREPARE strategy_stmt FROM @strategy_ddl;
EXECUTE strategy_stmt;
DEALLOCATE PREPARE strategy_stmt;
