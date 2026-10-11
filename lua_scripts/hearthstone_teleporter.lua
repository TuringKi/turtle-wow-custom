-- Existing Hearthstone (6948), for this repository's VMaNGOS Eluna port.
-- No SQL writes. Coordinates checked against the installed world's game_tele.
local ITEM = 6948
local HOME_SPELL = 8690
local SENDER = 6948
local HOME = 1
local CLOSE = 99
local pending = {}
local destinations = {
    [10] = {team=0, name="暴风城", map=0, x=-8833.38, y=628.628, z=94.0066, o=1.06535},
    [11] = {team=0, name="铁炉堡", map=0, x=-4918.88, y=-940.406, z=501.564, o=5.42347},
    [12] = {team=0, name="达纳苏斯", map=1, x=9949.56, y=2284.21, z=1341.4, o=1.59587},
    [20] = {team=1, name="奥格瑞玛", map=1, x=1629.36, y=-4373.39, z=31.2564, o=3.54839},
    [21] = {team=1, name="雷霆崖", map=1, x=-1277.37, y=124.804, z=131.287, o=5.22274},
    [22] = {team=1, name="幽暗城", map=0, x=1584.07, y=241.987, z=-52.1534, o=0.049647},
}


-- Only outdoor maps 0/1. Levels are the current world's entrance requirements.
-- Ragefire/Stockades are faction restricted because they sit inside capitals.
local dungeonPages = {
    [100] = {name="低等级副本入口", ids={1001,1002,1003,1004,1005,1006,1007,1008,1009}},
    [200] = {name="中等级副本入口", ids={2001,2002,2003,2004,2005,2006}},
    [300] = {name="高等级副本入口", ids={3001,3002,3003,3004,3005,3006,3007}},
}
local dungeonRows = {
    -- id, name, minimum level, faction (nil = both), map, x, y, z, orientation
    {1001,"怒焰裂谷",8,1,1,1811.78,-4410.5,-18.4704,5.20165},
    {1002,"死亡矿井",10,nil,0,-11208.7,1673.52,24.6361,1.51067},
    {1003,"哀嚎洞穴",10,nil,1,-731.607,-2218.39,17.0281,2.78486},
    {1004,"影牙城堡",10,nil,0,-234.675,1561.63,76.8921,1.24031},
    {1005,"黑暗深渊",10,nil,1,4249.99,740.102,-25.671,1.34062},
    {1006,"暴风城监狱",15,0,0,-8644.19,595.608,95.7028,2.31179},
    {1007,"诺莫瑞根",15,nil,0,-5163.54,925.423,257.181,1.57423},
    {1008,"剃刀沼泽",15,nil,1,-4470.28,-1677.77,81.3925,1.16302},
    {1009,"血色修道院（公共入口）",20,nil,0,2872.6,-764.398,160.332,5.05735},
    {2001,"剃刀高地",25,nil,1,-4657.3,-2519.35,81.0529,4.54808},
    {2002,"奥达曼",30,nil,0,-6071.37,-2955.16,209.782,0.015708},
    {2003,"祖尔法拉克",35,nil,1,-6801.19,-2893.02,9.00388,0.158639},
    {2004,"玛拉顿（橙色入口）",30,nil,1,-1464.14,2615.21,76.7172,3.21357},
    {2005,"玛拉顿（紫色入口）",30,nil,1,-1188.37,2879.61,85.7888,5.07366},
    {2006,"沉没的神庙",35,nil,0,-10177.9,-3994.9,-111.239,6.01885},
    {3001,"黑石深渊",40,nil,0,-7179.34,-921.212,165.821,5.09599},
    {3002,"黑石塔（公共入口）",45,nil,0,-7527.05,-1226.77,285.732,5.29626},
    {3003,"厄运之槌（东）",45,nil,1,-3980.8,789.005,161.007,4.71945},
    {3004,"厄运之槌（西）",45,nil,1,-3828.01,1250.22,160.226,3.20835},
    {3005,"厄运之槌（北）",45,nil,1,-3521.29,1085.2,161.097,4.7281},
    {3006,"斯坦索姆",45,nil,0,3352.92,-3379.03,144.782,6.25978},
    {3007,"通灵学院",45,nil,0,1269.64,-2556.21,93.6088,0.620623},
}
for _, row in ipairs(dungeonRows) do
    destinations[row[1]] = {name=row[2], minLevel=row[3], team=row[4],
        map=row[5], x=row[6], y=row[7], z=row[8], o=row[9]}
end


-- Town coordinates: live game_tele; faction pages are checked again at selection.
local travelPages = {}
local travelRootPages = {}
local townRows = {
    {5001,"北郡山谷",0,0,-8921.09,-119.135,82.195,5.82878},
    {5002,"闪金镇",0,0,-9448.55,68.236,56.3225,2.1115},
    {5003,"东谷伐木场",0,0,-9456.08,-1370.5,46.66,1.95},
    {5004,"哨兵岭",0,0,-10624.5,1096.66,33.7641,1.31041},
    {5005,"湖畔镇",0,0,-9266.59,-2188.77,64.0892,2.10205},
    {5006,"夜色镇",0,0,-10573,-1182.51,28.0148,0.309022},
    {5007,"反抗军营地",0,0,-11322.4,-202.492,75.6362,0.432339},
    {5008,"守望堡",0,0,-10999.8,-3380.08,62.2525,4.63501},
    {5009,"避难营",0,0,-10126,-2834.73,22.2157,0.674244},
    {5010,"摩根的岗哨",0,0,-8372.77,-2754.46,186.622,3.43486},
    {5011,"卡拉诺斯",0,0,-5597.31,-483.398,396.981,3.17566},
    {5012,"寒脊山谷",0,0,-6231.77,332.993,383.171,0.480178},
    {5013,"烈酒村",0,0,-5385.04,310.278,394.151,5.19649},
    {5014,"塞尔萨玛",0,0,-5352.54,-2948.53,323.78,5.34258},
    {5015,"奥加兹岗哨",0,0,-4817.04,-2656.26,327.12,4.68835},
    {5016,"米奈希尔港",0,0,-3769.32,-744.26,8.01027,1.95752},
    {5017,"避难谷",0,0,-1246.61,-2529.32,20.6098,0.741709},
    {5018,"南海镇",0,0,-853.221,-533.529,9.98556,0.242866},
    {5019,"鹰巢山",0,0,260.366,-2125.21,119.565,3.18494},
    {5020,"奎尔丹尼小屋",0,0,226.318,-2777.59,123.356,0.59469},
    {5021,"激流堡",0,0,-1551.2,-1808.1,67.5219,3.119},
    {5022,"阿拉萨拉斯",0,0,4226.82,-2722.43,121.874,5.30635},
    {5023,"远行者小屋",0,0,-5650.46,-4290.58,407.813,2.03292},
    {5024,"幽影谷",0,1,10334,833.902,1326.11,3.62142},
    {5025,"多兰纳尔",0,1,9848.37,966.953,1306.38,3.77457},
    {5026,"奥伯丁",0,1,6501.4,481.607,6.27062,1.70033},
    {5027,"阿斯特兰纳",0,1,2676.19,-422.905,107.123,0.648691},
    {5028,"石爪峰",0,1,2678.38,1497.46,233.869,6.26038},
    {5029,"尼耶尔前哨站",0,1,176.426,1309.76,190.18,0.556817},
    {5030,"羽月要塞",0,1,-4317.47,3287.35,18.2864,3.12825},
    {5031,"萨兰纳尔",0,1,-4525.63,-791.364,-42.3639,1.09938},
    {5032,"塞拉摩",0,1,-3641.3,-4358.93,8.35467,3.81559},
    {5033,"塔伦迪斯营地",0,1,2735.06,-3867.44,98.6548,3.56139},
    {5034,"刺枝林地",0,1,6209.51,-1927.01,569.393,3.82137},
    {5035,"林歌神殿",0,1,2924.92,-3206.94,169.344,5.18437},
    {5036,"丧钟镇",1,0,1843.5,1590,93.2971,3.08757},
    {5037,"布瑞尔",1,0,2259.25,290.43,34.1137,0.987414},
    {5038,"瑟伯切尔",1,0,504.534,1539.08,129.502,1.35812},
    {5039,"塔伦米尔",1,0,-34.1467,-923.366,54.5576,0.15019},
    {5040,"落锤镇",1,0,-941.007,-3526.66,70.935,3.48668},
    {5041,"恶齿村",1,0,-557.226,-4581.27,9.5884,1.01724},
    {5042,"卡加斯",1,0,-6692.48,-2175.31,244.145,0.427571},
    {5043,"烈焰峰",1,0,-7501.51,-2183.08,165.926,6.07144},
    {5044,"斯通纳德",1,0,-10446.9,-3261.91,20.1795,5.02142},
    {5045,"格罗姆高营地",1,0,-12388.9,172.578,2.83358,1.91753},
    {5046,"亡灵壁垒",1,0,1711.99,-719.761,54.3351,4.66387},
    {5047,"试炼谷",1,1,-601.294,-4296.76,37.8115,1.65401},
    {5048,"森金村",1,1,-813.097,-4880.08,18.995,4.42647},
    {5049,"剃刀岭",1,1,326.81,-4706.65,15.3665,4.16414},
    {5050,"回音群岛",1,1,-1041.59,-5346.67,0.218679,4.0102},
    {5051,"纳拉其营地",1,1,-2919.35,-264.535,53.6197,0.409027},
    {5052,"血蹄村",1,1,-2240.91,-399.174,-9.42446,2.53353},
    {5053,"十字路口",1,1,-452.84,-2650.76,95.5209,0.241081},
    {5054,"陶拉祖营地",1,1,-2363.11,-1913.78,95.7829,0.165556},
    {5055,"莫尔杉营地",1,1,1035.62,-2106,122.946,1.60767},
    {5056,"碎木岗哨",1,1,2270.94,-2538.19,93.9198,0.060429},
    {5057,"佐拉姆加前哨站",1,1,3376.86,1013.05,3.34387,3.81699},
    {5058,"烈日石居",1,1,966.147,926.499,104.649,1.27231},
    {5059,"幽灵岗哨",1,1,-1224.46,1728.53,90.0592,0.831707},
    {5060,"葬影村",1,1,-1664.79,3091.67,30.5552,6.07818},
    {5061,"乱风岗",1,1,-5431.78,-2449.38,89.2848,2.32854},
    {5062,"莫沙彻营地",1,1,-4396.7,224.841,25.4136,4.93684},
    {5063,"蕨墙村",1,1,-3130.67,-2908.43,34.0976,1.42798},
    {5064,"血毒岗哨",1,1,5128.91,-343.506,355.035,3.39176},
    {5065,"瓦罗莫克",1,1,3608.59,-4414.43,113.047,1.62303},
    {5066,"火花之水港",1,1,948.335,-5033.39,5.73102,2.94837},
    {5067,"藏宝海湾",nil,0,-14297.2,530.993,8.77916,3.98863},
    {5068,"棘齿城",nil,1,-956.664,-3754.71,5.33239,0.996637},
    {5069,"加基森",nil,1,-7177.15,-3785.34,8.36981,6.10237},
    {5070,"热砂港",nil,1,-6908.08,-4801.39,8.15214,5.07916},
    {5071,"永望镇",nil,1,6725.69,-4619.44,720.909,4.66802},
    {5072,"永夜港",nil,1,7966.85,-2491.04,487.734,3.20562},
    {5073,"塞纳里奥要塞",nil,1,-6818.09,733.814,41.5661,2.3082},
    {5074,"马绍尔营地",nil,1,-6152.25,-1087.6,-201.435,0.707637},
    {5075,"圣光之愿礼拜堂",nil,0,2279.65,-5310.01,87.0759,5.07618},
    {5076,"瑟银哨塔",nil,0,-6506.47,-1149.95,307.708,4.18256},
    {5077,"翡翠圣地",nil,1,3986.71,-1293.58,250.144,5.74591},
    {5078,"沙漠赛道",nil,1,-6221.35,-3927.64,-58.7495,0.757735},
    {5079,"木喉要塞（费伍德据点）",nil,1,6808.73,-2091.08,624.962,5.93802},
    {5080,"泥链镇",nil,1,-4594.56,-3208.2,34.9253,4.64108},
    {5081,"泰拉比姆营地",nil,1,-8878.96,-6536.87,13.4836,1.52793},
    {5082,"鹰之守望",0,0,-3947.78,-1863.39,143.499,2.72093},
    {5083,"丹阿格拉斯",0,0,-3963.03,-1337.33,148.715,2.96833},
    {5084,"凯兰之眠",0,0,-11885,3148.16,17.137,1.58763},
    {5085,"乌鸦郡",0,0,-2055.72,1103.78,32.168,3.52581},
    {5086,"静守镇",0,0,-1323.29,1200.61,124.896,5.8061},
    {5087,"诺达纳尔",nil,1,5492.38,-3733.48,1594.16,2.87627},
    {5088,"鲁瑟兰村",0,1,8640.58,841.118,23.3464,0.05236},
}
for _, row in ipairs(townRows) do
    destinations[row[1]] = {name=row[2], team=row[3], map=row[4],
        x=row[5], y=row[6], z=row[7], o=row[8]}
end
travelPages[500] = {name="联盟据点：东部王国（1）", team=0, ids={5001,5002,5003,5004,5005,5006,5007,5008,5009,5010,5011,5012}}
travelRootPages[#travelRootPages+1] = 500
travelPages[501] = {name="联盟据点：东部王国（2）", team=0, ids={5013,5014,5015,5016,5017,5018,5019,5020,5021,5022,5023}}
travelRootPages[#travelRootPages+1] = 501
travelPages[510] = {name="联盟据点：卡利姆多", team=0, ids={5024,5025,5026,5027,5028,5029,5030,5031,5032,5033,5034,5035}}
travelRootPages[#travelRootPages+1] = 510
travelPages[520] = {name="部落据点：东部王国", team=1, ids={5036,5037,5038,5039,5040,5041,5042,5043,5044,5045,5046}}
travelRootPages[#travelRootPages+1] = 520
travelPages[530] = {name="部落据点：卡利姆多（1）", team=1, ids={5047,5048,5049,5050,5051,5052,5053,5054,5055,5056,5057,5058}}
travelRootPages[#travelRootPages+1] = 530
travelPages[531] = {name="部落据点：卡利姆多（2）", team=1, ids={5059,5060,5061,5062,5063,5064,5065,5066}}
travelRootPages[#travelRootPages+1] = 531
travelPages[540] = {name="中立城镇、营地（1）", team=nil, ids={5067,5068,5069,5070,5071,5072,5073,5074,5075,5076,5077,5078}}
travelRootPages[#travelRootPages+1] = 540
travelPages[541] = {name="中立城镇、营地（2）", team=nil, ids={5079,5080,5081}}
travelRootPages[#travelRootPages+1] = 541

travelPages[502] = {name="联盟据点：新增城镇", team=0, ids={5082,5083,5084,5085,5086}}
travelRootPages[#travelRootPages+1] = 502
travelPages[511] = {name="联盟据点：鲁瑟兰村", team=0, ids={5088}}
travelRootPages[#travelRootPages+1] = 511
travelPages[542] = {name="中立城镇：诺达纳尔", ids={5087}}
travelRootPages[#travelRootPages+1] = 542

-- Raid travel is exterior only: keys, attunements and raid requirements remain core-controlled.
local raidRows = {
    {4001,"奥妮克希亚的巢穴",50,1,-4750.38,-3754.44,49.0485,0.785398},
    {4002,"熔火之心（洛索斯入口）",50,0,-7512.38,-1043.39,181.55,0.909809},
    {4003,"黑翼之巢（命令宝珠）",50,0,-7663.74,-1217.4,287.789,5.33945},
    {4004,"祖尔格拉布",60,0,-11916.2,-1206.9,92.2612,1.5708},
    {4005,"安其拉废墟",60,1,-8415.7,1502.44,30.6862,5.49779},
    {4006,"安其拉神殿",60,1,-8239.01,1993.25,129.071,4.01426},
    {4007,"纳克萨玛斯（传送入口）",60,0,3120.16,-3724.93,137.66,5.83567},
    {4008,"卡拉赞下层大厅",60,0,-11118.5,-2010.84,47.082,3.7},
    {4009,"卡拉赞之塔（卡拉赞外部入口区）",60,0,-11123,-2015.93,47.0999,0.634974},
    {4010,"翡翠圣殿",60,1,4819.06,-1746.33,1156.99,2.5},
    {4011,"木喉要塞（艾萨拉团队副本入口）",60,1,4724.58,-4911.79,134.967,4.2285},
}
for _, row in ipairs(raidRows) do
    destinations[row[1]] = {name=row[2], minLevel=row[3], map=row[4],
        x=row[5], y=row[6], z=row[7], o=row[8]}
end
travelPages[400] = {name="团队副本入口", ids={4001,4002,4003,4004,4005,4006,4007,4008,4009,4010,4011}}

local function SameFaction(player, destination)
    return destination.team == nil or destination.team == player:GetTeam()
end

local function CanUse(player)
    if player:IsDead() or player:IsInCombat() or player:HasUnitState(0x80)
        or player:InBattleground() or player:IsCasting() then
        player:SendBroadcastMessage("死亡、战斗、飞行、战场或施法中不能使用传送炉石。")
        return false
    end
    return true
end

local function ShowMenu(player, item, page)
    player:GossipClearMenu()
    local allowed = {}
    local function Add(icon, text, id)
        allowed[id] = true
        player:GossipMenuAddItem(icon, text, SENDER, id)
    end
    if page == 0 then
        Add(0, "返回绑定旅店（原炉石读条和冷却）", HOME)
        for _, id in ipairs({10, 11, 12, 20, 21, 22}) do
            local d = destinations[id]
            if SameFaction(player, d) then Add(2, "传送：" .. d.name, id) end
        end
        for _, id in ipairs(travelRootPages) do
            local pageInfo = travelPages[id]
            if SameFaction(player, pageInfo) then Add(0, pageInfo.name, id) end
        end
        for _, id in ipairs({100, 200, 300}) do Add(0, dungeonPages[id].name, id) end
        Add(0, travelPages[400].name, 400)
    else
        for _, id in ipairs((dungeonPages[page] or travelPages[page]).ids) do
            local d = destinations[id]
            if SameFaction(player, d) then
                Add(2, d.name .. (d.minLevel and "（最低 " .. d.minLevel .. " 级）" or ""), id)
            end
        end
        Add(0, "返回主菜单", 0)
    end
    Add(0, "关闭", CLOSE)
    pending[player:GetGUIDLow()] = {item=item:GetGUIDLow(), expires=os.time()+120, allowed=allowed}
    player:GossipSendMenu(100, item)
end

local function Hello(event, player, item)
    pending[player:GetGUIDLow()] = nil
    player:GossipClearMenu()
    if not CanUse(player) then
        player:GossipComplete()
        return false
    end
    ShowMenu(player, item, 0)
    -- This port uses false to suppress the item's normal spell cast.
    return false
end

local function Select(event, player, item, sender, intid)
    local guid = player:GetGUIDLow()
    local menu = pending[guid]
    pending[guid] = nil -- Single use; reject duplicate or unsolicited selections.
    player:GossipComplete()
    if not menu or sender ~= SENDER or item:GetEntry() ~= ITEM
        or item:GetGUIDLow() ~= menu.item or os.time() > menu.expires
        or not menu.allowed[intid] then
        return false
    end
    if intid == CLOSE or not CanUse(player) then return false end
    if intid == 0 or dungeonPages[intid] or travelPages[intid] then
        ShowMenu(player, item, intid)
        return false
    end
    if intid == HOME then
        if player:HasSpellCooldown(HOME_SPELL) then
            player:SendBroadcastMessage("炉石尚在冷却中。")
        else
            -- Keep the item as cast source so the core applies item cooldowns.
            player:CastCustomSpell(player, HOME_SPELL, false, nil, nil, nil, item)
        end
        return false
    end
    local d = destinations[intid]
    if not d or not SameFaction(player, d) then return false end
    if d.minLevel and player:GetLevel() < d.minLevel then
        player:SendBroadcastMessage("该副本入口传送至少需要 " .. d.minLevel .. " 级。")
        return false
    end
    if not player:Teleport(d.map, d.x, d.y, d.z, d.o) then
        player:SendBroadcastMessage("传送失败，请稍后再试。")
    end
    return false
end

RegisterItemGossipEvent(ITEM, 1, Hello)
RegisterItemGossipEvent(ITEM, 2, Select)
RegisterPlayerEvent(4, function(event, player) pending[player:GetGUIDLow()] = nil end)
print("[HearthstoneTeleporter] Loaded: item 6948, faction capitals, 88 towns/outposts, 22 dungeon entrances, 11 raid entrances and home spell.")
