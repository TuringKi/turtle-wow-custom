-- Restore the transmog dialogue used with the 1.18.1 client.
-- Source: sql/database_updates/world/20260711170358_world.sql
-- Reviewed and applied on 2026-09-06; retained here as the exact execution SQL.
-- WORLD database only. No account or character database operations.
-- One-time migration: do not re-run on the already updated installation.
-- Before applying elsewhere, verify broadcast_text.entry=900000,
-- npc_text.ID=900000 and gossip_menu.entry=64999 are absent, and both
-- creature_template entries 51290/51291 exist with gossip_menu_id=0.
-- Save the affected rows first; MyISAM tables do not support rollback.
-- Stop on SQL errors; never use mysql --force.

START TRANSACTION;
INSERT INTO `broadcast_text`
(
    `entry`,
    `male_text`,
    `female_text`,
    `chat_type`,
    `sound_id`,
    `language_id`,
    `emote_id1`,
    `emote_id2`,
    `emote_id3`,
    `emote_delay1`,
    `emote_delay2`,
    `emote_delay3`
)
VALUES
(900000, 'TRANSMOG_TRIGGER', 'TRANSMOG_TRIGGER', 0, 0, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO `gossip_menu`
(
    `entry`,
    `text_id`,
    `script_id`,
    `condition_id`
)
VALUES
(64999, 900000, 0, 0);
INSERT INTO `npc_text`
(
    `ID`,
    `BroadcastTextID0`,
    `Probability0`,
    `BroadcastTextID1`,
    `Probability1`,
    `BroadcastTextID2`,
    `Probability2`,
    `BroadcastTextID3`,
    `Probability3`,
    `BroadcastTextID4`,
    `Probability4`,
    `BroadcastTextID5`,
    `Probability5`,
    `BroadcastTextID6`,
    `Probability6`,
    `BroadcastTextID7`,
    `Probability7`
)
VALUES
(900000, 900000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
UPDATE creature_template SET gossip_menu_id=64999 WHERE entry IN (51290,51291) AND gossip_menu_id=0;
SELECT ROW_COUNT() AS npc_rows_updated;
COMMIT;
