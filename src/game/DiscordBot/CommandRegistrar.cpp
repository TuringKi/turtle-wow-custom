#include "GMCommandHandler.hpp"
#include "LoginCommandHandler.hpp"
#include "PlayerCommandHandler.hpp"


namespace DiscordBot
{
    void RegisterHandlers()
    {
        new GMCommandHandler{};
        new PlayerCommandHandler{};
        new LoginCommandHandler{};
    }
} // namespace DiscordBot