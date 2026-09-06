-- WORLD ONLY. Replace obsolete spawn-location references absent from 1.18.1 WorldSafeLocs.dbc.
-- Preserve custom population, level and reward settings.
UPDATE battleground_template SET alliance_start_location=97,horde_start_location=98 WHERE id=2 AND alliance_start_location=769 AND horde_start_location=770;
UPDATE battleground_template SET alliance_start_location=77,horde_start_location=76 WHERE id=1 AND alliance_start_location=611 AND horde_start_location=610;
UPDATE battleground_template SET alliance_start_location=114,horde_start_location=113 WHERE id=3 AND alliance_start_location=890 AND horde_start_location=889;
UPDATE battleground_template SET alliance_start_location=130,horde_start_location=131 WHERE id=5 AND alliance_start_location=700 AND horde_start_location=701;
