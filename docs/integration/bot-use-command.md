# 修复机器人 use 命令不执行 — 2026-09-06

用户反馈 `/w <bot> use go`、`.bot cmd <bot> use go` 和通配队伍命令均未让机器人执行使用动作。前一轮仅确认命令注册，没有核对触发器的消费者，给出了无法可靠执行的指引。

## 确认的问题与修复

- `ChatTriggerContext` 为 `u` 和 `use` 分别创建触发器，`NamedObjectContext` 按请求名称缓存实例。`ChatCommandHandlerStrategy` 仅监听 `u`，因此解析器向 `use` 实例写入的事件没有对应消费者。补上 `use` 的执行映射，保留 `u`。
- `HandleBotDo` 拆出了动作名和参数，却一直用完整原文查询动作。修正为查找当前拆分的动作名，使 `.bot do <bot> use go` 等带参数动作能够执行。
- 名称匹配直接把 `string::find` 结果当布尔值，首字符匹配被排除、无匹配的 npos 却被接受。改为显式检查 npos。
- 名称回退搜索会覆盖明确的物件链接，甚至把背包物品的目标改成附近无关物件。仅在没有物品、没有明确物件目标时进行名称搜索。
- `use go` 的最近物件搜索忽略已删除、GENERIC 装饰物和 NO_INTERACT 物件，与核心正常交互入口对这些目标的限制一致。

## 使用方式

推荐直接执行，便于立即看到失败原因：

```text
.bot do 机器人名字 use go
```

`go` 选择机器人附近最近的可交互候选物件；仍需满足距离、物件状态和正常使用条件，不会绕过钥匙、任务或脚本要求，也不会自动寻路过去。

修复后聊天队列方式也可用：`/w 机器人名字 use go`、`.bot cmd 机器人名字 use go`。`.bot cmd * use go` 给队伍里的每个机器人分别选最近候选物件，不保证它们选中同一个目标。背包物品使用参数为物品链接或 ID，例如 `use 6948`，不应附加 `go`。

## 验证

- `python3 tests/playerbots/test_use_commands.py`：编译生产命令解析、触发器和动作处理代码，检验 use/u 事件消费、带参数直接执行、名称匹配、目标缺失、物件链接以及物品目标隔离；通过。
- 同一测试使用 `--baseline=ae886b2`（及 `--selection-only`）时，旧代码分别在事件未消费和选错物件的断言处失败。
- `test_summon_states.py` 通过，已有机器人身份与召唤保护未回退。
- Release 增量编译通过；隔离世界服 ready，合成角色 Checkbb 的排队 `use` 请求进入动作并对不存在的目标给出明确反馈。直接执行 `use 6948` 返回正在使用炉石；死亡矿井 `use go` 通过排队与直接执行两种方式，均到达核心 CMSG_GAMEOBJ_USE，目标为门杆 entry 101831、guid 26188。未模拟真人客户端点击或验证所有物件脚本。
- 本轮隔离关服退出码 0，无选定 SQL/断言/Eluna 错误；此前偶发关服 SIGSEGV 仍保留为未结案事项。
- 原子安装到 `.install/libexec/mangosd`，SHA-256：`9b1d60ebf17add1a58fb2fef491882c120f653d40c850c17ec1417081a7ba43d`；原程序保留在 `/root/turtle-wow-startup-check/bot-use-command/mangosd-before`。未启停生产世界服，下次启动/重启加载新版。

本机证据目录：`/root/turtle-wow-startup-check/bot-use-command/`。生产数据库无需迁移；本轮不修改生产账号、角色或世界数据。
