#ifndef MANGOS_BOT_SESSION_H
#define MANGOS_BOT_SESSION_H

#include <string>

// WorldSession assigns <PBOT> to null-socket sessions. Retain the historical
// markers used by other bot login paths; an empty address is not proof of a bot.
inline bool IsBotSessionAddress(std::string const& address)
{
    return address == "<PBOT>" || address == "<BOT>" || address == "disconnected/bot";
}

#endif
