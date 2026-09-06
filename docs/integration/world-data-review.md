# 世界库逐表审阅摘要

比较对象：现有世界库的只读副本，与 `sql/base` → `database_updates/world` → 根目录补丁的隔离候选结果。157 个候选补丁按此顺序试跑通过；若把两目录混排，已观察到训练师重复主键错误。

**尚未修改服务器。** 表格统计共同唯一键与共同字段；“候选独有键”不等于可以直接插入，关联键重排、掉落规则和中文定制仍需逐项处理。所有现有独有数据保留，migrations、player_census 等历史/运行数据不以候选快照覆盖。无共同唯一键的表须另外比较。

| 表 | 当前行数 | 候选行数 | 候选独有键 | 同键字段差异 | 当前独有键，保留 | 处理 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| `ai_playerbot_rpg_races` | 441 | 0 | 0 | 0 | 441 | 定制表整体保留 |
| `ai_playerbot_travelnode` | 2352 | 0 | 0 | 0 | 2352 | 定制表整体保留 |
| `ai_playerbot_travelnode_link` | 8856 | 0 | 0 | 0 | 8856 | 定制表整体保留 |
| `ai_playerbot_travelnode_path` | 603996 | 0 | 0 | 0 | 603996 | 定制表整体保留 |
| `area_template` | 1633 | 1481 | 123 | 12 | 275 | 需逐项审阅 |
| `areatrigger_tavern` | 56 | 65 | 9 | 0 | 0 | 需逐项审阅 |
| `areatrigger_teleport` | 133 | 148 | 15 | 0 | 0 | 需逐项审阅 |
| `areatrigger_template` | 466 | 517 | 51 | 0 | 0 | 需逐项审阅 |
| `auctionhousebot` | 5197 | 78 | — | — | — | 无共同唯一键 |
| `auctionhousebot2` | 78 | 0 | 0 | 0 | 78 | 定制表整体保留 |
| `autobroadcast` | 7 | 1 | — | — | — | 无共同唯一键 |
| `battleground_template` | 5 | 5 | 0 | 4 | 0 | 需逐项审阅 |
| `bot_smart_script` | 583 | 0 | 0 | 0 | 583 | 定制表整体保留 |
| `bottalktext` | 2690 | 0 | 0 | 0 | 2690 | 定制表整体保留 |
| `broadcast_text` | 13665 | 14162 | 497 | 2 | 0 | 需逐项审阅 |
| `cartographer` | 837 | 756 | 207 | 0 | 288 | 需逐项审阅 |
| `collection_mount` | 203 | 418 | 215 | 0 | 0 | 需逐项审阅 |
| `collection_pet` | 173 | 232 | 59 | 0 | 0 | 需逐项审阅 |
| `collection_toy` | 71 | 75 | 4 | 0 | 0 | 需逐项审阅 |
| `conditions` | 1476 | 1494 | 18 | 0 | 0 | 需逐项审阅 |
| `creature` | 79780 | 88842 | 9265 | 246 | 203 | 需逐项审阅 |
| `creature_addon` | 7797 | 8505 | 712 | 0 | 4 | 需逐项审阅 |
| `creature_ai_events` | 5957 | 6086 | 129 | 0 | 0 | 需逐项审阅 |
| `creature_ai_scripts` | 6994 | 7120 | — | — | — | 无共同唯一键 |
| `creature_display_info_addon` | 12381 | 13025 | 646 | 0 | 2 | 需逐项审阅 |
| `creature_equip_template` | 5532 | 5990 | 458 | 3 | 0 | 需逐项审阅 |
| `creature_involvedrelation` | 5706 | 6336 | 672 | 0 | 42 | 需逐项审阅 |
| `creature_linking` | 568 | 614 | 46 | 0 | 0 | 需逐项审阅 |
| `creature_loot_template` | 312884 | 427660 | 232163 | 9739 | 117387 | 需逐项审阅 |
| `creature_movement` | 69385 | 82605 | 13303 | 0 | 83 | 需逐项审阅 |
| `creature_movement_scripts` | 1323 | 1323 | — | — | — | 无共同唯一键 |
| `creature_questrelation` | 5499 | 6098 | 638 | 0 | 39 | 需逐项审阅 |
| `creature_spells` | 2648 | 2988 | 340 | 5 | 0 | 需逐项审阅 |
| `creature_spells_scripts` | 18 | 18 | — | — | — | 无共同唯一键 |
| `creature_template` | 12751 | 14339 | 1588 | 12160 | 0 | 需逐项审阅 |
| `creature_template_npcbot_wander_nodes` | 5039 | 0 | 0 | 0 | 5039 | 定制表整体保留 |
| `custom_merchant` | 0 | 564 | 564 | 0 | 0 | 候选新表 |
| `daily_quest_timer` | 1 | 1 | — | — | — | 无共同唯一键 |
| `event_scripts` | 290 | 290 | — | — | — | 无共同唯一键 |
| `faction` | 202 | 204 | 2 | 0 | 0 | 需逐项审阅 |
| `faction_template` | 332 | 334 | 2 | 8 | 0 | 需逐项审阅 |
| `game_event` | 97 | 97 | 0 | 31 | 0 | 需逐项审阅 |
| `game_graveyard_zone` | 214 | 283 | 273 | 0 | 204 | 需逐项审阅 |
| `game_tele` | 641 | 647 | 7 | 0 | 1 | 需逐项审阅 |
| `gameobject` | 60171 | 66142 | 6223 | 24 | 252 | 需逐项审阅 |
| `gameobject_involvedrelation` | 248 | 265 | 18 | 0 | 1 | 需逐项审阅 |
| `gameobject_loot_template` | 13539 | 10210 | 9938 | 35 | 13267 | 需逐项审阅 |
| `gameobject_questrelation` | 296 | 319 | 24 | 0 | 1 | 需逐项审阅 |
| `gameobject_scripts` | 95 | 95 | — | — | — | 无共同唯一键 |
| `gameobject_template` | 20833 | 21196 | 363 | 917 | 0 | 需逐项审阅 |
| `generic_scripts` | 1975 | 1975 | — | — | — | 无共同唯一键 |
| `gossip_menu` | 4793 | 5173 | 380 | 0 | 0 | 需逐项审阅 |
| `gossip_menu_option` | 2626 | 2773 | 147 | 0 | 0 | 需逐项审阅 |
| `gossip_scripts` | 478 | 494 | — | — | — | 无共同唯一键 |
| `item_display_info` | 29604 | 45462 | — | — | — | 无共同唯一键 |
| `item_loot_template` | 3053 | 6205 | 3283 | 1155 | 131 | 需逐项审阅 |
| `item_template` | 21838 | 26544 | 4706 | 19310 | 0 | 需逐项审阅 |
| `itemextendedcost` | 0 | 549 | 549 | 0 | 0 | 候选新表 |
| `lft_user_groups` | 0 | 0 | 0 | 0 | 0 | 候选新表 |
| `locales_area` | 1633 | 1481 | 123 | 1242 | 275 | 需逐项审阅 |
| `mangos_string` | 977 | 976 | 1 | 0 | 2 | 需逐项审阅 |
| `map_template` | 65 | 70 | 5 | 4 | 0 | 需逐项审阅 |
| `migrations` | 634 | 0 | 0 | 0 | 634 | 需逐项审阅 |
| `miraclerace_checkpoint` | 28 | 28 | — | — | — | 无共同唯一键 |
| `miraclerace_creaturespool` | 84 | 84 | — | — | — | 无共同唯一键 |
| `miraclerace_gameobject` | 21 | 21 | — | — | — | 无共同唯一键 |
| `module_string` | 0 | 0 | 0 | 0 | 0 | 候选新表 |
| `module_string_locale` | 0 | 0 | 0 | 0 | 0 | 候选新表 |
| `npc_text` | 4284 | 4661 | 377 | 0 | 0 | 需逐项审阅 |
| `npc_trainer` | 34295 | 38038 | 5654 | 3945 | 1911 | 需逐项审阅 |
| `npc_vendor` | 17878 | 12713 | 1904 | 43 | 7069 | 需逐项审阅 |
| `npc_vendor_template` | 413 | 2353 | 2161 | 0 | 221 | 需逐项审阅 |
| `object_scaling` | 3992 | 4297 | 305 | 0 | 0 | 需逐项审阅 |
| `page_text` | 1556 | 1767 | 211 | 17 | 0 | 需逐项审阅 |
| `pickpocketing_loot_template` | 7077 | 6941 | 347 | 0 | 483 | 需逐项审阅 |
| `player_census` | 18228 | 10524 | 0 | 845 | 7704 | 需逐项审阅 |
| `player_levelstats` | 3420 | 3540 | 120 | 0 | 0 | 需逐项审阅 |
| `player_premade_item` | 4908 | 0 | 0 | 0 | 4908 | 定制表整体保留 |
| `player_premade_item_template` | 356 | 0 | 0 | 0 | 356 | 定制表整体保留 |
| `player_premade_spell` | 9992 | 0 | 0 | 0 | 9992 | 定制表整体保留 |
| `player_premade_spell_template` | 252 | 0 | 0 | 0 | 252 | 定制表整体保留 |
| `playerbot_names` | 16389 | 0 | 0 | 0 | 16389 | 定制表整体保留 |
| `playercreateinfo` | 57 | 59 | 2 | 0 | 0 | 需逐项审阅 |
| `playercreateinfo_action` | 303 | 316 | 13 | 0 | 0 | 需逐项审阅 |
| `playercreateinfo_item` | 433 | 448 | — | — | — | 无共同唯一键 |
| `playercreateinfo_spell` | 2126 | 2191 | 89 | 4 | 24 | 需逐项审阅 |
| `points_of_interest` | 275 | 286 | 11 | 0 | 0 | 需逐项审阅 |
| `pool_gameobject` | 17829 | 21743 | 3914 | 0 | 0 | 需逐项审阅 |
| `pool_template` | 1680 | 1777 | 97 | 0 | 0 | 需逐项审阅 |
| `quest_end_scripts` | 1321 | 1321 | — | — | — | 无共同唯一键 |
| `quest_start_scripts` | 500 | 500 | — | — | — | 无共同唯一键 |
| `quest_template` | 5989 | 6708 | 719 | 4550 | 0 | 需逐项审阅 |
| `reference_loot_template` | 9808 | 59119 | 57938 | 0 | 8627 | 需逐项审阅 |
| `script_texts` | 1112 | 1194 | 82 | 0 | 0 | 需逐项审阅 |
| `skill_line_ability` | 6247 | 6770 | 5096 | 1674 | 4573 | 需逐项审阅 |
| `skill_race_class_info_mod` | 0 | 1 | 1 | 0 | 0 | 候选新表 |
| `skinning_loot_template` | 2959 | 2921 | 261 | 2233 | 299 | 需逐项审阅 |
| `sound_entries` | 8461 | 8559 | 98 | 0 | 0 | 需逐项审阅 |
| `spell_affect` | 276 | 253 | 156 | 14 | 179 | 需逐项审阅 |
| `spell_chain` | 1108 | 1148 | 41 | 1 | 1 | 需逐项审阅 |
| `spell_disabled` | 78 | 76 | 0 | 0 | 2 | 需逐项审阅 |
| `spell_effect_mod` | 364 | 330 | 4 | 0 | 38 | 需逐项审阅 |
| `spell_extra` | 0 | 27917 | 27917 | 0 | 0 | 候选新表 |
| `spell_group` | 390 | 396 | 15 | 0 | 9 | 需逐项审阅 |
| `spell_learn_spell` | 5 | 56 | 51 | 0 | 0 | 需逐项审阅 |
| `spell_mod` | 584 | 575 | 15 | 0 | 24 | 需逐项审阅 |
| `spell_pet_auras` | 23 | 28 | 5 | 0 | 0 | 需逐项审阅 |
| `spell_proc_event` | 201 | 276 | 84 | 9 | 9 | 需逐项审阅 |
| `spell_scripts` | 29 | 39 | — | — | — | 无共同唯一键 |
| `spell_template` | 24879 | 27923 | 3058 | 4522 | 14 | 需逐项审阅 |
| `spell_threat` | 118 | 122 | 5 | 9 | 1 | 需逐项审阅 |
| `taxi_nodes` | 109 | 124 | 38 | 5 | 23 | 需逐项审阅 |
| `taxi_path_transitions` | 372 | 372 | 372 | 0 | 372 | 需逐项审阅 |
| `transports` | 12 | 13 | 1 | 0 | 0 | 需逐项审阅 |
| `world_safe_locs_facing` | 112 | 112 | 89 | 17 | 89 | 需逐项审阅 |

## 同键记录的字段差异

以下数量是各字段存在差异的行数，不能相加当作记录总数。差异可能是上游新增内容、旧服定制、翻译或运行数据；未经审阅不覆盖。

| 表 | 字段与差异行数 |
| --- | --- |
| `area_template` | `name` 7, `map_id` 3, `zone_id` 2, `explore_flag` 2 |
| `battleground_template` | `horde_start_location` 4, `alliance_start_location` 4, `min_players_per_team` 3 |
| `broadcast_text` | `sound_id` 2, `chat_type` 2 |
| `creature` | `spawntimesecsmax` 170, `spawntimesecsmin` 170, `position_z` 67, `position_x` 65, `orientation` 65, `id2` 64, `position_y` 64, `wander_distance` 52, `movement_type` 47, `id` 46, `id3` 32, `mana_percent` 26, `spawn_flags` 2 |
| `creature_equip_template` | `equipentry1` 2, `equipentry3` 1 |
| `creature_loot_template` | `ChanceOrQuestChance` 9739 |
| `creature_spells` | `castFlags_2` 4, `castFlags_1` 1 |
| `creature_template` | `health_max` 11680, `health_min` 11680, `dmg_max` 11462, `dmg_min` 11460, `ranged_dmg_max` 10949, `ranged_dmg_min` 10860, `subname` 7130, `loot_id` 714, `vendor_id` 571, `faction` 258, `pickpocket_loot_id` 184, `skinning_loot_id` 131, `armor` 117, `pet_spell_list_id` 96, `level_min` 66, `display_id1` 63, `type_flags` 59, `level_max` 57, `name` 47, `npc_flags` 45, `beast_family` 36, `equipment_id` 36, `scale` 35, `unit_flags` 29, `mana_min` 22, `attack_power` 22, `mana_max` 20, `dynamic_flags` 19, `type` 17, `spell_list_id` 17, `ai_name` 16, `rank` 14, `fire_res` 12, `frost_res` 11, `flags_extra` 11, `gossip_menu_id` 10, `ranged_attack_time` 8, `arcane_res` 6, `trainer_type` 6, `auras` 5, `script_name` 5, `base_attack_time` 5, `speed_walk` 4, `gold_max` 3, `shadow_res` 3, `detection_range` 3, `civilian` 2, `gold_min` 2, `nature_res` 2, `unit_class` 2, `display_id2` 2, `display_id3` 2, `movement_type` 2, `trainer_class` 2, `ranged_attack_power` 2, `mechanic_immune_mask` 2, `speed_run` 1, `spell_id1` 1, `spell_id2` 1, `spell_id3` 1, `spell_id4` 1, `dmg_school` 1, `display_id4` 1, `leash_range` 1, `racial_leader` 1, `school_immune_mask` 1 |
| `faction_template` | `faction_id` 6, `faction_flags` 2, `friend_faction1` 2, `our_mask` 1, `hostile_mask` 1, `friendly_mask` 1, `enemy_faction1` 1, `enemy_faction2` 1, `friend_faction2` 1 |
| `game_event` | `start_time` 28, `end_time` 11, `disabled` 2 |
| `gameobject` | `spawntimesecsmax` 11, `spawntimesecsmin` 11, `position_z` 10, `position_y` 4, `position_x` 3, `spawn_flags` 2, `visibility_mod` 2 |
| `gameobject_loot_template` | `groupid` 31, `ChanceOrQuestChance` 12 |
| `gameobject_template` | `data1` 667, `data15` 586, `name` 30, `data0` 19, `data4` 18, `type` 4, `data2` 3, `flags` 2, `script_name` 2, `size` 1, `data5` 1, `data6` 1, `faction` 1, `displayId` 1 |
| `item_loot_template` | `ChanceOrQuestChance` 1063, `groupid` 116, `maxcount` 2, `mincountOrRef` 2 |
| `item_template` | `spellcooldown_5` 14431, `spellcategorycooldown_5` 14114, `spellcooldown_1` 5879, `spellcategorycooldown_1` 5827, `script_name` 2426, `spellcooldown_2` 1834, `spellcategorycooldown_2` 1830, `disenchant_id` 1449, `name` 918, `spellcooldown_3` 626, `spellcategorycooldown_3` 622, `display_id` 403, `spellcooldown_4` 297, `spellcategorycooldown_4` 297, `description` 262, `required_honor_rank` 258, `subclass` 249, `spellid_1` 242, `bag_family` 242, `item_level` 210, `max_count` 199, `stat_value1` 183, `armor` 174, `required_reputation_rank` 174, `stat_value2` 126, `sell_price` 125, `spellid_2` 122, `max_durability` 122, `class` 113, `spelltrigger_2` 106, `dmg_min1` 91, `dmg_max1` 90, `required_level` 86, `spellcategory_1` 82, `buy_price` 81, `spelltrigger_1` 66, `quality` 59, `spelltrigger_3` 49, `stat_value3` 47, `stackable` 44, `spellid_3` 43, `inventory_type` 40, `sheath` 39, `bonding` 39, `stat_type2` 36, `spellcharges_1` 33, `required_reputation_faction` 32, `material` 26, `map_bound` 25, `area_bound` 25, `stat_type1` 25, `delay` 21, `flags` 21, `stat_type3` 21, `buy_count` 13, `nature_res` 12, `start_quest` 11, `set_id` 9, `spelltrigger_4` 9, `allowable_race` 8, `spellcategory_2` 7, `fire_res` 6, `spellid_4` 6, `arcane_res` 6, `spellcharges_2` 6, `ammo_type` 5, `allowable_class` 5, `container_slots` 5, `spellppmrate_1` 4, `block` 3, `dmg_type1` 2, `shadow_res` 2, `stat_type4` 2, `stat_value4` 2, `required_skill` 2, `required_skill_rank` 2, `dmg_max2` 1, `dmg_min2` 1, `dmg_type2` 1, `frost_res` 1, `spellid_5` 1, `spellppmrate_2` 1, `spellppmrate_3` 1, `spelltrigger_5` 1, `spellcategory_3` 1 |
| `locales_area` | `NameLoc2` 1226, `NameLoc8` 583, `NameLoc4` 62, `NameLoc0` 7, `NameLoc1` 1, `NameLoc3` 1 |
| `map_template` | `map_name` 4, `map_type` 1, `linked_zone` 1, `script_name` 1, `player_limit` 1, `ghost_entrance_x` 1, `ghost_entrance_y` 1, `ghost_entrance_map` 1 |
| `npc_trainer` | `spellcost` 3036, `reqlevel` 1542 |
| `npc_vendor` | `slot` 31, `incrtime` 10, `maxcount` 10, `condition_id` 2 |
| `page_text` | `text` 17 |
| `player_census` | `date_time` 845, `total_players` 275, `horde_players` 242, `alliance_players` 148 |
| `playercreateinfo_spell` | `note` 4 |
| `quest_template` | `ReqSourceId1` 2025, `ReqSourceCount1` 2025, `EndText` 1764, `ObjectiveText4` 1593, `ObjectiveText3` 1592, `ObjectiveText2` 1587, `OfferRewardText` 1207, `RequestItemsText` 1112, `Details` 394, `ReqSourceId2` 340, `ReqSourceCount2` 340, `ObjectiveText1` 329, `Objectives` 271, `ReqSourceId3` 208, `ReqSourceCount3` 208, `RewRepValue2` 119, `ReqSourceId4` 111, `ReqSourceCount4` 111, `RewMoneyMaxLevel` 103, `RewItemCount1` 100, `RewChoiceItemCount1` 100, `RewItemId1` 98, `RewChoiceItemCount2` 95, `RewChoiceItemId1` 90, `RewChoiceItemId2` 89, `RewRepValue1` 78, `SpecialFlags` 75, `RewChoiceItemId3` 61, `RewChoiceItemCount3` 61, `Title` 57, `RewRepFaction1` 52, `RewOrReqMoney` 33, `QuestFlags` 32, `RewRepFaction2` 25, `Method` 17, `MinLevel` 16, `RequiredRaces` 16, `RewRepFaction3` 14, `ReqItemId1` 13, `RewRepValue3` 13, `ZoneOrSort` 11, `Type` 10, `SrcItemId` 10, `RewSpell` 9, `ReqCreatureOrGOId1` 9, `ReqCreatureOrGOCount1` 9, `RewRepValue5` 7, `RewRepFaction4` 7, `RewRepFaction5` 7, `SrcItemCount` 6, `QuestLevel` 5, `ReqItemCount1` 5, `RewXP` 4, `RewItemId2` 4, `ReqCreatureOrGOId3` 4, `ReqItemId4` 3, `PrevQuestId` 3, `ReqItemCount4` 3, `RewItemCount2` 3, `ReqCreatureOrGOId2` 3, `ReqCreatureOrGOId4` 3, `ReqItemId3` 2, `StartScript` 2, `CompleteScript` 2, `ReqCreatureOrGOCount3` 2, `RewItemId3` 1, `NextQuestId` 1, `ReqItemCount3` 1, `RewItemCount3` 1, `ExclusiveGroup` 1, `RequiredClasses` 1, `NextQuestInChain` 1, `RewChoiceItemId4` 1, `RewChoiceItemCount4` 1, `ReqCreatureOrGOCount2` 1, `ReqCreatureOrGOCount4` 1 |
| `skill_line_ability` | `spell_id` 1673, `skill_id` 1663, `class_mask` 1089, `max_value` 942, `min_value` 942, `req_skill_value` 379, `superseded_by_spell` 361, `learn_on_get_skill` 180, `req_train_points` 83, `race_mask` 40 |
| `skinning_loot_template` | `ChanceOrQuestChance` 2156, `maxcount` 537, `mincountOrRef` 22, `groupid` 9 |
| `spell_affect` | `SpellFamilyMask` 14 |
| `spell_chain` | `rank` 1, `prev_spell` 1, `first_spell` 1 |
| `spell_proc_event` | `Cooldown` 4, `procFlags` 2, `procEx` 1, `ppmRate` 1, `SpellFamilyName` 1, `SpellFamilyMask0` 1, `SpellFamilyMask1` 1, `SpellFamilyMask2` 1 |
| `spell_template` | `description` 1265, `effectBonusCoefficient1` 947, `auraDescription` 727, `effectBasePoints1` 695, `effectBasePoints2` 459, `name` 436, `effect2` 379, `effectImplicitTargetA2` 367, `effectDieSides2` 337, `effectApplyAuraName2` 336, `effectBaseDice2` 329, `effectItemType1` 326, `spellFamilyFlags` 280, `attributes` 254, `manaCost` 250, `customFlags` 228, `effectApplyAuraName1` 226, `effectMiscValue1` 224, `effectMiscValue2` 201, `effect1` 192, `durationIndex` 188, `spellFamilyName` 186, `spellIconId` 162, `spellVisual1` 160, `attributesEx3` 149, `effectItemType2` 149, `effect3` 148, `dmgMultiplier2` 148, `effectImplicitTargetA3` 144, `effectBasePoints3` 141, `dmgMultiplier3` 138, `castingTimeIndex` 136, `attributesEx` 135, `effectRadiusIndex1` 135, `effectDieSides3` 134, `effectBaseDice3` 130, `attributesEx2` 127, `categoryRecoveryTime` 126, `effectApplyAuraName3` 126, `effectBonusCoefficient2` 120, `baseLevel` 109, `procFlags` 104, `auraDescriptionFlags` 104, `nameSubtext` 101, `startRecoveryTime` 101, `interruptFlags` 100, `nameSubtextFlags` 100, `rangeIndex` 99, `descriptionFlags` 98, `nameFlags` 94, `effectDieSides1` 94, `procChance` 93, `effectImplicitTargetA1` 82, `effectMiscValue3` 80, `spellLevel` 78, `effectTriggerSpell1` 74, `recoveryTime` 72, `effectRadiusIndex2` 71, `category` 70, `effectTriggerSpell2` 57, `effectItemType3` 56, `attributesEx4` 48, `effectAmplitude2` 47, `effectBaseDice1` 46, `effectAmplitude1` 45, `procCharges` 43, `dmgClass` 42, `effectTriggerSpell3` 37, `startRecoveryCategory` 36, `preventionType` 32, `equippedItemSubClassMask` 30, `effectImplicitTargetB1` 28, `effectImplicitTargetB2` 28, `dispel` 27, `stancesNot` 27, `stances` 25, `effectRadiusIndex3` 24, `stanceBarOrder` 21, `effectBonusCoefficient3` 21, `auraInterruptFlags` 20, `stackAmount` 19, `mechanic` 18, `effectAmplitude3` 18, `effectRealPointsPerLevel1` 16, `school` 15, `effectMultipleValue1` 15, `manaCostPercentage` 14, `requiresSpellFocus` 14, `manaPerSecond` 13, `maxLevel` 12, `dmgMultiplier1` 12, `targets` 10, `channelInterruptFlags` 10, `reagent1` 9, `reagentCount1` 9, `equippedItemClass` 9, `effectMechanic1` 8, `effectMechanic2` 8, `speed` 7, `reagentCount2` 7, `maxTargetLevel` 7, `effectImplicitTargetB3` 6, `effectRealPointsPerLevel2` 6, `totem1` 5, `powerType` 5, `reagent2` 4, `casterAuraState` 4, `targetCreatureType` 4, `effectMultipleValue3` 4, `reagent3` 3, `reagentCount3` 3, `spellPriority` 3, `effectMultipleValue2` 3, `totem2` 2, `reagent4` 2, `activeIconId` 2, `reagentCount4` 2, `manCostPerLevel` 2, `effectChainTarget3` 2, `effectDicePerLevel1` 2, `effectPointsPerComboPoint2` 2, `castUI` 1, `reagent5` 1, `reagentCount5` 1, `reagentCount6` 1, `effectChainTarget1` 1, `effectRealPointsPerLevel3` 1, `effectPointsPerComboPoint1` 1 |
| `spell_threat` | `multiplier` 9 |
| `taxi_nodes` | `mount_creature_id1` 3, `mount_creature_id2` 3, `name` 2 |
| `world_safe_locs_facing` | `orientation` 17 |
