# 合并遗漏补齐：实际执行记录（2026-09-06）

上游基准为 `c7d46275f900fdb07f9b2306e7c6f8c7cf59072c`，已包含在本地合并提交 `1629c24` 中。此次发现的主要遗漏在数据库功能内容及安装目录的路线部署：此前成功启动只验证了结构和部分依赖，不代表所有上游内容已启用。

## 已执行的增量

| 文件（sql/custom_upgrade_118） | 正式数据库的实际结果 |
| --- | --- |
| 17_world_spell_bindings.sql | 填充 889 条既有法术的空 script_name；新增 191 条完整法术记录（含触发依赖） |
| 18_world_feature_seeds.sql | 原为空的 custom_merchant、itemextendedcost、skill_race_class_info_mod 分别新增 564、549、1 行 |
| 19_world_object_bindings.sql | 填充 3 个生物、2 个物件、1 个副本的空脚本绑定，其他字段不变 |
| 20_world_missing_spell_data.sql | 再新增 2,859 条缺失法术；为合计 3,050 条新法术补齐 spell_extra，保留所有旧法术数值与旧系数 |
| 21_world_battleground_locations.sql | 4 条战场记录的 8 个 WorldSafeLocs 引用改为安装版 DBC 存在的编号，其他字段不变 |
| 22_character_strategy_capacity.sql | 仅角色库 ai_playerbot_db_store.value 从 varchar(255) 扩大到 varchar(4000)，保持字符集、排序规则及 NULL/default 定义；执行前后该表均为 0 行 |
| 23_world_spell_support.sql | 新增 spell_proc_event 84、spell_chain 41、spell_learn_spell 51、spell_mod 15、spell_affect 156、spell_group 6 行；旧记录逐行指纹一致 |

除 22 指向角色库外，其余均指向世界库。本轮没有账号库写入，没有账号/角色记录删除、覆盖，也没有生成正式测试账号。受影响表/记录已做小范围 SQL 备份，保存在本机 `/root/turtle-wow-startup-check/merge-completion/`；没有重新做巨大的角色整库备份，也未删除旧备份。

19 的精确范围：creature_template 62037、62056、62057；gameobject_template 1000512、2006138；map_template 816。21 的战场编号及位置前后值：2 为 769/770 → 97/98；1 为 611/610 → 77/76；3 为 890/889 → 114/113；5 为 700/701 → 130/131。

23 的 spell_group 不能按上游槽位编号直接覆盖：现有 group_id=2000 的 0–8 槽已占用，成员顺序与上游不同。保留这些记录，将缺少的 51533、51534、51535、51536、51525、51526 依次追加到 9–14 槽。隔离库和正式库均校验原有行不变及重复执行不增加记录。

这些是针对本机已审计状态的补丁，不是适用于任意旧数据库的自动升级器。不要批量执行整个上游或定制目录；14 等历史脚本包含一次性操作，22 必须选择角色库，其他脚本的执行前提和已有主键也需先核对。SQL 自动更新保持关闭。

## 最终法术绑定核对

参照完整基础数据加 130 个 world 子目录补丁、27 个根目录补丁执行后的最终结果核对；不是只取早期 `20260721013813_world.sql`。

1,054 条有对应实现且适用的最终绑定已与正式库逐项匹配，见 [sql-audit-final-spell-bindings.tsv](sql-audit-final-spell-bindings.tsv)。下列上游问题没有强行套入：

- 5176、5177、5178、5179、5180、6780、8905、9912 指向 `spell_druid_wrath`，当前源码没有该脚本实现，保留空绑定。
- 27230 实际为宠物伤害增益，却被上游绑定为制造治疗石，未新增该错误记录。
- 后续补丁已清除 Rockbiter 及 52567 的早期绑定，不能当作遗漏补回；45908 按最终结果绑定 `spell_warlock_demon_gate`。正式库独有的 46431 保持原空绑定。

新增法术使用完整参考行，核对安装版 1.18.1 Spell.dbc；没有为消除报错插入只含编号的空法术。候选中另有 7 个编号不在安装版 Spell.dbc，未添加。

## 安装目录

已将仓库的 140 份 `.route` / `.fallback` 文件及 `dc_roster.txt` 复制到：

```text
/root/turtle-wow-custom/.install/share/mod-dungeon-clear/routes/
/root/turtle-wow-custom/.install/share/mod-dungeon-clear/dc_roster.txt
```

`.install/etc/mangosd.conf` 已设置：

```ini
DungeonClear.RouteRecorderDir = "/root/turtle-wow-custom/.install/share/mod-dungeon-clear/routes"
DungeonClear.RosterFile = "/root/turtle-wow-custom/.install/share/mod-dungeon-clear/dc_roster.txt"
```

文件内容逐一匹配源码；主配置原文件已备份。此轮没有修改编译源码，没有重新构建或替换二进制。正式世界服未由审计进程启动或重启，数据库绑定和配置需重启世界服加载，不能用 `.reload eluna` 替代。

## 验证及尚未解决的范围

增量已先在隔离 MySQL 8 世界库副本执行，再在正式 MySQL 5.6.34 执行；检查了预期新增、受保护字段/记录的指纹以及重复执行结果。角色字段另用合成 NULL、255 个中文字符验证原值保持，并确认能保存 4,000 字符。

隔离启动只连接本机世界库副本和合成账号/角色库，已到达 `World server is up and running`，加载了炉石 Lua，没有缺列/缺表/数据库断言。启动成功不是客户端副本出入测试：用户报告的带机器人出副本客户端空指针崩溃尚未复现或证实修复。

另发现隔离世界服在正常关服后偶发 SIGSEGV：两次普通运行出现，GDB 和信号跟踪运行正常退出，尚无有效崩溃栈，不能将它与客户端崩溃视作同一问题，也不能宣称整体验证全通过。补齐 23 后的最后一次普通隔离启动及关服退出码为 0，但单次正常退出不足以排除前述偶发现象。相关结果和日志保存在上述本机审计目录，正式世界服未参与这些测试。

世界内容仍保留现有定制差异，没有把参考库整表覆盖到正式库。旧审阅中的 32 张差异表包含生物/物件模板与刷新、任务、掉落、训练师等；缺失地图 818 及部分新副本模板也没有仅凭脚本名字创建。它们需要按玩法和依赖形成单独的完整内容迁移，不能将所有差异自动认定为可覆盖的遗漏。详见 [world-data-review.md](world-data-review.md)。此次完成的是上表已核实的增量及部署，不代表全量世界内容已与上游相同。
