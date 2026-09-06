#pragma once

#include <initializer_list>
#include <string>
#include <vector>

namespace LFT
{
inline std::string DungeonKey(std::string const& name)
{
    std::string key;
    for (unsigned char c : name)
    {
        if (c >= 'A' && c <= 'Z') c += 'a' - 'A';
        if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c >= 128)
            key += char(c);
    }
    if (key.compare(0, 3, "the") == 0) key.erase(0, 3);
    return key;
}

struct DungeonEntrance
{
    unsigned trigger;
    unsigned map;
    std::initializer_list<char const*> names;
    unsigned teleportSpell = 0;
};

// Use portal destinations inside the instance, never a fuzzy game_tele match.
// Wings sharing a map deliberately have distinct portal IDs.
inline DungeonEntrance const* FindDungeonEntrance(std::string const& name)
{
    static DungeonEntrance const entrances[] = {
        {2230, 389, {"Ragefire Chasm", "怒焰裂谷", "rfc"}},
        {228, 43, {"Wailing Caverns", "哀嚎洞穴", "wc"}},
        {78, 36, {"Deadmines", "死亡矿井", "dm"}},
        {145, 33, {"Shadowfang Keep", "影牙城堡", "sfk"}},
        {101, 34, {"Stockade", "Stockades", "Stormwind Stockades", "暴风城监狱", "stocks"}},
        {257, 48, {"Blackfathom Deeps", "黑暗深渊", "bfd"}},
        {324, 90, {"Gnomeregan", "诺莫瑞根", "gnomer"}},
        {244, 47, {"Razorfen Kraul", "剃刀沼泽", "rfk"}},
        {45, 189, {"Scarlet Monastery Graveyard", "Scarlet Graveyard", "血色修道院墓地", "血色墓地", "smgy"}},
        {614, 189, {"Scarlet Monastery Library", "Scarlet Library", "血色修道院图书馆", "血色图书馆", "smlib"}},
        {612, 189, {"Scarlet Monastery Armory", "Scarlet Armory", "血色修道院军械库", "血色军械库", "血色武器库", "smarmory"}},
        {610, 189, {"Scarlet Monastery Cathedral", "Scarlet Cathedral", "血色修道院大教堂", "血色大教堂", "血色教堂", "smcath"}},
        {442, 129, {"Razorfen Downs", "剃刀高地", "rfd"}},
        {286, 70, {"Uldaman", "奥达曼", "ulda"}},
        {924, 209, {"Zul'Farrak", "祖尔法拉克", "zf"}},
        {3133, 349, {"Maraudon", "Maraudon Orange", "Maraudon Orange Crystals", "玛拉顿", "玛拉顿橙色区", "maraorange"}},
        {3134, 349, {"Maraudon Purple", "Maraudon Purple Crystals", "玛拉顿紫色区", "marapurple"}},
        {3133, 349, {"Maraudon Princess", "玛拉顿公主区", "maraprincess"}, 21128},
        {446, 109, {"Sunken Temple", "Temple of Atal'Hakkar", "沉没的神庙", "阿塔哈卡神庙", "st"}},
        {1466, 230, {"Blackrock Depths", "Blackrock Depths Arena", "Blackrock Depths Emperor", "黑石深渊", "黑石深渊竞技场", "黑石深渊皇帝", "brd", "brdarena", "brdemp"}},
        {1468, 229, {"Blackrock Spire", "Lower Blackrock Spire", "黑石塔", "黑石塔下层", "lbrs"}},
        {3183, 429, {"Dire Maul East", "厄运之槌东区", "厄运东", "dme"}},
        {3186, 429, {"Dire Maul West", "厄运之槌西区", "厄运西", "dmw"}},
        {3189, 429, {"Dire Maul North", "厄运之槌北区", "厄运北", "dmn"}},
        {2567, 289, {"Scholomance", "通灵学院", "scholo"}},
        {2217, 329, {"Stratholme", "Stratholme Live", "Stratholme Living", "Stratholme: Scarlet Bastion", "斯坦索姆", "斯坦索姆血色区", "stratlive"}},
        {2214, 329, {"Stratholme Undead", "Stratholme Dead", "Stratholme: Undead District", "斯坦索姆亡灵区", "stratud"}},
        {107, 35, {"Stormwind Vault", "暴风城地牢", "swv"}},
        {1632, 269, {"Black Morass", "Caverns of Time: Black Morass", "黑色沼泽", "时光之穴黑色沼泽", "cotbm"}},
        {5008, 800, {"Karazhan Crypt", "Karazhan Crypts", "卡拉赞墓穴", "kc"}},
        {5004, 802, {"Crescent Grove", "新月林地", "tcg"}},
        {5009, 808, {"Hateforge Quarry", "仇恨熔炉采石场", "hfq"}},
        {5014, 815, {"Gilneas City", "吉尔尼斯城"}},
    };
    std::string const key = DungeonKey(name);
    for (auto const& entrance : entrances)
        for (auto alias : entrance.names)
            if (DungeonKey(alias) == key) return &entrance;
    return nullptr;
}

// The protocol uses ':' between choices, but some display names also contain
// a colon. Preserve recognized complete labels before splitting the next one.
inline std::vector<std::string> SplitDungeonChoices(std::string const& text)
{
    std::vector<std::string> choices;
    size_t begin = 0;
    while (begin <= text.size())
    {
        size_t end = text.find(':', begin);
        if (end != std::string::npos)
        {
            size_t next = text.find(':', end + 1);
            std::string combined = text.substr(begin, next == std::string::npos ? next : next - begin);
            if (FindDungeonEntrance(combined)) end = next;
        }
        choices.push_back(text.substr(begin, end == std::string::npos ? end : end - begin));
        if (end == std::string::npos) break;
        begin = end + 1;
    }
    return choices;
}
}
