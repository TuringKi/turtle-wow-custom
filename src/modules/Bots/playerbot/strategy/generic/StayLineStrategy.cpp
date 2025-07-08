#include "botpch.h"

#include "StayLineStrategy.h"
#include "playerbot.h"

using namespace ai;

NextAction** StayLineStrategy::getDefaultActions() { return NextAction::array(0, new NextAction("stay line", 50.0f), NULL); }