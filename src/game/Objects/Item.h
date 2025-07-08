/*
 * Copyright (C) 2005-2011 MaNGOS <http://getmangos.com/>
 * Copyright (C) 2009-2011 MaNGOSZero <https://github.com/mangos/zero>
 * Copyright (C) 2011-2016 Nostalrius <https://nostalrius.org>
 * Copyright (C) 2016-2017 Elysium Project <https://github.com/elysium-project>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef MANGOSSERVER_ITEM_H
#define MANGOSSERVER_ITEM_H

#include "Common.h"
#include "ItemPrototype.h"
#include "LootMgr.h"
#include "Object.h"

class SpellEntry;
class Bag;
class Field;
class QueryResult;
class Unit;
struct ItemRandomPropertiesEntry;

struct ItemSetEffect
{
    uint32 setid = 0;
    uint32 item_count = 0;
    SpellEntry const* spells[8] = {};
};


enum BuyResult
{
    BUY_ERR_CANT_FIND_ITEM = 0,
    BUY_ERR_ITEM_ALREADY_SOLD = 1,
    BUY_ERR_NOT_ENOUGHT_MONEY = 2,
    BUY_ERR_SELLER_DONT_LIKE_YOU = 4,
    BUY_ERR_DISTANCE_TOO_FAR = 5,
    BUY_ERR_ITEM_SOLD_OUT = 7,
    BUY_ERR_CANT_CARRY_MORE = 8,
    BUY_ERR_RANK_REQUIRE = 11,
    BUY_ERR_REPUTATION_REQUIRE = 12
};

enum SellResult
{
    SELL_ERR_CANT_FIND_ITEM = 1,
    SELL_ERR_CANT_SELL_ITEM = 2, // merchant doesn't like that item
    SELL_ERR_CANT_FIND_VENDOR = 3, // merchant doesn't like you
    SELL_ERR_YOU_DONT_OWN_THAT_ITEM = 4, // you don't own that item
    SELL_ERR_UNK = 5, // nothing appears...
    SELL_ERR_ONLY_EMPTY_BAG = 6 // can only do with empty bags
};

// -1 from client enchantment slot number
enum EnchantmentSlot
{
    PERM_ENCHANTMENT_SLOT = 0,
    TEMP_ENCHANTMENT_SLOT = 1,
    MAX_INSPECTED_ENCHANTMENT_SLOT = 2,

    PROP_ENCHANTMENT_SLOT_0 = 3, // used with RandomSuffix
    PROP_ENCHANTMENT_SLOT_1 = 4, // used with RandomSuffix
    PROP_ENCHANTMENT_SLOT_2 = 5, // used with RandomSuffix
    PROP_ENCHANTMENT_SLOT_3 = 6,
    MAX_ENCHANTMENT_SLOT = 7
};

#define MAX_VISIBLE_ITEM_OFFSET 12

enum EnchantmentOffset
{
    ENCHANTMENT_ID_OFFSET = 0,
    ENCHANTMENT_DURATION_OFFSET = 1,
    ENCHANTMENT_CHARGES_OFFSET = 2
};

#define MAX_ENCHANTMENT_OFFSET 3

enum EnchantmentSlotMask
{
    ENCHANTMENT_CAN_SOULBOUND = 0x01,
    ENCHANTMENT_UNK1 = 0x02,
    ENCHANTMENT_UNK2 = 0x04,
    ENCHANTMENT_UNK3 = 0x08
};

enum ItemUpdateState
{
    ITEM_UNCHANGED = 0,
    ITEM_CHANGED = 1,
    ITEM_NEW = 2,
    ITEM_REMOVED = 3,
    ITEM_STASHED = 4 // Giperion Turtle: Item is moved from owner, but should be keeped in world
};

enum ItemLootUpdateState
{
    ITEM_LOOT_NONE = 0, // loot not generated
    ITEM_LOOT_TEMPORARY = 1, // generated loot is temporary (will deleted at loot window close)
    ITEM_LOOT_UNCHANGED = 2,
    ITEM_LOOT_CHANGED = 3,
    ITEM_LOOT_NEW = 4,
    ITEM_LOOT_REMOVED = 5
};

// masks for ITEM_FIELD_FLAGS field
enum ItemDynFlags
{
    ITEM_DYNFLAG_BINDED = 0x00000001, // set in game at binding
    ITEM_DYNFLAG_UNK1 = 0x00000002,
    ITEM_DYNFLAG_UNLOCKED = 0x00000004, // have meaning only for item with proto->LockId, if not set show as "Locked, req. lockpicking N"
    ITEM_DYNFLAG_WRAPPED = 0x00000008, // mark item as wrapped into wrapper container
    ITEM_DYNFLAG_UNK4 = 0x00000010, // can't repeat old note: appears red icon (like when item durability==0)
    ITEM_DYNFLAG_UNK5 = 0x00000020,
    ITEM_DYNFLAG_UNK6 = 0x00000040, // ? old note: usable
    ITEM_DYNFLAG_UNK7 = 0x00000080,
    ITEM_DYNFLAG_UNK8 = 0x00000100,
    ITEM_DYNFLAG_READABLE = 0x00000200, // can be open for read, it or item proto pagetText make show "Right click to read"
    ITEM_DYNFLAG_UNK10 = 0x00000400,
    ITEM_DYNFLAG_UNK11 = 0x00000800,
    ITEM_DYNFLAG_UNK12 = 0x00001000,
    ITEM_DYNFLAG_UNK13 = 0x00002000,
    ITEM_DYNFLAG_UNK14 = 0x00004000,
    ITEM_DYNFLAG_UNK15 = 0x00008000,
    ITEM_DYNFLAG_UNK16 = 0x00010000,
    ITEM_DYNFLAG_UNK17 = 0x00020000,

    ITEM_DYNFLAG_BOA = 0x00040000 // custom flag, server soulbound


};

enum ItemRequiredTargetType
{
    ITEM_TARGET_TYPE_CREATURE = 1,
    ITEM_TARGET_TYPE_DEAD = 2
};

#define MAX_ITEM_REQ_TARGET_TYPE 2

struct ItemRequiredTarget
{
    ItemRequiredTarget(ItemRequiredTargetType uiType, uint32 uiTargetEntry) : m_uiType(uiType), m_uiTargetEntry(uiTargetEntry) {}
    ItemRequiredTargetType m_uiType;
    uint32 m_uiTargetEntry;

    // helpers
    bool IsFitToRequirements(Unit* pUnitTarget) const;
};

bool ItemCanGoIntoBag(ItemPrototype const* proto, ItemPrototype const* pBagProto);

class Item : public Object
{
public:
    static Item* CreateItem(uint32 item, uint32 count, Player const* player = nullptr);
    Item* CloneItem(uint32 count, Player const* player = nullptr) const;

    Item();
    virtual ~Item();

    virtual bool Create(uint32 guidlow, uint32 itemid, ObjectGuid ownerGuid = ObjectGuid());
    void RemoveFromWorld() override;

    ItemPrototype const* GetProto() const;
    bool ChangeEntry(ItemPrototype const* pNewProto);

    ObjectGuid const& GetOwnerGuid() const { return GetGuidValue(ITEM_FIELD_OWNER); }
    void SetOwnerGuid(ObjectGuid guid) { SetGuidValue(ITEM_FIELD_OWNER, guid); }
    Player* GetOwner() const;

    void SetBinding(bool val) { ApplyModFlag(ITEM_FIELD_FLAGS, ITEM_DYNFLAG_BINDED, val); }
    bool IsSoulBound() const { return HasFlag(ITEM_FIELD_FLAGS, ITEM_DYNFLAG_BINDED) || HasFlag(ITEM_FIELD_FLAGS, ITEM_DYNFLAG_BOA); }
    bool IsAccountBound() const { return HasFlag(ITEM_FIELD_FLAGS, ITEM_DYNFLAG_BOA); }
    bool IsBindedNotWith(Player const* player) const;
    bool IsBoundByEnchant() const;
    virtual void SaveToDB(bool direct = false);
    virtual bool LoadFromDB(uint32 guidLow, ObjectGuid ownerGuid, Field* fields, uint32 entry);
    virtual void DeleteFromDB();
    void DeleteFromInventoryDB();
    void LoadLootFromDB(Field* fields);

    static void DeleteAllFromDB(uint32 guidLow);

    bool isWeapon() const { return GetProto()->Class == ITEM_CLASS_WEAPON; }
    bool isProjectile() const { return GetProto()->Class == ITEM_CLASS_PROJECTILE; }
    bool isOneHandedWeapon() const { return (isWeapon() && (GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_AXE || GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_SWORD || GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_MACE || GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_FIST || GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_DAGGER || GetProto()->SubClass == ITEM_SUBCLASS_WEAPON_EXOTIC)); }

    bool IsBag() const { return GetProto()->InventoryType == INVTYPE_BAG; }
    bool IsQuiver() const { return GetProto()->InventoryType == INVTYPE_BAG && GetProto()->Class == ITEM_CLASS_QUIVER; }
    bool IsBroken() const { return GetUInt32Value(ITEM_FIELD_MAXDURABILITY) > 0 && GetUInt32Value(ITEM_FIELD_DURABILITY) == 0; }
    bool CanBeTraded() const;
    void SetInTrade(bool b = true) { mb_in_trade = b; }
    bool IsInTrade() const { return mb_in_trade; }

    bool IsFitToSpellRequirements(SpellEntry const* spellInfo) const;
    bool IsTargetValidForItemUse(Unit* pUnitTarget);
    bool IsLimitedToAnotherMapOrZone(uint32 cur_mapId, uint32 cur_zoneId) const;

    Bag* ToBag()
    {
        if (IsBag())
            return reinterpret_cast<Bag*>(this);
        return nullptr;
    }
    const Bag* ToBag() const
    {
        if (IsBag())
            return reinterpret_cast<const Bag*>(this);
        return nullptr;
    }

    uint32 GetCount() const { return GetUInt32Value(ITEM_FIELD_STACK_COUNT); }
    void SetCount(uint32 value) { SetUInt32Value(ITEM_FIELD_STACK_COUNT, value); }
    uint32 GetMaxStackCount() const { return GetProto()->GetMaxStackSize(); }
    InventoryResult CanBeMergedPartlyWith(ItemPrototype const* proto) const;

    uint8 GetSlot() const { return m_slot; }
    Bag* GetContainer() { return m_container; }
    uint8 GetBagSlot() const;
    void SetSlot(uint8 slot) { m_slot = slot; }
    uint16 GetPos() const { return uint16(GetBagSlot()) << 8 | GetSlot(); }
    void SetContainer(Bag* container) { m_container = container; }

    bool IsInBag() const { return m_container != nullptr; }
    bool IsEquipped() const;

    // RandomPropertyId (signed but stored as unsigned)
    int32 GetItemRandomPropertyId() const { return GetInt32Value(ITEM_FIELD_RANDOM_PROPERTIES_ID); }
    uint32 GetItemSuffixFactor() const { return GetUInt32Value(ITEM_FIELD_PROPERTY_SEED); }
    void SetItemRandomProperties(int32 randomPropId);
    static int32 GenerateItemRandomPropertyId(uint32 item_id);
    void SetEnchantment(EnchantmentSlot slot, uint32 id, uint32 duration, uint32 charges);
    void SetEnchantmentDuration(EnchantmentSlot slot, uint32 duration);
    void SetEnchantmentCharges(EnchantmentSlot slot, uint32 charges);
    void ClearEnchantment(EnchantmentSlot slot);
    uint32 GetEnchantmentId(EnchantmentSlot slot) const { return GetUInt32Value(ITEM_FIELD_ENCHANTMENT + slot * MAX_ENCHANTMENT_OFFSET + ENCHANTMENT_ID_OFFSET); }
    uint32 GetEnchantmentDuration(EnchantmentSlot slot) const { return GetUInt32Value(ITEM_FIELD_ENCHANTMENT + slot * MAX_ENCHANTMENT_OFFSET + ENCHANTMENT_DURATION_OFFSET); }
    uint32 GetEnchantmentCharges(EnchantmentSlot slot) const { return GetUInt32Value(ITEM_FIELD_ENCHANTMENT + slot * MAX_ENCHANTMENT_OFFSET + ENCHANTMENT_CHARGES_OFFSET); }

    void SendTimeUpdate(Player const* owner) const;
    void UpdateDuration(Player* owner, uint32 diff);

    // spell charges (negative means that once charges are consumed the item should be deleted)
    int32 GetSpellCharges(uint8 index /*0..5*/ = 0) const { return GetInt32Value(ITEM_FIELD_SPELL_CHARGES + index); }
    void SetSpellCharges(uint8 index /*0..5*/, int32 value) { SetInt32Value(ITEM_FIELD_SPELL_CHARGES + index, value); }

    Loot loot;

    void SetLootState(ItemLootUpdateState state);
    bool HasGeneratedLoot() const { return !loot.empty() && m_lootState != ITEM_LOOT_NONE && m_lootState != ITEM_LOOT_REMOVED; }
    bool HasTemporaryLoot() const { return !loot.empty() && m_lootState == ITEM_LOOT_TEMPORARY; }

    bool HasSavedLoot() const { return m_lootState != ITEM_LOOT_NONE && m_lootState != ITEM_LOOT_NEW && m_lootState != ITEM_LOOT_TEMPORARY; }

    // Update States
    ItemUpdateState GetState() const { return uState; }
    void SetState(ItemUpdateState state, Player* forplayer = nullptr);
    void AddToUpdateQueueOf(Player* player);
    void RemoveFromUpdateQueueOf(Player* player);
    bool IsInUpdateQueue() const { return uQueuePos != -1; }
    uint16 GetQueuePos() const { return uQueuePos; }
    void FSetState(ItemUpdateState state) // forced
    {
        uState = state;
    }

    bool HasQuest(uint32 quest_id) const override { return GetProto()->StartQuest == quest_id; }
    bool HasInvolvedQuest(uint32 /*quest_id*/) const override { return false; }
    bool IsPotion() const { return GetProto()->IsPotion(); }
    bool IsConjuredConsumable() const { return GetProto()->IsConjuredConsumable(); }

    void AddToClientUpdateList() override;
    void RemoveFromClientUpdateList() override;
    void BuildUpdateData(UpdateDataMapType& update_players) override;
    void UpdateDurability(uint32 durability, Player* pPlayer);

    uint32 GetVisibleEntry() const;

    void SetGeneratedLoot(bool value) { generatedLoot = value; }
    bool HasGeneratedLootSecondary() { return generatedLoot; } // todo, remove and add condition to HasGeneratedLoot

    bool IsCharter() const { return GetEntry() == 5863u; }
    static void GetLocalizedNameWithSuffix(std::string& name, const ItemPrototype* proto, const ItemRandomPropertiesEntry* randomProp, int dbLocale, LocaleConstant dbcLocale);

    uint32 GetTransmogrification() const { return transmogrifyId; }
    void SetTransmogrification(uint32 value) { transmogrifyId = value; }

    uint32 GetOriginMapId() const { return m_obtainedFromMapId; }
    void SetCanTradeWithRaidUntil(time_t tradeUntil, uint32 mapId)
    {
        m_tradeAllowedUntil = tradeUntil;
        m_obtainedFromMapId = mapId;
    }
    bool CanBeTradedEvenIfSoulBound() const;
    void AddPlayerToAllowedTradeList(ObjectGuid guid) { m_canBeTradedWithPlayers.insert(guid); }
    bool CanTradeSoulBoundToPlayer(ObjectGuid guid) const { return m_canBeTradedWithPlayers.find(guid) != m_canBeTradedWithPlayers.end(); }
    void ResetSoulBoundTradeData();

    bool preventCancel = false;

private:
    uint32 transmogrifyId;
    bool generatedLoot;
    uint8 m_slot;
    Bag* m_container;
    ItemUpdateState uState;
    int16 uQueuePos;
    bool mb_in_trade; // true if item is currently in trade-window
    ItemLootUpdateState m_lootState;
    time_t m_tradeAllowedUntil = 0;
    uint32 m_obtainedFromMapId = 0;
    ObjectGuidSet m_canBeTradedWithPlayers;
};

#endif
