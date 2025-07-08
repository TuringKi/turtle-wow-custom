#include "botpch.h"


#include "FollowLineStrategy.h"
#include "playerbot.h"

using namespace ai;

NextAction** FollowLineStrategy::getDefaultActions() { return NextAction::array(0, new NextAction("follow line", 1.0f), NULL); }