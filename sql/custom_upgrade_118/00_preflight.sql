-- Read-only. Run separately in the login, character, world and logs databases.
SELECT DATABASE() AS selected_database, VERSION() AS server_version;
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY TABLE_NAME;
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_DEFAULT, ORDINAL_POSITION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('account', 'characters', 'shop_logs', 'uptime', 'world_config',
                     'character_pvp_currency', 'character_inventory', 'character_inventory_copy',
                     'guild_bank_money', 'migrations', 'ai_playerbot_equip_cache',
                     'ai_playerbot_db_store', 'ai_playerbot_random_bots',
                     'ai_playerbot_arena_team_names', 'ai_playerbot_tele_cache',
                     'custom_merchant', 'itemextendedcost', 'module_string',
                     'module_string_locale', 'skill_race_class_info_mod',
                     'spell_template', 'spell_extra', 'lft_user_groups')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
SELECT TABLE_NAME, INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('ai_playerbot_random_bots', 'spell_template', 'spell_extra')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
-- Do not run the additions against a different baseline without reviewing this output.
