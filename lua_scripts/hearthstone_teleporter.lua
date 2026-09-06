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
        for _, id in ipairs({100, 200, 300}) do Add(0, dungeonPages[id].name, id) end
    else
        for _, id in ipairs(dungeonPages[page].ids) do
            local d = destinations[id]
            if SameFaction(player, d) then
                Add(2, d.name .. "（最低 " .. d.minLevel .. " 级）", id)
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
    if intid == 0 or dungeonPages[intid] then
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
print("[HearthstoneTeleporter] Loaded: item 6948, faction capitals, 22 dungeon entrances and home spell.")
