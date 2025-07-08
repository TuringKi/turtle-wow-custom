#include "../../botpch.h"


#include "../playerbot.h"
#include "AiObjectContext.h"
#include "NamedObjectContext.h"
#include "StrategyContext.h"
#include "actions/ActionContext.h"
#include "actions/ChatActionContext.h"
#include "actions/WorldPacketActionContext.h"
#include "triggers/ChatTriggerContext.h"
#include "triggers/TriggerContext.h"
#include "triggers/WorldPacketTriggerContext.h"
#include "values/ValueContext.h"

using namespace ai;

AiObjectContext::AiObjectContext(PlayerbotAI* ai) : PlayerbotAIAware(ai)
{
    strategyContexts.Add(new StrategyContext());
    strategyContexts.Add(new MovementStrategyContext());
    strategyContexts.Add(new AssistStrategyContext());
    strategyContexts.Add(new QuestStrategyContext());

    actionContexts.Add(new ActionContext());
    actionContexts.Add(new ChatActionContext());
    actionContexts.Add(new WorldPacketActionContext());

    triggerContexts.Add(new TriggerContext());
    triggerContexts.Add(new ChatTriggerContext());
    triggerContexts.Add(new WorldPacketTriggerContext());

    valueContexts.Add(new ValueContext());
}

void AiObjectContext::Update()
{
    strategyContexts.Update();
    triggerContexts.Update();
    actionContexts.Update();
    valueContexts.Update();
}

void AiObjectContext::Reset()
{
    strategyContexts.Reset();
    triggerContexts.Reset();
    actionContexts.Reset();
    valueContexts.Reset();
}
