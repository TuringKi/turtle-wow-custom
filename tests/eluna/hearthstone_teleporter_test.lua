-- Run from repository root with Lua 5.2. No server or database required.
local handlers, logout = {}, nil
function RegisterItemGossipEvent(entry, event, fn)
    assert(entry == 6948); handlers[event] = fn
end
function RegisterPlayerEvent(event, fn) assert(event == 4); logout = fn end
dofile('lua_scripts/hearthstone_teleporter.lua')
local item = {GetEntry=function() return 6948 end, GetGUIDLow=function() return 7 end}
local function Player(team)
    local p = {team=team, menu={}, messages={}}
    function p:GetGUIDLow() return 42 end
    function p:GetTeam() return self.team end
    function p:GetLevel() return self.level or 60 end
    function p:IsDead() return self.dead or false end
    function p:IsInCombat() return self.combat or false end
    function p:HasUnitState(mask) assert(mask == 0x80); return self.taxi or false end
    function p:InBattleground() return self.bg or false end
    function p:IsCasting() return self.casting or false end
    function p:SendBroadcastMessage(text) table.insert(self.messages, text) end
    function p:GossipClearMenu() self.menu = {} end
    function p:GossipComplete() self.closed = true end
    function p:GossipMenuAddItem(icon, text, sender, id) self.menu[id] = text end
    function p:GossipSendMenu(text, source) assert(text == 100 and source == item) end
    function p:HasSpellCooldown(spell) assert(spell == 8690); return self.cooldown end
    function p:CastCustomSpell(target, spell, triggered, b1, b2, b3, source)
        assert(target == self and spell == 8690 and triggered == false)
        assert(b1 == nil and b2 == nil and b3 == nil and source == item)
        self.cast = true
    end
    function p:Teleport(map, x, y, z, o)
        self.destination = {map, x, y, z, o}; return not self.failTeleport
    end
    return p
end
local function open(p) assert(handlers[1](1, p, item) == false) end
local function choose(p, id, source, sender)
    assert(handlers[2](2, p, source or item, sender or 6948, id) == false)
end
for _, team in ipairs({0, 1}) do
    local p = Player(team); open(p)
    assert(p.menu[1] and p.menu[99])
    for _, id in ipairs({10,11,12,20,21,22}) do
        assert((p.menu[id] ~= nil) == ((id < 20) == (team == 0)))
    end
    choose(p, team == 0 and 10 or 20); assert(p.destination)
    p.destination = nil; choose(p, team == 0 and 10 or 20); assert(not p.destination)
end
for _, flag in ipairs({'dead','combat','taxi','bg','casting'}) do
    local p = Player(0); p[flag] = true; open(p); assert(next(p.menu) == nil)
    p[flag] = false; open(p); p[flag] = true; choose(p,10); assert(not p.destination)
end
local p = Player(0)
choose(p,10); assert(not p.destination)
open(p); choose(p,20); assert(not p.destination) -- forged enemy destination
open(p); choose(p,999); assert(not p.destination)
open(p); choose(p,10,item,123); assert(not p.destination)
open(p); choose(p,10,{GetEntry=function() return 6948 end,GetGUIDLow=function() return 8 end})
assert(not p.destination)
open(p); logout(4,p); choose(p,10); assert(not p.destination)
local originalTime = os.time
open(p); os.time = function() return originalTime()+121 end
choose(p,10); assert(not p.destination); os.time = originalTime
open(p); choose(p,1); assert(p.cast)
p.cast = nil; p.cooldown = true; open(p); choose(p,1); assert(not p.cast)
p.cooldown = nil; p.failTeleport = true; open(p); choose(p,10)
assert(p.messages[#p.messages] == '传送失败，请稍后再试。')
print('PASS: faction menus, state checks, forged/repeated/expired selections, logout, home cooldown and failed teleport.')

-- Every dungeon option remains outside instances and is reachable on its page.
local seen = {}
for _, team in ipairs({0,1}) do
    for _, page in ipairs({100,200,300}) do
        local p = Player(team); open(p); choose(p,page)
        assert(p.menu[0] and p.menu[99] and not p.menu[1])
        local ids = {}
        for id in pairs(p.menu) do if id >= 1000 then table.insert(ids,id) end end
        if page == 100 then
            assert((p.menu[1001] ~= nil) == (team == 1))
            assert((p.menu[1006] ~= nil) == (team == 0))
        end
        for _, id in ipairs(ids) do
            open(p); choose(p,page); choose(p,id)
            assert(p.destination and (p.destination[1] == 0 or p.destination[1] == 1))
            seen[id] = true
        end
        open(p); choose(p,page); choose(p,0); assert(p.menu[1] and p.menu[100])
    end
end
local count = 0; for _ in pairs(seen) do count = count+1 end; assert(count == 22)
local p = Player(0)
open(p); choose(p,3001); assert(not p.destination) -- not shown on root page
open(p); choose(p,100); choose(p,3001); assert(not p.destination) -- wrong page
open(p); choose(p,100); choose(p,1001); assert(not p.destination) -- enemy capital
p.level = 39; open(p); choose(p,300); choose(p,3001); assert(not p.destination)
p.level = 40; open(p); choose(p,300); choose(p,3001); assert(p.destination)
p.destination = nil
open(p); choose(p,300); p.combat = true; choose(p,3001); assert(not p.destination)
print('PASS: all 22 outdoor entrances, page navigation, faction rules, level threshold and combat recheck.')
