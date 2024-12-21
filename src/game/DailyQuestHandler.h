#pragma once
#include <Common.h>
#include <SystemConfig.h>
#include <ctime>
#include <vector>

constexpr uint32 CheckUpdateTimer = 60 * IN_MILLISECONDS;

class DailyQuestHandler
{
public:
    DailyQuestHandler() : m_nextResetTime(0), m_shouldCheckUpdate(CheckUpdateTimer) {}

    void LoadFromDB(bool quests);
    void Update(uint32 diff);

private:
    time_t m_nextResetTime;
    uint32 m_shouldCheckUpdate;
    turtle_vector<uint32, Category_DailyQuest> m_questIds;
};

extern DailyQuestHandler sDailyQuestHandler;