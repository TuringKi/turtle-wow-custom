# 现有服务器 SQL 升级审查

目标：本地 `c71155a` 合并上游 `6cdc923`（1.18.1）。增量脚本位于 `sql/custom_upgrade_118/`；实际执行状态和验证结果见下节。

## 2026-09-06 实际执行与启动验证

本节为最新状态；下方保留此前的审阅记录，历史记录中的“尚未执行”不再代表本次执行状态。

- 已执行 `01`、`02`、`03`、`04`、`10`、`11` 六个增量脚本。账号表、角色表原字段及原世界表的数据指纹校验一致。角色库从 110 张表增至 114 张；没有导入账号/角色初始化脚本。
- 随后修复启动遗漏：`12_world_spell_script_name.sql` 只新增 `spell_template.script_name`，默认空串；未套用上游法术数值或脚本绑定 UPDATE。
- `13_world_playerbot_dependencies.sql` 新增装备评分、评分属性、附魔、命名地点、区域等级、帮助文本、机器人文本、文本概率八张依赖表，并补种子记录。实际世界库最终为 214 张表。原 206 张表的旧字段数据校验一致。
- 依赖种子脚本按显式主键跳过已有记录；没有唯一键的评分属性按 `(id,field)` 检查后插入。兼容 MySQL 5.6 的 `FROM DUAL`，重复执行不重复增加记录。
- 为避免首次启动重新计算，向正式角色库原本为空的 `ai_playerbot_equip_cache`、`ai_playerbot_rnditem_cache` 分别插入 1,256,225、81,530 条隔离环境预计算记录，数据校验一致。原有 `ai_playerbot_item_info_cache` 校验值未变。没有复制测试账号或角色。
- `.install/etc/aiplayerbot.conf` 已启用新机器人，独立前缀为 `NB1181`，保留 256 个账号的设置，并补入匹配版本的 286 项天赋预设配置。可配置的删除账号/公会/竞技场队伍开关均为 0；核心 `CleanCharacterDB=0`、`CharDelete.KeepDays=0`；SQL 自动更新保持关闭。
- `.install/bin` 的启动入口指定 `.install/etc` 配置，真正的二进制位于 `.install/libexec`。`etc/modules/mod_dungeon_clear.conf` 已补齐。
- 使用现有世界库副本、真实角色库结构和合成账号/角色，隔离运行新机器人：首次生成缓存后成功开服；第二次启动耗时 38 秒，网络连接收到认证挑战包，9 个测试角色中有 2 个在线。没有出现缺列、缺表或数据库断言错误。保留了原世界数据中的非致命引用/路径警告；这不是全部游戏内容的测试证明。
- 正式数据库使用 MySQL 5.6.34；隔离运行使用本机 MySQL 8.0.39。没有以正式账号/角色数据库启动验证服务。用户要求停止整库备份后，仅保留结构备份；不完整的全库导出不能用于恢复。

执行与校验记录：`/root/turtle-wow-db-upgrade-20260906/`、`/root/turtle-wow-startup-check/`。

仍保留的范围限制：32 张世界内容差异表没有覆盖；机器人策略 value 字段仍为 varchar(255)，未扩容；用户要求只改前缀，因此机器人代码中的临时角色/空账号清理逻辑未修改，关闭删除开关并不能禁止所有运行时清理。

## 2026-09-06 幻化对话修复（已审阅并执行）

客户端为 1.18.1。Felicia（51290）和 Herrina（51291）原有幻化 NPC 标志保留，但 `gossip_menu_id` 都为 0；缺少上游 `20260711170358_world.sql` 中的 `TRANSMOG_TRIGGER` 对话关联。

用户确认范围后，已执行 [14_world_transmog_dialogue.sql](../../sql/custom_upgrade_118/14_world_transmog_dialogue.sql)：

| 表 | 已执行的变化 |
| --- | --- |
| broadcast_text | 新增 entry=900000，男女文本均为 TRANSMOG_TRIGGER |
| npc_text | 新增 ID=900000，BroadcastTextID0=900000 |
| gossip_menu | 新增 entry=64999、text_id=900000 |
| creature_template | 仅将 entry=51290、51291 的 gossip_menu_id 从 0 改为 64999 |

执行前复查三个目标编号均未占用，并保存相关记录。执行后确认新增三行、更新两行；逐字段比较两名 NPC，只有 `gossip_menu_id` 改变，最终对话关联查询返回两条 `TRANSMOG_TRIGGER`。本次没有删除操作，也未修改账号库、角色库。此前“原世界表字段未变”的校验记录针对 01–13 阶段；本次两行菜单变更是用户另行批准的例外。

14 保存本次实际执行 SQL，是一次性脚本，不应在当前已修复数据库重复运行。用于其他安装时，先检查上述编号不存在且两名 NPC 菜单为 0，保存受影响记录，再逐文件执行并遇错停止；MyISAM 表不能依赖事务回滚。不要批量执行整个升级目录。

本机执行前后记录保存在 `/root/turtle-wow-startup-check/transmog-apply-20260906-125933/`，不提交私有数据库记录。数据库关联已验证；世界服需要重启加载，客户端窗口显示仍待用户实测。

## 2026-09-06 移动邮箱修复（已审阅并执行）

移动邮箱终端物品 50011 通过法术 46096 加入玩具收藏，`collection_toy` 将其关联到召唤法术 46001。新版将处理逻辑移到 C++ 法术脚本，而 12 阶段只新增空的 `script_name` 字段，导致两处功能没有绑定。

用户确认后执行 [15_world_mobile_mailbox.sql](../../sql/custom_upgrade_118/15_world_mobile_mailbox.sql)：仅将 `spell_template` 的 46001 绑定为 `spell_item_summon_utility_object`、46096 绑定为 `spell_turtle_toy_collection`。原值均为空，执行后逐字段确认只有这两处变化。邮箱对象 144112 已存在，类型为邮箱；未修改账号库或角色库。46096 是共用收藏法术，恢复后使用相关收藏物品会按原逻辑消耗物品并学会玩具。

本机前后记录位于 `/root/turtle-wow-startup-check/mailbox-apply-20260906-145833/`。需要重启世界服加载核心脚本绑定，`.reload eluna` 不适用于这项修复；数据库验证完成，实际邮箱交互待客户端测试。

## 执行边界（历史审阅记录）

- **账号库、角色库：只补缺失内容，不删库、不删表、不清空表，不执行 DELETE、REPLACE 写入、清理脚本，不修改已有字段值。** 新增字段会让已有行读取到新字段的默认值；原字段保持不变。
- **世界库：可以在当前库上做增量修改，但必须先把具体表、行条件、前后差异及影响范围交用户审阅。** 尚未得到实际写入的批准。
- 不直接执行 `sql/create_databases.sql`、`sql/setup_databases.sh`、`sql/base/*.sql` 或机器人初始化原文件。这些文件包含删表重建或清理内容。
- `Database.AutoUpdate.Enabled = 0`。配置模板和代码缺省值均已关闭自动更新；不要把整个上游目录加入现有服的自动更新路径。
- 不用现有账号库、角色库启动测试服。新机器人模板 `AiPlayerbot.Enabled = 0`；本机 `.install/etc/aiplayerbot.conf` 与 `.install_pbot/etc/aiplayerbot.conf` 当前也为 0。启用前还需核对其运行时行为：`CreateRandomBots()` 包含临时角色、空账号清理，`DeleteRandomBotAccounts = 0` 不能单独阻止这些路径。本次升级不会运行这些清理。

## 2026-09-06 只读核对结果

读取 `.install/etc/mangosd.conf` 指向的 `192.168.1.80:3310`，服务器版本 **MySQL 5.6.34**。以下为当时观察，执行前需重新检查结构；未读取或导出真实账号凭据、角色记录。世界库只读数据导出用于本机隔离比较，因未锁表且有 MyISAM 表，不作为停服后的正式一致性备份。

| 用途 | 配置中的库 | 现有表数 | 结论 |
| --- | --- | ---: | --- |
| 账号 | `twptr_logon` | 45 | active、realm_id、queue、maxqueue 已有；缺 world_config.dynamic_scaling_pop |
| 角色 | `nd_char` | 110 | characters.active 已有；缺 extraBonusTalentCount、新 PvP 货币表及部分机器人结构 |
| 世界 | `twptr_world` | 199 | shop_items 的 7 个新版展示字段和 collection_toy 已有；缺 5 张新版基础表 |
| 日志 | `twptr_logs` | 1 | 基础表和列未发现缺项 |

世界库现有 `migrations` 有 634 条旧历史，没有 `Module` 列；与候选上游补丁的内容哈希没有匹配。这**不能证明 157 个候选补丁都需要执行**：已手工更新的数据可能没有相应记录。

## 账号库候选操作

`01_logon_additions.sql` 通过 information_schema 判断后，仅新增缺失字段。对本次实际库，预期只新增：

```sql
ALTER TABLE world_config ADD COLUMN dynamic_scaling_pop INT UNSIGNED NOT NULL DEFAULT 0 AFTER max_item_stack_transferred;
```

其他 4 个字段已存在，保持其原定义，包括现有 `shop_logs.realm_id` 没有默认值这一差异。基础导出还含 `gp_history`、`account.email_letterid`、`account.server`，但没有发现当前服务端代码读取这些历史/外部字段，暂不作为核心启动必需迁移。

## 角色库候选操作

| 脚本 | 预期新增 | 原数据处理 |
| --- | --- | --- |
| `02_character_additions.sql` | characters.extraBonusTalentCount，默认 0 | active 已存在时跳过；不更新任何旧列 |
| `03_character_pvp_currency.sql` | character_pvp_currency | 只建缺失表，不回填、更改既有荣誉数据 |
| `04_character_bot_additions.sql` | ai_playerbot_equip_cache.spec，默认 0；ai_playerbot_db_store.preset，默认空串 | 只加字段，不清缓存、不重建已有机器人表 |
| 同上 | ai_playerbot_tele_cache、ai_playerbot_arena_team_names | 只建缺失表；不重复导入现有名字或策略 |
| 同上 | character_inventory_copy | 缺表时 LIKE 原背包表创建结构；不复制、清空背包数据 |
| 同上 | ai_playerbot_random_bots.idx_owner_bot_event | 新增普通联合索引，不改变旧行 |

**上述候选尚不足以证明现代机器人能安全启用。** 实际 `ai_playerbot_db_store.value` 是 varchar(255)，上游需要 varchar(4000)。扩大已有字段不属于“只增加缺失字段”，本次未加入执行脚本。保留现有定义可能导致长策略写入失败或截断；解决这一项及启动清理行为前，保持新机器人关闭。

不上 `20260731160000_guild_bank_money_unsigned.sql` 的公会资金类型变更：实际 `guild_bank_money.money` 仍为有符号 int，转换定义超出本次仅增加范围。不创建基础导出里的历史归档表 `character_bck`、`character_reputation_broken`、`character_skills_copy`、`characters_namecleanup2020_2`，当前代码未发现依赖。

现有 ai_playerbot_names、自定义策略、随机机器人记录以及其余定制表全部保留。数据库中真实记录的内容不在本次结构核对范围内，不能用表存在代替内容兼容检查。

## 世界库提交审阅的范围

`10_world_missing_tables.sql` **仅作为第一批候选**：创建缺失的 `custom_merchant`、`itemextendedcost`、`module_string`、`module_string_locale`、`skill_race_class_info_mod`。它只含表结构，不导入基础数据，不能独立完成 1.18 世界内容升级。`11_world_patch_tables.sql` 另补 spell_extra、lft_user_groups。spell_extra 只从**当前** spell_template 复制缺失项，保留当前法术系数与自定义标记，不用上游数值覆盖；已经存在的 spell_extra 行保持原样。两文件仍需用户审阅后才可在实际世界库执行。

已有 `playerbot`、`playerbot_names`、四张 `player_premade_*`、`auctionhousebot2`、`bot_smart_script`、`bottalktext`、`creature_template_npcbot_wander_nodes` 及机器人路径表必须保留。

现有副本与候选结果的逐表、逐字段计数见 [world-data-review.md](world-data-review.md)。共同唯一键的记录中，32 张表存在字段差异；不能把这些差异自动视作应覆盖的定制。

完整上游候选文件见 [world-sql-candidates.md](world-sql-candidates.md)：130 个 `sql/database_updates/world/` 文件和 27 个根目录文件。当前审查发现包括：

- 生物、物件、任务、商人、训练师、掉落、地图等基础内容的大批整表替换。需要在隔离副本比较主键及字段，形成保留现有定制的增量；不直接导入原文件。
- 职业法术、毒蛇套装、盾牌专精、乱舞、PvP 饰品等修复。
- 复活点、德鲁伊航线、地精/高等精灵出生点、公会银行对话、生存专业训练与指路。
- 分解掉落、战场声望物品与商人门槛、北风任务修复。
- 新机器人经典世界路径、RPG 种族与提示文本。现有同名表先比较；原 RPG 脚本会删除 option_id=99 对话和重建表，不能直接执行。

这些分组是审查范围，**不是已批准执行的变更**。最终数据修改必须附精确条件、当前值、目标值、插入/修改行数和 SQL 内容摘要。

## MySQL 版本与重复执行

候选脚本使用 MySQL 5.6 支持的 information_schema + PREPARE 方式判断字段、索引，不使用 MariaDB 的 ADD INDEX IF NOT EXISTS。新表的 utf8mb3 名称改为 5.6 认识的 utf8；不改变旧表字符集。移除新 InnoDB 表中非必需的压缩格式要求，避免依赖 Barracuda 配置。

旧表的零日期默认值会让 MySQL 8 的严格模式拒绝 ADD COLUMN。01/02 只在当前连接临时关闭两项零日期检查，保留其他严格转换检查，执行后恢复原 sql_mode。这里 `REPLACE(...)` 是字符串函数，**不是替换数据行的 REPLACE INTO**。

脚本遇到已有字段/表会跳过，不会自动纠正已有定义。执行前仍需核对 `00_preflight.sql`，不能把跳过视为兼容认证。不要使用 mysql `--force` 忽略错误；DDL 不依赖事务回滚来恢复，应先完成备份及审阅。

## 自动更新器覆盖范围

代码只扫描配置路径下 auth、character、world 各目录的直接 `.sql` 文件，并另扫模块 `data/sql/<类别>`。不会自动扫描根目录 27 个补丁、`sql/character_updates/`、机器人 `sql/characters/`、`sql/world/classic/`，也没有日志库分支。历史按 Module 和 SHA1 识别；内容改变可能重新执行。即使设置按文件名排序，也不能解决整表覆盖及手工修改冲突。

## 执行顺序（待最终审阅）

1. 确认使用 3310 的这一组库，停服并做可恢复备份；重新跑只读结构检查。
2. 审阅最终账号、角色新增脚本及世界库逐项数据差异。
3. 用户同意后，才在对应库执行已审阅文件，逐文件停止并检查错误；禁止批量导入上游目录。
4. 对比原表集合、旧字段值及账号/角色关联记录，核对新增默认值、索引、世界库定制数据。
5. 先在隔离环境验证 1.18.1 数据文件和服务端，解决新机器人存储长度及清理问题后再确定正式启用配置。

## 已完成的隔离验证

MySQL 8 隔离实例中，实际角色库的结构副本加人工记录，02/03/04 连续执行两次通过，原 110 张表保留，新建 4 张，测试角色与机器人原字段值未变。01/02/03 亦在仓库旧结构上验证两次执行。MySQL 5.6 实际服没有执行这些脚本。

全新候选世界库中，先执行 130 个 world 子目录补丁，再执行 27 个根目录补丁，全部通过。两目录按文件名混排会出现训练师重复主键，不能采用混排顺序。这个结果证明隔离 MySQL 8 中的候选顺序可执行，不证明能够直接升级现有 MySQL 5.6 世界库。

10/11 世界结构候选也在现有世界库的隔离副本上各执行两遍：199 张原表校验值不变，新增 7 张；spell_extra 新增的 24,879 行与原 spell_template 的系数、等级和自定义标记一致。此为结构补齐与现值复制验证，不是 32 张内容差异表的覆盖批准。
