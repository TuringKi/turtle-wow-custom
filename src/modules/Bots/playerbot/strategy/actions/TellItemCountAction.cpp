#include "botpch.h"


#include "../../playerbot.h"
#include "../values/ItemCountValue.h"
#include "TellItemCountAction.h"

using namespace ai;

bool TellItemCountAction::Execute(Event event)
{
    string text = event.getParam();
    list<Item*> found = parseItems(text);
    for (list<Item*>::iterator i = found.begin(); i != found.end(); i++)
    {
        TellItem((*i)->GetProto(), (*i)->GetCount());
    }

    return true;
}
