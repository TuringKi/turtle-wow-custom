# “地狱之影”坐骑学习提示核对

本次只读检查发现：物品与技能使用了不同的中文名称。

| 对象 | ID | 检查结果 |
| --- | --- | --- |
| 物品 | 50536 | `item_template.name = Twilight`，`locales_item.name_loc4 = 地狱之影` |
| 物品使用法术 | 46499 | Add Mount to Collection，绑定 `spell_turtle_mount_collection` |
| 坐骑技能 | 33396 | `collection_mount` 中 50536 唯一映射到此技能；世界库名称 Twilight |
| 提供的 1.18.1 资源 | Spell.dbc / 33396 | 中文简体名为“暮”，英文名为 Twilight；安装目录和提供的压缩包参考副本一致 |

`spell_turtle_mount_collection::OnCheckCast` 检查物品映射到的坐骑技能是否已在角色法术列表中，不是检查共享的学习法术 46499。只有已经拥有 33396 才会返回 `You already know this mount.`。未拥有时，执行效果学习 33396 并消耗物品。

只读角色查询发现，持有物品 50536 的非 NB1181 角色已有 33396，且 `active = 1, disabled = 0`。因此这条记录对应的“已学会”判断有数据库依据，应先在收藏中查找“暮”或 Twilight。用户实际客户端文件尚未取得，不能据服务器 DBC 断言客户端显示名称完全一致。

没有删除、重学、覆盖角色技能，没有消费物品，也没有修改 DBC 或数据库。若实际报错角色不同，或仍无法在收藏中找到，应继续核对角色名、提示原文与客户端收藏列表；不应通过删除已学技能绕过检查。
