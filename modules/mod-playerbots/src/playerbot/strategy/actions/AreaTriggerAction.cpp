
#include "playerbot/playerbot.h"
#include "AreaTriggerAction.h"
#include "playerbot/PlayerbotAIConfig.h"

using namespace ai;

bool ReachAreaTriggerAction::Execute(Event& event)
{
    Player* requester = event.getOwner() ? event.getOwner() : GetMaster();
    uint32 triggerId;

    if (ai->IsRealPlayer() || ai->IsAreaTriggerRelaySuppressed())
        return false;

    WorldPacket p(event.getPacket());
    p.rpos(0);
    p >> triggerId;

    AreaTriggerEntry const* atEntry = sAreaTriggerStore.LookupEntry(triggerId);
    if(!atEntry)
        return false;

    AreaTrigger const* at = sObjectMgr.GetAreaTrigger(triggerId);
    if (!at)
    {
        WorldPacket p1(CMSG_AREATRIGGER);
        p1 << triggerId;
        p1.rpos(0);
        bot->GetSession()->HandleAreaTriggerOpcode(p1);

        return true;
    }

    if (bot->GetMapId() != atEntry->mapid || bot->GetDistance(atEntry->x, atEntry->y, atEntry->z) > sPlayerbotAIConfig.sightDistance)
    {
        ai->TellError(requester, "I won't follow: too far away");
        return true;
    }

    // Use the same acceptance zone as WorldSession::HandleAreaTriggerOpcode.
    // Navmesh paths can end short of a portal's center, particularly at walls.
    if (::IsPointInAreaTriggerZone(atEntry, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 5.0f))
    {
        context->GetValue<LastMovement&>("last area trigger")->Get().lastAreaTrigger = 0;
        WorldPacket trigger(CMSG_AREATRIGGER);
        trigger << triggerId;
        bot->GetSession()->HandleAreaTriggerOpcode(trigger);
        return true;
    }

    MotionMaster &mm = *bot->GetMotionMaster();
    mm.MovePoint(triggerId, atEntry->x, atEntry->y, atEntry->z, MOVE_PATHFINDING | MOVE_RUN_MODE);
    const float distance = bot->GetDistance(atEntry->x, atEntry->y, atEntry->z, DIST_CALC_NONE);
    const float duration = 1000.0f * distance / bot->GetSpeed(MOVE_RUN) + sPlayerbotAIConfig.reactDelay;
    ai->TellError(requester, "Wait for me");
    SetDuration(duration);
    context->GetValue<LastMovement&>("last area trigger")->Get().lastAreaTrigger = triggerId;

    return true;
}



bool AreaTriggerAction::Execute(Event& event)
{
    LastMovement& movement = context->GetValue<LastMovement&>("last area trigger")->Get();

    uint32 triggerId = movement.lastAreaTrigger;

    // Clear pending entry while an exit-sensitive run suppresses portal
    // relays, so it cannot fire after the module releases this bot.
    if (ai->IsAreaTriggerRelaySuppressed())
    {
        movement.lastAreaTrigger = 0;
        return false;
    }

    AreaTriggerEntry const* atEntry = sAreaTriggerStore.LookupEntry(triggerId);
    if(!atEntry)
    {
        movement.lastAreaTrigger = 0;
        return false;
    }

    // Recheck at execution time; do not consume a pending entry while still
    // approaching it, or relay a trigger from a different map.
    if (!::IsPointInAreaTriggerZone(atEntry, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 5.0f))
        return false;

    movement.lastAreaTrigger = 0;

    AreaTrigger const* at = sObjectMgr.GetAreaTrigger(triggerId);
    if (!at)
        return true;

    WorldPacket p(CMSG_AREATRIGGER);
    p << triggerId;
    p.rpos(0);
    bot->GetSession()->HandleAreaTriggerOpcode(p);
    return true;
}
