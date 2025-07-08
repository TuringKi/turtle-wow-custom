#pragma once

#include "Group.h"

#include "../Value.h"

namespace ai
{
    class RtiTargetValue : public UnitCalculatedValue
    {
    public:
        RtiTargetValue(PlayerbotAI* ai) : UnitCalculatedValue(ai) {}

    public:
        static RaidTargetIcon GetRtiIndex(string rti)
        {
            if (rti == "star")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_STAR;
            }
            else if (rti == "circle")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_CIRCLE;
            }
            else if (rti == "diamond")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_DIAMOND;
            }
            else if (rti == "triangle")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_TRIANGLE;
            }
            else if (rti == "moon")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_MOON;
            }
            else if (rti == "square")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_SQUARE;
            }
            else if (rti == "cross")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_CROSS;
            }
            else if (rti == "skull")
            {
                return RaidTargetIcon::RAID_TARGET_ICON_SKULL;
            }

            assert(false);
            return RaidTargetIcon::RAID_TARGET_ICON_STAR;
        }

        Unit* Calculate()
        {
            Group* group = bot->GetGroup();
            if (!group)
            {
                return NULL;
            }

            string rti = AI_VALUE(string, "rti");
            auto index = GetRtiIndex(rti);

            if (index == -1)
            {
                return NULL;
            }

            ObjectGuid guid = group->GetTargetWithIcon(index);
            if (!guid)
            {
                return NULL;
            }

            Unit* unit = ai->GetUnit(guid);
            if (!unit || unit->IsDead())
            {
                return NULL;
            }

            return unit;
        }
    };
} // namespace ai
