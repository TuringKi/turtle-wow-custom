#pragma once

#include "botpch.h"

#include "../Trigger.h"
#include "../values/LastMovementValue.h"

namespace ai
{
    class WithinAreaTrigger : public Trigger
    {
    public:
        WithinAreaTrigger(PlayerbotAI* ai) : Trigger(ai, "within area trigger") {}

        virtual bool IsActive()
        {


            LastMovement& movement = context->GetValue<LastMovement&>("last movement")->Get();
            if (!movement.lastAreaTrigger)
            {
                return false;
            }

            AreaTriggerEntry const* atEntry = sObjectMgr.GetAreaTrigger(movement.lastAreaTrigger);
            if (!atEntry)
            {
                return false;
            }

            auto const* at = sObjectMgr.GetAreaTriggerTeleport(movement.lastAreaTrigger);
            if (!at)
            {
                return false;
            }

            return IsPointInAreaTriggerZone(atEntry, bot->GetMapId(), bot->GetPositionX(), bot->GetPositionY(), bot->GetPositionZ(), 0.5f);
        }
    };
} // namespace ai
