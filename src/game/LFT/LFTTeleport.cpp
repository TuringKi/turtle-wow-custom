#include "LFTMgr.h"
#include "LFTDungeonEntrances.h"
#include "Chat.h"
#include "Config/Config.h"
#include "Group.h"
#include "MapManager.h"
#include "MapPersistentStateMgr.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "SpellMgr.h"
#include "World.h"
#include <optional>

namespace
{
std::optional<AreaTriggerTeleport> PartyEntrance(std::string const& instance)
{
    auto const* known = LFT::FindDungeonEntrance(instance);
    std::string const key = "LFT.Teleport.Entrance." + LFT::DungeonKey(instance);
    int32 const configured = sConfig.GetIntDefault(key.c_str(), 0);
    if (configured <= 0 && !known) return {};
    uint32 const id = configured > 0 ? uint32(configured) : known->trigger;
    auto const* portal = sObjectMgr.GetAreaTriggerTeleport(id);
    if (!portal || !sObjectMgr.GetAreaTrigger(id)) return {};
    AreaTriggerTeleport entrance = *portal;
    if (configured <= 0 && known->teleportSpell)
    {
        auto const* location = sSpellMgr.GetSpellTargetPosition(known->teleportSpell);
        if (!location) return {};
        entrance.destination = *location;
    }
    auto const& dest = entrance.destination;
    auto const* map = sMapStorage.LookupEntry<MapEntry>(dest.mapId);
    if (!map || !map->IsNonRaidDungeon() || map->maxPlayers < 5 ||
        (configured <= 0 && dest.mapId != known->map) ||
        !MapManager::IsValidMapCoord(dest.mapId, dest.x, dest.y, dest.z, dest.o))
        return {};
    return entrance;
}
}

bool LFTManager::ValidateTeleportDestinations(Player* player, std::vector<std::string> const& instances) const
{
    if (!sConfig.GetBoolDefault("LFT.Teleport.Enable", false)) return true;
    for (auto const& instance : instances)
    {
        if (PartyEntrance(instance)) continue;
        Send(player, "S2C_QUEUE_ERROR;invalid");
        ChatHandler(player).PSendSysMessage("LFT: no verified inside entrance for '%s'. Select a specific dungeon wing or ask an administrator to configure its entrance.", instance.c_str());
        return false;
    }
    return true;
}

bool LFTManager::TeleportGroupToInstance(Offer const& offer)
{
    if (!sConfig.GetBoolDefault("LFT.Teleport.Enable", false)) return true;
    auto fail = [&](std::string const& reason)
    {
        sLog.outError("LFT: party teleport for '%s' failed: %s", offer.instance.c_str(), reason.c_str());
        for (auto const& role : offer.roles)
            if (Player* player = GetPlayer(role.first))
                ChatHandler(player).PSendSysMessage("LFT: %s. Your party is kept; resolve this and queue again to enter together.", reason.c_str());
        return false;
    };
    auto const entrance = PartyEntrance(offer.instance);
    if (!entrance) return fail("no verified inside entrance");
    if (offer.roles.size() != 5 || offer.accepted.size() != offer.roles.size())
        return fail("all five members must accept first");

    std::vector<Player*> members;
    Group* group = nullptr;
    for (auto const& role : offer.roles)
    {
        Player* player = GetPlayer(role.first);
        if (!player || !player->GetSession() || !player->IsInWorld()) return fail("a member is offline or loading");
        if (!group) group = player->GetGroup();
        if (!group || player->GetGroup() != group || group->GetMembersCount() != 5 || group->isRaidGroup())
            return fail("the matched five-person party has changed");
        if (!player->IsAlive() || player->IsBeingTeleported() || player->IsInCombat() || player->IsTaxiFlying() ||
            player->InBattleGround() || player->InBattleGroundQueue())
            return fail(std::string(player->GetName()) + " is dead, busy, in combat, flying or in a battleground queue");
        if (entrance->requiredPhase > sWorld.GetContentPhase()) return fail("the dungeon is not available in this content phase");
        if (!player->IsGameMaster())
        {
            uint32 const mapId = entrance->destination.mapId;
            bool const lunaticException = (mapId == 36 || mapId == 43 || mapId == 389 || mapId == 822) && player->HasChallenge(CHALLENGE_LUNATIC);
            if (player->GetLevel() < entrance->requiredLevel && !sWorld.getConfig(CONFIG_BOOL_INSTANCE_IGNORE_LEVEL) && !lunaticException)
                return fail(std::string(player->GetName()) + " does not meet the entrance level requirement");
            if (entrance->requiredCondition && !IsConditionSatisfied(entrance->requiredCondition, player, player->GetMap(), player, CONDITION_FROM_AREATRIGGER))
                return fail(std::string(player->GetName()) + " does not meet the entrance quest/item condition");
        }
        members.push_back(player);
    }

    Player* leader = GetPlayer(group->GetLeaderGuid());
    if (!leader || !offer.roles.count(leader->GetObjectGuid())) return fail("the party leader changed");
    auto const& dest = entrance->destination;
    auto* chosenSave = leader->GetBoundInstanceSaveForSelfOrGroup(dest.mapId);
    // Never overwrite a conflicting permanent lockout to force a match.
    for (Player* player : members)
        if (auto* bind = player->GetBoundInstance(dest.mapId))
            if (bind->perm && bind->state != chosenSave) return fail("members have incompatible instance lockouts");

    // Create/reuse ONE map and bind the group before scheduling any member.
    // Otherwise independent far-teleport acknowledgements can create copies.
    auto* target = static_cast<DungeonMap*>(sMapMgr.CreateMap(dest.mapId, leader));
    if (!target) return fail("the instance could not be created");
    uint32 arriving = 0;
    for (Player* player : members)
    {
        if (!player->CheckInstanceCount(target->GetInstanceId())) return fail(std::string(player->GetName()) + " has reached the instance entry limit");
        if (player->GetMap() == target) continue; // CanEnter asserts for existing members.
        if (!target->CanEnter(player)) return fail(std::string(player->GetName()) + " cannot enter the instance");
        if (!player->IsGameMaster()) ++arriving;
    }
    if (target->GetPlayersCountExceptGMs() + arriving > target->GetMaxPlayers()) return fail("the instance has insufficient room for the whole party");
    if (auto* bind = group->GetBoundInstance(dest.mapId))
    {
        if (bind->state != target->GetPersistanceState()) return fail("the party instance binding changed");
    }
    else
        group->BindToInstance(target->GetPersistanceState(), false);

    for (Player* player : members)
    {
        uint32 const options = player->GetMapId() == dest.mapId && player->GetInstanceId() != target->GetInstanceId() ? TELE_TO_FORCE_MAP_CHANGE : 0;
        if (!player->TeleportTo(dest.mapId, dest.x, dest.y, dest.z, dest.o, options))
            return fail(std::string(player->GetName()) + " could not begin teleporting");
    }
    sLog.outBasic("LFT: scheduled all %u party members into '%s', map %u instance %u", uint32(members.size()), offer.instance.c_str(), dest.mapId, target->GetInstanceId());
    return true;
}
