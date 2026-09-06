# 2026-09-06 上游增量合并

合并来源：Shyalya/tortoise-wow 的 `playerbots-integration-gh`，从前次 `6cdc923` 更新到 `c7d46275f900fdb07f9b2306e7c6f8c7cf59072c`，共新增 5 个提交。合并前本地 main 为 `ac2cba2`；自动合并无冲突，保留本地机器人兼容修改、Eluna 炉石、幻化及移动邮箱修复。

更新内容：沉没的神庙、黑石深渊、玛拉顿自动清本路线；删除两条过时的黑石深渊路线文件；黑石深渊目标顺序不再指定酒吧三名友善 NPC。路线 `.cpp` 是位于 `routes/` 的生成参考文件，处于模块 `src/` 编译收集范围之外；运行时路线由 `.route` 文件提供。

验证：34 份新增/修改的 `.route` 文件包含 918 个坐标点，已检查文件名/头部地图和目标编号、坐标有效性、可选标记及至少三个点的加载要求。Git 冲突及空白检查通过，Eluna 炉石 Lua 5.2 测试通过。本次没有编译源码或构建配置变化，未重编译；没有进行真实地图导航测试。

## 数据库和部署范围

上游新增 `sql/database_updates/world/20260905175321_world.sql` 含两个 DELETE，分别清理 `creature_movement` 和 `creature_linking` 的指定记录。只合入版本历史，**没有在服务器执行**；不得将它作为已批准升级批量导入。SQL 自动更新继续保持关闭。

本次只合并代码仓库，没有复制安装目录、修改数据库或重启运行服务。路线生效需要按实际 `DungeonClear.RouteRecorderDir` 配置同步数据，部署时另行核对。

合并前已有的 `src/modules/.gitignore` 未提交修改及嵌套 `src/modules/playerbots/` 工作区保持原样，不纳入提交。
