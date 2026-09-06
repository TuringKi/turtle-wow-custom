# 2026-09-06 上游增量合并

合并来源：Shyalya/tortoise-wow 的 `playerbots-integration-gh`，从前次 `6cdc923` 更新到 `c7d46275f900fdb07f9b2306e7c6f8c7cf59072c`，共新增 5 个提交。合并前本地 main 为 `ac2cba2`；自动合并无冲突，保留本地机器人兼容修改、Eluna 炉石、幻化及移动邮箱修复。

更新内容：沉没的神庙、黑石深渊、玛拉顿自动清本路线；删除两条过时的黑石深渊路线文件；黑石深渊目标顺序不再指定酒吧三名友善 NPC。路线 `.cpp` 是位于 `routes/` 的生成参考文件，处于模块 `src/` 编译收集范围之外；运行时路线由 `.route` 文件提供。

验证：34 份新增/修改的 `.route` 文件包含 918 个坐标点，已检查文件名/头部地图和目标编号、坐标有效性、可选标记及至少三个点的加载要求。Git 冲突及空白检查通过，Eluna 炉石 Lua 5.2 测试通过。本次没有编译源码或构建配置变化，未重编译；没有进行真实地图导航测试。

## 数据库和部署范围

上游新增 `sql/database_updates/world/20260905175321_world.sql` 含两个 DELETE，分别清理 `creature_movement` 和 `creature_linking` 的指定记录。初次合并时没有执行；用户随后明确要求执行，已按下节核对并应用带孤立条件的定制版本。SQL 自动更新继续保持关闭。

代码合并阶段未部署安装目录或重启服务；随后数据库操作见下节。路线生效需要按实际 `DungeonClear.RouteRecorderDir` 配置同步数据，部署时另行核对。

合并前已有的 `src/modules/.gitignore` 未提交修改及嵌套 `src/modules/playerbots/` 工作区保持原样，不纳入提交。

## 后续批准的 SQL 执行

原补丁命中 304 条 creature_movement、41 条 creature_linking。但本库仍保留上游假定不存在的 8 个路径生物和 12 个关联生物，不能直接按编号删除全部记录。

用户授权后，执行 `sql/custom_upgrade_118/16_world_orphan_cleanup.sql`，增加 NOT EXISTS 对应 creature 的保护条件：实际删除 147 条孤立路径、29 条孤立关联；保留 157 条有效路径及 12 条有效关联。对所有非删除目标行做前后 SHA256 校验，一致；命中范围中的孤立记录清零。

仅操作世界库上述两表，账号库和角色库未操作。匹配记录的 INSERT-only SQL 备份和前后校验保存在 `/root/turtle-wow-startup-check/orphan-apply-20260906-161625/`。
