#include "botpch.h"


#include "../../playerbot.h"
#include "PossibleTargetsValue.h"

#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"

using namespace ai;
using namespace MaNGOS;

void PossibleTargetsValue::FindUnits(list<Unit*>& targets)
{
    MaNGOS::AnyUnfriendlyUnitInObjectRangeCheck u_check(bot, bot, range);
    MaNGOS::UnitListSearcher<MaNGOS::AnyUnfriendlyUnitInObjectRangeCheck> searcher(targets, u_check);
    Cell::VisitAllObjects(bot, searcher, range);
}

bool PossibleTargetsValue::AcceptUnit(Unit* unit) { return !unit->HasFlag(UNIT_FIELD_FLAGS, UNIT_FLAG_SPAWNING) && (unit->IsHostileTo(bot) || (unit->GetLevel() > 1 && !unit->IsFriendlyTo(bot))); }
