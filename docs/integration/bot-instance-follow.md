# Bot dungeon entry and summon recovery — 2026-09-06

Reported behavior: bots created by `.rndbot group` remain displayed at the dungeon entrance, are absent inside, and `.bot summon *` reports `Bot is offline`.

## Findings and changes

- The default `ObjectMgr::GetPlayer` lookup excludes players temporarily removed from the world during a far teleport. Summon/recall/come now also consult bot holders and the unfiltered player registry. A real session undergoing transfer is no longer automatically classified as offline.
- Summon verifies session and AI ownership, completes a pending transfer through the existing bot ACK handler, and only then requests another teleport. It distinguishes unfinished transfer, missing world state, and a rejected teleport. Account/control, combat, battleground, and cross-instance restrictions remain enforced.
- Bot portal detection used a 0.5-yard tolerance; the core handler uses 5 yards. Both bot detection and action execution now use the core geometry helper and tolerance. The normal area-trigger handler still enforces instance entry requirements.
- Portal movement now explicitly requests running with pathfinding. Its duration uses the actual distance instead of taking the square root twice. Pending entry is retained while the bot is still approaching; module suppression still clears it.

A map marker and the saved database map/online fields do not establish the bot's live map, instance, or teleport state. These are confirmed code defects consistent with the symptoms, not an end-to-end reproduction of the user's dungeon failure.

## Validation

- Release build with modern playerbots and Eluna: passed.
- `python3 tests/playerbots/test_summon_states.py`: 13 cases passed. It compiles the production summon handler against stateful doubles and checks transfer recovery and restrictions. It does not exercise real networking, map admission, or portal navigation.
- Isolated startup against local test databases: world ready, hearthstone Lua loaded, no selected SQL/assertion/Eluna errors; clean shutdown (exit 0). Production was not used for this startup test.
- Installed executable SHA-256: `f65ac94bbdfd092800bca6d2496974076dcf3001c37fc0a96c2cebcb677aef54`. Previous executable retained in `/root/turtle-wow-startup-check/bot-instance-follow/mangosd-before`. The existing world process was not restarted.

## Deployment and client verification

The replacement executable belongs in `/root/turtle-wow-custom/.install/libexec/mangosd`. No account, character, or world database migration is required for this change. No configuration or DBC replacement is required.

The running world process must be restarted to load the new executable. After restart, create/rejoin a bot group, approach the entrance together, and enter the dungeon. Verify the bots appear inside the same instance, rather than relying on map markers. If entry still fails, run `.bot summon *` inside and record the exact response and dungeon name. Check leaving and re-entering as well. Actual client verification remains outstanding.
