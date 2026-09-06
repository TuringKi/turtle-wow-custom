-- WORLD ONLY. Fill verified empty object/map script bindings.
UPDATE creature_template SET script_name='boss_zuluhed_the_whacked' WHERE entry=62037 AND (script_name='' OR script_name IS NULL);
UPDATE creature_template SET script_name='boss_bogpaw_truthsay' WHERE entry=62056 AND (script_name='' OR script_name IS NULL);
UPDATE creature_template SET script_name='boss_gowlfang' WHERE entry=62057 AND (script_name='' OR script_name IS NULL);
UPDATE gameobject_template SET script_name='go_warlock_demon_gate' WHERE entry=1000512 AND (script_name='' OR script_name IS NULL);
UPDATE gameobject_template SET script_name='go_stormwrought_secret_door' WHERE entry=2006138 AND (script_name='' OR script_name IS NULL);
UPDATE map_template SET script_name='instance_dragonmaw_retreat' WHERE entry=816 AND (script_name='' OR script_name IS NULL);
