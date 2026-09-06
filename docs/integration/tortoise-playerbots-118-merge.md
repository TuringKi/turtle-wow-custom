# Tortoise 1.18.1 合并记录

本次把上游 1.18.1 与现代 playerbots 模块合入本地定制工程，保留 native partybot/battlebot、自定义伤害规则和 AuctionHouseBotMgr。完整构建与 SQL 隔离核对已完成，合并结果交回原 main；本次交付为代码合并与 SQL 审阅材料，没有部署、启动正式服或执行正式数据库升级。

## 输入与合并方法

- 本地定制基线：`c71155aac27582536024327a8868d730f690d639`，原分支 `main`。
- 上游：`https://github.com/Shyalya/tortoise-wow`，`playerbots-integration-gh`，固定提交 `6cdc923bd546f6b034da7dd8dff21803c15693ed`。
- 独立工作树 `/root/turtle-wow-merge`，分支 `merge/tortoise-playerbots-118`。
- 双方历史没有共同祖先。使用本地最初导入 `996c9888af8e64a214e9e6d04058f511e9487e33` 作**内容比较基线**，而非声称它是上游真实祖先。最终 merge commit 的两个父提交应是本地与上游实际 HEAD。
- 使用 `merge-recursive --ignore-space-change` 后的 46 个文本冲突全部解决；真实上游提交已写入 MERGE_HEAD，最终创建保留两个真实父提交的合并提交。

## 定制保留

| 本地定制 | 合并后处理 |
| --- | --- |
| native partybot / battlebot | 保留全部源码，始终编译；恢复配置、加载、更新、会话及登录回调 |
| PartyBot.DamageMul / DamageTakenMul | 保持原默认值、计算位置和次序；整个 DealDamageMods 函数与本地 HEAD 相同 |
| 玩家自伤使用普通生物法术倍率 | 保留 |
| 非玩家造成至少 1000 伤害先变 100 | 保留，再应用原有后续倍率 |
| Partybot 坐骑 | 以最终 c71155a 为准，复制队长坐骑；更早的随机坐骑代码仍注释 |
| 塔迪乌斯小怪假死窗口 | partybot 场景 50000ms，普通场景 5000ms |
| 自定义 AuctionHouseBotMgr | 原 cpp/h 保留，配置、Load、Update 保留 |
| partybot/battlebot/pbot 命令 | 保持玩家权限；rndbot 保持本地管理员权限，ahbot 保持本地玩家权限 |
| 无网络机器人会话 | GetBot/SetBot、收发包、强制连接和退出、临时角色不保存等入口保留 |
| Creature 崩溃防护 | 保留 native bot 判断，兼容上游反作弊空对象防护 |

上游删除了 native PlayerBotAI/PlayerBotMgr，不能仅保留文件而丢掉调用点。此次补回整个生命周期，加载安排在玩家、宠物及预设模板缓存准备后，避免原来的重复 Load。

## 两套 PlayerbotAI 的构建隔离

native `PlayerBotAI`（大写 B）和 ike3 `PlayerbotAI` 不是同一套实现。新上游还引入完整的现代 cmangos playerbots、自动副本模块和 hook 接口。

- 默认 `BUILD_PLAYERBOTS=ON`、`BUILD_LEGACY_PLAYERBOTS=OFF`：编译现代模块；native partybot/battlebot 仍在。
- 旧 ike3 源码保留，可用 `BUILD_PLAYERBOTS=OFF`、`BUILD_LEGACY_PLAYERBOTS=ON` 单独构建。两者同时开启会明确报错，避免同名类与全局管理器冲突。
- 两种模式均保留 native partybot/battlebot。
- 现代模块通过 Player 的模块槽保存 AI；兼容 getter 让原定制的机器人识别逻辑识别新 AI。旧字段与入口只在旧模式调用。
- 核心已有的 trim、时间、容器和 Unit 接口不重复定义；现代随机数与非战斗法术自由函数改为模块专用名称，保留原核心语义。现代战场路径变量与 waypoint 类型也使用独立名称，防止与 native 的不同回调类型发生符号/ODR 冲突；双方坐标与路线数据保持原样。最终程序确认同时含两套路径符号。
- 旧 ike3 仅三个源文件适配：宠物创建与法术查询两处明确读取 Creature 原数组；声望查询改读实际 ObjectMgr 存储并检查缺失数据。其余旧机器人源码保持原样。

这些编译选项不等于运行开关。为满足数据库保留要求，现代机器人配置模板默认 `AiPlayerbot.Enabled=0`，审查数据库兼容及启动清理行为后才能启用。

## 验证记录

- 595 个 native/旧机器人文件中 592 个逐字节与本地 HEAD 一致，仅旧 ike3 三个文件有上述兼容适配。全部 native bot 文件及完整 DealDamageMods 保持逐字节一致，证据见 preservation-final.json。
- 6 个 native bot 翻译单元的语法编译通过。
- 现代与旧模式 CMake 配置通过；现代模式另外启用 Eluna，并初始化上游固定的 Eluna 子模块 `1b06f28ff3a00054d915d824c725fb4283fee74d`。
- Release 完整构建通过：现代 playerbots + Eluna 模式、旧 ike3 模式均生成 mangosd 与 realmd；两个模式的版本命令正常退出。CTest 的 eluna.lua-runtime 通过（1/1）。未对实际数据库启动服务端，未作游戏内行为测试。
- SQL 新增脚本先在仓库旧结构的隔离 MySQL 8 实例测试；再只读导出实际角色库结构，在独立空库放入人工测试记录，连续执行两遍候选脚本。110 张原表保留，新增 4 张，原测试角色与机器人字段未变。
- 实际服务器仅执行了只读元数据查询和世界库数据导出；账号/角色真实记录未导出，未执行迁移。候选世界库先 world 子目录再根目录的 157 个补丁隔离执行全部通过；与现有副本比较，32 张表的共同主键存在字段差异，已列入审查文档。

构建、冲突、SQL 清单和测试证据位于 `/root/turtle-wow-merge-audit/`。隔离测试 MySQL 只监听 `/root/turtle-wow-sql-test/mysql.sock`，禁用网络，与 `192.168.1.80:3310` 实际数据库分离。

## 数据库交付边界

详见 [SQL 升级审查](sql-upgrade-118.md) 、[世界补丁候选清单](world-sql-candidates.md) 和 [逐表字段对比](world-data-review.md)。账号、角色库严格只增加，世界库逐项总结供用户审阅后再改。自动更新模板和代码缺省值均关闭；不执行原始全量导出或批量上游更新。

实际库已比仓库 1.17.1 结构更新，部分字段无需添加；现代机器人策略存储长度和启动清理仍需解决。仅加缺失表不能证明完整升级或启用安全。

## 原工作区保留要求

原 `/root/turtle-wow-custom` 有 `.gitignore`、`src/modules/.gitignore`、`src/shared/revision.h` 三个未提交修改；`src/modules/playerbots` 是独立 cmangos/playerbots 仓库，HEAD 为 `7745993640395d9ce9434cfe140d4f302ddd06cd`，158 个已跟踪文件修改。原未提交内容完整备份到 `/root/turtle-wow-merge-audit/original-worktree-backup/`，附原补丁和 SHA256。原工作区保留本地忽略规则；嵌套仓库不替换，按 951 个已跟踪文件 SHA256 与原 status 核对。

上游取消了 revision.h 的版本跟踪，但根 CMake 仍在配置时生成 src/shared/revision.h。原脏头仅包含旧提交哈希与日期，需完整留档；后续 CMake 生成当前合并版本，不能继续沿用旧值。原版本头备份在上述目录的 `src/shared/revision.h`。验证用二进制在 merge commit 前构建，版本命令仍显示输入基线日期；它们没有安装到正式运行目录，后续正式构建会重新生成版本信息。
