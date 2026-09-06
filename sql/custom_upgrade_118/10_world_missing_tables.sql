-- WORLD REVIEW REQUIRED. Missing tables only; no current data is overwritten.
-- Base definitions from upstream 6cdc923, adjusted to MySQL 5.6 utf8 naming.

CREATE TABLE IF NOT EXISTS `custom_merchant` (
  `id` int(10) unsigned NOT NULL DEFAULT 0,
  `entry` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `slot` smallint(5) unsigned NOT NULL DEFAULT 0,
  `item` mediumint(8) unsigned NOT NULL DEFAULT 0,
  `count` int(10) unsigned NOT NULL DEFAULT 1,
  `extendedcost` int(10) unsigned NOT NULL DEFAULT 0,
  `condition_id` mediumint(8) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `entry_slot` (`entry`,`slot`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED COMMENT='Npc System';

CREATE TABLE IF NOT EXISTS `itemextendedcost` (
  `id` int(10) unsigned NOT NULL DEFAULT 0,
  `costHonour` int(10) unsigned NOT NULL DEFAULT 0,
  `costArena` int(10) unsigned NOT NULL DEFAULT 0,
  `unknown1` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItem1` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItem2` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItem3` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItem4` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItem5` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItemCount1` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItemCount2` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItemCount3` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItemCount4` int(10) unsigned NOT NULL DEFAULT 0,
  `requiredItemCount5` int(10) unsigned NOT NULL DEFAULT 0,
  `personalRating` int(10) unsigned NOT NULL DEFAULT 0,
  `purchaseGroup` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `module_string` (
  `module` varchar(64) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `content_default` text NOT NULL,
  PRIMARY KEY (`module`,`id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `module_string_locale` (
  `module` varchar(64) NOT NULL,
  `id` int(10) unsigned NOT NULL,
  `locale` tinyint(3) unsigned NOT NULL,
  `content` text NOT NULL,
  PRIMARY KEY (`module`,`id`,`locale`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

CREATE TABLE IF NOT EXISTS `skill_race_class_info_mod` (
  `Id` int(10) unsigned NOT NULL DEFAULT 0,
  `SkillLineDbcRecord` int(11) NOT NULL DEFAULT -1,
  `RaceMask` int(11) NOT NULL DEFAULT -1,
  `ClassMask` int(11) NOT NULL DEFAULT -1,
  `Flags` int(11) NOT NULL DEFAULT -1,
  `MinLevel` int(11) NOT NULL DEFAULT -1,
  `SkillTierId` int(11) NOT NULL DEFAULT -1,
  `SkillCostIndex` int(11) NOT NULL DEFAULT -1,
  `Comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
