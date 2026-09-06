-- WORLD REVIEW REQUIRED. Adds two missing patch tables.
-- Spell extras are copied from CURRENT spell_template values, never upstream replacements.

CREATE TABLE IF NOT EXISTS `spell_extra` (
  `entry` int(10) unsigned NOT NULL DEFAULT 0,
  `effectBonusCoefficient1` float NOT NULL DEFAULT -1,
  `effectBonusCoefficient2` float NOT NULL DEFAULT -1,
  `effectBonusCoefficient3` float NOT NULL DEFAULT -1,
  `minTargetLevel` int(10) unsigned NOT NULL DEFAULT 0,
  `customFlags` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`entry`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=FIXED COMMENT='Server-only Spell.dbc fields';

CREATE TABLE IF NOT EXISTS `lft_user_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `creatorGuid` int unsigned NOT NULL,
  `creatorName` varchar(12) NOT NULL,
  `creatorClass` varchar(16) NOT NULL,
  `creatorLevel` tinyint unsigned NOT NULL DEFAULT 0,
  `team` smallint unsigned NOT NULL DEFAULT 0,
  `hardcore` tinyint unsigned NOT NULL DEFAULT 0,
  `category` tinyint unsigned NOT NULL DEFAULT 1,
  `title` varchar(128) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `tankLimit` tinyint unsigned NOT NULL DEFAULT 0,
  `healerLimit` tinyint unsigned NOT NULL DEFAULT 0,
  `damageLimit` tinyint unsigned NOT NULL DEFAULT 0,
  `tankCount` tinyint unsigned NOT NULL DEFAULT 0,
  `healerCount` tinyint unsigned NOT NULL DEFAULT 0,
  `damageCount` tinyint unsigned NOT NULL DEFAULT 0,
  `tankSignups` text NOT NULL,
  `healerSignups` text NOT NULL,
  `damageSignups` text NOT NULL,
  `createdAt` int unsigned NOT NULL DEFAULT 0,
  `updatedAt` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_lft_user_groups_creator` (`creatorGuid`),
  KEY `idx_lft_user_groups_browse` (`category`, `team`, `hardcore`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `spell_extra` (`entry`, `effectBonusCoefficient1`, `effectBonusCoefficient2`, `effectBonusCoefficient3`, `minTargetLevel`, `customFlags`)
SELECT s.`entry`, s.`effectBonusCoefficient1`, s.`effectBonusCoefficient2`, s.`effectBonusCoefficient3`, s.`minTargetLevel`, s.`customFlags`
FROM `spell_template` AS s
LEFT JOIN `spell_extra` AS e ON e.`entry` = s.`entry`
WHERE e.`entry` IS NULL;
