# 909702 盾击脚本的可选目标

报错 `FindScriptTargets: Failed to find target ... id 909702 ... target_type: 5` 来自裂盾军团战士（creature 9097）的盾击（spell 11972）。正式库与上游基础脚本的配置一致，不是未导入的 DBC 或缺失生物 GUID。

`ScriptMgr.h` 将目标类型 5 定义为 `TARGET_T_HOSTILE_RANDOM_NOT_TOP`；`GetTargetByType` 调用 `SelectAttackingTarget(ATTACKING_TARGET_RANDOM, 1, ...)`，跳过第一仇恨。参数 0 表示默认选择规则，不是要查找编号为 0 的生物。只有一个有效目标，或其余候选不符合条件时，查找失败是允许出现的情况。

事件 909702 在当前敌人距其 0–5 码时触发，重试周期为 14–20 秒。它没有保证另一个仇恨目标一定存在。核心在未找到目标时已经安全返回，日志本身不是空指针崩溃的证据。

已执行 [25_world_optional_shield_bash_target.sql](../../sql/custom_upgrade_118/25_world_optional_shield_bash_target.sql)：只将 `creature_ai_scripts` 的该行 `data_flags` 从 8 改为 24，保留 `SF_GENERAL_ABORT_ON_FAILURE`，增加 `SF_GENERAL_SKIP_MISSING_TARGETS`。有合适目标时仍按原规则尝试盾击；没有时跳过，不再将这种情况打印为错误。没有将目标改为坦克，也没有改法术、事件、冷却或全局日志设置。

正式 MySQL 5.6 执行前保存目标行 SQL；执行后核对只改变这一处标志，其他行及目标行其他字段指纹一致，重复执行校验通过。备份和结果在本机 `/root/turtle-wow-startup-check/shield-bash-909702/`。账号与角色数据库没有写入。

世界服重启后加载；也可以由管理员执行 `.reload creature_ai_events`，该命令会一起重新加载脚本和事件（`HandleReloadEventAIEventsCommand`）。本轮还部署了运输程序和路径修复，因此整体仍建议重启世界服。未自动重启正式服，尚未做真实战斗复测。
