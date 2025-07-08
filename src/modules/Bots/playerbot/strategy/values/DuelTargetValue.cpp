#include "ObjectMgr.h"
#include "botpch.h"

#include "../../playerbot.h"
#include "DuelTargetValue.h"

using namespace ai;

Unit* DuelTargetValue::Calculate() { return bot->m_duel ? sObjectAccessor.FindPlayer(bot->m_duel->opponent) : NULL; }
