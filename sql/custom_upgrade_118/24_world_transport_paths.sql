-- WORLD ONLY. Align existing active transport taxi paths with installed 1.18.1 DBC.
-- Reviewed against final upstream world reference; preserve all other template fields.
-- Exact old-value guards: a different existing value is not overwritten.
UPDATE gameobject_template SET data0=72 WHERE entry=20808 AND type=15 AND data0=241; -- TEST Ship
UPDATE gameobject_template SET data0=121 WHERE entry=164871 AND type=15 AND data0=302; -- Zeppelin - Orgrimmar to Undercity
UPDATE gameobject_template SET data0=110 WHERE entry=175080 AND type=15 AND data0=285; -- Zeppelin - Grom'Gol-Orgrimar
UPDATE gameobject_template SET data0=116 WHERE entry=176231 AND type=15 AND data0=292; -- Proudmore's Treasure
UPDATE gameobject_template SET data0=117 WHERE entry=176244 AND type=15 AND data0=293; -- Moonspray
UPDATE gameobject_template SET data0=323 WHERE entry=176250 AND type=15 AND data0=1636; -- Windrunner
UPDATE gameobject_template SET data0=120 WHERE entry=176495 AND type=15 AND data0=301; -- Zeppelin - Grom'Gol to Undercity
UPDATE gameobject_template SET data0=122 WHERE entry=177233 AND type=15 AND data0=303; -- Feathermoon Ferry
UPDATE gameobject_template SET data0=294 WHERE entry=181646 AND type=15 AND data0=967; -- Ship - Auberdine to Stormwind
UPDATE gameobject_template SET data0=295 WHERE entry=190549 AND type=15 AND data0=1221; -- Zeppelin - Orgrimmar to Thunder Bluff
UPDATE gameobject_template SET data0=296 WHERE entry=190550 AND type=15 AND data0=1500; -- Ship - Sparkwater Port to Revantusk Village
UPDATE gameobject_template SET data0=297 WHERE entry=190552 AND type=15 AND data0=1501; -- Zeppelin - Orgrimmar to Kargath
