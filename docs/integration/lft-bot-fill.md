# LFT 真人排队后机器人补位

本次接入 Turtle LFT 的现有排队器。真人进入队列并等待 60 秒后，在线的随机机器人补齐缺少的职责，目标为 1 坦克、1 治疗、3 输出。机器人自动回答职责确认和组队邀请，真人仍须自己确认。不启用无人排队时的纯机器人副本队。

## 使用

1. 在支持服务器 LFT 排队协议的客户端 LFT 界面选择副本、职责并加入队列，回答职责确认。已有队伍由队长发起；机器人队员自动回答。
2. 等待 60 秒，后台每 5 秒检查一次可用机器人。出现组队确认时点击接受。
3. 组好队后正常进入副本，需要时在副本内使用 `.bot summon *`。本功能负责排队组队，不自动传送真人，也不保证机器人能独立完成所有副本机关。

客户端需要支持 `TW_LFG` 前缀以及 `C2S_QUEUE_JOIN` / `C2S_ROLECHECK_RESPONSE` / `C2S_OFFER_ACCEPT`。本机没有用户实际使用的客户端插件，不能仅凭客户端版本号保证界面协议一致。若插件只有手动发布招募信息而没有排队入口，可按顺序用以下宏验证服务器队列（示例死亡矿井、输出；服务器按原样比较副本名称）：

```lua
/run SendAddonMessage("TW_LFG","C2S_QUEUE_JOIN;Deadmines;d","GUILD")
/run SendAddonMessage("TW_LFG","C2S_ROLECHECK_RESPONSE;d","GUILD")
```

等候补位后发送接受；若尚未产生邀请，不会提前自动接受未来邀请：

```lua
/run SendAddonMessage("TW_LFG","C2S_OFFER_ACCEPT","GUILD")
```

退出排队：

```lua
/run SendAddonMessage("TW_LFG","C2S_QUEUE_LEAVE","GUILD")
```

`t` 为坦克、`h` 为治疗、`d` 为输出。普通聊天频道里输入这些协议字符串无效。机器人不足、阵营/硬核模式或等级不匹配时仍会等待，日志会给出缺少的职责；不会为了凑人数创建或覆盖玩家账号。

## 实现及保护

- 新增 PlayerScript 候选资格钩子，由现代机器人模块使用自己的账号名单和配置前缀判断，移除 LFT 对 `RNDBOT` 的硬编码。当前安装仍使用 `NB1181`。
- 排除真人客户端、真人主人、外部测试保留、离线、死亡、传送、战斗、飞行及战场状态；不从普通既有队伍中抢人。旧有纯机器人队回收路径仅接受 LFT 自己记录的队伍。
- 招募前检查阵营、硬核模式和等级。缺坦克/治疗时沿用已有的随机机器人职责/天赋选择；不对真人自动分配天赋。
- 职责统计只计算能进入 1/1/3 配比的排队成员，排除已有邀请者，避免输出人数过多阻止补坦克和治疗。
- 已有机器人成员自动回答职责弹窗；真人即使启用了自身 AI 也不会被自动确认。
- 成功组队时移除补位跟踪，保留职责；退出后清退无需求的补位机器人。关闭功能时移除尚未形成邀请的补位成员，已有邀请按原超时流程处理。
- 不依赖旧 `LfgActions` 的空实现，也不靠 `AiPlayerbot.RandomBotJoinLfg` 开关启用。

## 配置

安装配置文件：`/root/turtle-wow-custom/.install/etc/mangosd.conf`。源码样例默认仍关闭，当前安装启用以下配置：

```ini
LFT.BotFill.Enable = 1
LFT.BotFill.DelaySeconds = 60
LFT.BotFill.LevelRangeBelow = 2
LFT.BotFill.LevelRangeBelowHealer = 4
LFT.BotFill.LevelRangeAbove = 6
LFT.BotFill.SeedRuns = 0
LFT.BotFill.SeedTeleport = 0
```

需要重启世界服加载新程序。本次不代为重启生产世界服，不修改生产账号、角色或世界数据库；无需新增 SQL。游戏运行后的正常组队和机器人存档仍会发生。

## 验证

`tests/playerbots/test_lft_candidates.py` 编译真实模块候选判定，覆盖账号资格、真人/主人/外部保留排除，以及离线、死亡、战斗、传送、飞行、战场和单人副本状态。

`tests/playerbots/test_lft_bot_fill.py` 编译真实 LFT 补位、职责确认、匹配、邀请和完成函数；以 ASan/UBSan 验证延时/禁用、1/1/3、真人手动接受、输出过量、已邀请成员、阵营/硬核/等级、退出清理和成功后职责保留。网络输出和实际 Group 创建边界使用内存替身，不代表真实客户端已经验证。

会话身份/副本召唤、启动删除保护、use 指令回归也已通过。编译、隔离启动和安装记录保存于服务器私有目录 `/root/turtle-wow-startup-check/lft-bot-fill/`，不提交二进制或配置密钥。

完整 Release 编译成功，最后增量编译包含两处 LFT 实现的最新修改。隔离世界服使用本机 socket 和合成角色库，成功启动并加载 Eluna，实际观察到 1 坦克、1 治疗、3 输出自动接受并建队，正常退出码 0；未出现数据库结构错误或断言。为了在没有真人客户端时驱动这次集成测试，仅隔离配置临时启用了纯机器人种子。该模式出现反复重组，不能据此宣称纯机器人副本队已可稳定使用；生产 `SeedRuns = 0`，不启用此模式。

新程序已原子安装到 `/root/turtle-wow-custom/.install/libexec/mangosd`，SHA-256 为 `070e52198f20b3b9fe0409b5f5314e3d08816ac64d8bc929cafaaa8639d7b28b`。原程序及原配置分别保存在私有验证目录的 `mangosd-before`、`mangosd.conf-before`，未删除既有备份。生产世界服未重启，实际 1.18.1 客户端的排队界面、邀请确认和进本仍需游戏内测试。
