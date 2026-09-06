# LFT 组队完成后客户端仍显示扫描

CompleteOffer 先调用 TeleportGroupToInstance，再通过 LFTManager::GetPlayer 查找成员发送 S2C_OFFER_COMPLETE。跨地图 TeleportTo 会同步从旧地图移除玩家，GetPlayer 的 IsInWorld 过滤随即返回空；服务端虽然清空了排队记录，却漏发完成通知。

现在在启动传送前保留本次同步调用中的五名玩家指针。传送调度成功后，完成队列清理并直接向仍连接的会话发送原有 TW_LFG/S2C_OFFER_COMPLETE。不提前报告成功：传送函数返回失败时仍取消匹配，不发送完成通知。没有放宽 GetPlayer 的全局在世界中检查，匹配器仍不会招募传送中的角色。

同时修复 SendQueueStatus 在无队列、无角色确认、无匹配邀请时完全不回复的问题：使用已有 S2C_QUEUE_LEFT;<角色名> 通知客户端清除旧排队状态。客户端再次请求状态时可恢复此前残留的扫描界面；排队中和确认中的回复保持各自状态。排队在匹配完成时结束，不需要等待击杀最终首领。

回归测试 test_lft_bot_fill.py 模拟传送使全部五名成员 IsInWorld=false，要求每人恰好收到一次完成通知，服务端队列和邀请全部清空；恢复在世界中后，查询状态收到离队消息，可再次排队。拒绝传送不发送成功。使用 ASan/UBSan，并运行 test_lft_party_teleport.py 验证入本逻辑。

以上验证使用实际生产函数及会话/传送替身，不代表已连接实际 1.18.1 客户端验证界面。无需 SQL 或客户端文件更新；安装二进制后需重启世界服，部署不操作生产进程。
