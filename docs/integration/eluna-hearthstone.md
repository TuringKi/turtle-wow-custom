# 现有炉石的 Eluna 传送菜单

`lua_scripts/hearthstone_teleporter.lua` 绑定现有炉石 6948，无需 SQL、物品模板修改或客户端补丁。右键打开菜单，显示本阵营的三座经典主城、“返回绑定旅店”和三组副本入口菜单。主城传送免费、即时；旅店入口使用原法术 8690，非触发施法并传入炉石物品，交由核心处理读条和物品冷却，不重置冷却。

主城坐标来自当前世界库的 `game_tele`，并非自定义种族新增主城。死亡、战斗、飞行、战场、施法时禁止使用；选择菜单时再次检查。菜单有效期 120 秒，只接受当前炉石对应的选择，拒绝跨阵营目标和重复请求，退出登录清理菜单状态。

## 副本入口

已增加 22 个入口，坐标逐项匹配当前世界库 `game_tele`，仅使用野外地图 0、1。数据库中另有同名的副本内部坐标，未使用。最低等级取当前 `areatrigger_teleport` 的入口要求，菜单显示并在点击时验证；这是最低入场等级，不是建议挑战等级。

| 分组 | 入口 |
| --- | --- |
| 低等级 | 怒焰裂谷、死亡矿井、哀嚎洞穴、影牙城堡、黑暗深渊、暴风城监狱、诺莫瑞根、剃刀沼泽、血色修道院公共入口 |
| 中等级 | 剃刀高地、奥达曼、祖尔法拉克、玛拉顿橙色/紫色入口、沉没的神庙 |
| 高等级 | 黑石深渊、黑石塔公共入口、厄运东/西/北、斯坦索姆、通灵学院 |

怒焰裂谷仅部落可见，暴风城监狱仅联盟可见；其他入口双方可用。选择分组后可返回主菜单。服务器只接受当前显示菜单中的选项，并重复验证等级、阵营和使用状态。

只传送使用者到外部入口附近，之后自行进本；钥匙、任务、队伍等进入条件继续由核心检查。副本门外机器人掉队时可另用 `.bot summon *` 召集。没有自动带机器人传送或新增团队副本、海龟自定义副本入口。

新增测试已覆盖全部 22 个目的地的菜单可达性、仅使用外部地图、跨页伪造选项、最低等级边界及进入子菜单后战斗状态变化。真实地形落点和客户端子菜单仍需游戏内确认。升级前安装脚本备份位于 `/root/turtle-wow-startup-check/hearthstone-backups/`，避免备份 Lua 被 Eluna 重复加载。

## 安装与使用

当前构建 `BUILD_ELUNA=ON`，使用 Lua 5.2。物品使用、物品 gossip 选择均已在核心接入。本次已将脚本安装到：

```text
/root/turtle-wow-custom/.install/lua_scripts/hearthstone_teleporter.lua
```

`.install/etc/mangosd.conf` 已设置以下两项，修改前已在同目录保存带日期的配置备份：

```ini
Eluna.Enabled = 1
Eluna.ScriptPath = "/root/turtle-wow-custom/.install/lua_scripts"
```

首次部署请重启世界服，让配置和脚本一起加载；日志应出现 `[HearthstoneTeleporter] Loaded`。之后只修改 Lua 时，管理员可使用 `.reload eluna` 重新加载（会重新加载其他 Eluna 脚本）。无需重启登录服、重新编译或执行数据库升级。

重启后右键背包中的炉石测试：本阵营三个主城逐个传送；选择旅店确认读条、返回绑定点和冷却；战斗时确认拒绝。原炉石冷却保留，因此客户端若在物品冷却期间不发送使用请求，菜单也可能无法打开；本实现不改客户端、不清除炉石冷却。普通炉石提示文字仍由现有物品数据提供。

## 验证范围

使用构建中相同的 Lua 5.2 库运行 `tests/eluna/hearthstone_teleporter_test.lua`，通过阵营菜单、状态变化、伪造目标、物品不匹配、重复及超时选择、退出清理、旅店冷却、传送失败测试。测试以模拟 Eluna 对象检查脚本行为，未连接正式数据库或启动正式世界服；客户端实际菜单、读条冷却和地图落点仍待实测。

仓库根目录运行：

```sh
lua5.2 tests/eluna/hearthstone_teleporter_test.lua
```

本机没有系统 Lua 命令，验证时从现有构建的 Lua 5.2 源码及静态库生成临时解释器 `/root/turtle-wow-startup-check/lua52`。测试文件位于脚本加载目录之外。

## 参考与适配

- [Eluna-VMaNGOS](https://github.com/Eluna-Ports/Eluna-VMaNGOS)：Eluna 集成及 ScriptPath 加载方式。
- [RegisterItemGossipEvent](https://elunaluaengine.github.io/Global/RegisterItemGossipEvent.html)：绑定物品菜单，hello 返回 false 阻止默认使用法术。
- [Teleport](https://elunaluaengine.github.io/Player/Teleport.html)：传送 API；本仓库 VMaNGOS 适配实际返回布尔值，以本地实现为准。
- [社区超级炉石示例](https://github.com/najoast/eluna_scripts/blob/master/src/super_hearthstone.lua)：参考物品菜单组织方式；本脚本独立编写，仅使用当前核心已有接口。

## 当前进程加载记录

2026-09-06 14:55 重载仍使用启动时读取的相对路径 `lua_scripts`，加载 0 个脚本。已建立 `.install/bin/lua_scripts -> ../lua_scripts`，兼容当前进程的旧路径。14:57:16 日志确认预编译 1 个脚本，并在世界及多个地图状态执行成功。之后重启使用配置中的绝对路径。符号链接及实际安装配置属于本机部署，不提交私有配置文件。
