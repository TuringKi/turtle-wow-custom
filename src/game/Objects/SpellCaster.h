/*
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

#ifndef _SPELL_CASTER_OBJECT_H
#define _SPELL_CASTER_OBJECT_H

#include <array>
#include <memory>
#include <optional>
#include "Object.h"
#include "SpellDefines.h"
#include "Utilities/EventProcessor.h"

using std::optional;

class Aura;
class DynamicObject;
class Item;
class Spell;
class SpellCaster;
class SpellEntry;
struct ItemPrototype;


#define CURRENT_FIRST_NON_MELEE_SPELL 1
#define CURRENT_MAX_SPELL 4

class CooldownData
{
    friend class CooldownContainer;

public:
    CooldownData(TimePoint clockNow, uint32 spellId, uint32 duration, uint32 spellCategory, uint32 categoryDuration, uint32 itemId = 0, bool isPermanent = false) : m_spellId(spellId), m_category(spellCategory), m_expireTime(duration ? std::chrono::milliseconds(duration) + clockNow : TimePoint()), m_catExpireTime(spellCategory && categoryDuration ? std::chrono::milliseconds(categoryDuration) + clockNow : TimePoint()), m_typePermanent(isPermanent), m_itemId(itemId) {}

    // return false if permanent
    bool GetSpellCDExpireTime(TimePoint& expireTime) const
    {
        if (m_typePermanent)
            return false;

        expireTime = m_expireTime;
        return true;
    }

    void SetCatCDExpireTime(TimePoint expireTime) { m_catExpireTime = expireTime; }

    // return false if permanent
    bool GetCatCDExpireTime(TimePoint& expireTime) const
    {
        if (m_typePermanent)
            return false;

        expireTime = m_catExpireTime;
        return true;
    }

    bool IsSpellCDExpired(TimePoint const& now) const
    {
        if (m_typePermanent)
            return false;

        return now >= m_expireTime;
    }

    bool IsCatCDExpired(TimePoint const& now) const
    {
        if (m_typePermanent)
            return false;

        if (!m_category)
            return true;

        if (now >= m_catExpireTime)
            return true;

        return false;
    }

    bool IsPermanent() const { return m_typePermanent; }
    uint32 GetItemId() const { return m_itemId; }
    uint32 GetSpellId() const { return m_spellId; }
    uint32 GetCategory() const { return m_category; }

private:
    uint32 m_spellId;
    uint32 m_category;
    TimePoint m_expireTime;
    TimePoint m_catExpireTime;
    bool m_typePermanent;
    uint32 m_itemId;
};

typedef std::unique_ptr<CooldownData> CooldownDataUPTR;
typedef std::map<uint32, TimePoint> GCDMap;
typedef std::map<SpellSchools, TimePoint> LockoutMap;

class CooldownContainer
{
public:
    typedef std::map<uint32, CooldownDataUPTR> spellIdMap;
    typedef spellIdMap::const_iterator ConstIterator;
    typedef spellIdMap::iterator Iterator;
    typedef std::map<uint32, ConstIterator> categoryMap;

    void Update(TimePoint const& now)
    {
        auto spellCDItr = m_spellIdMap.begin();
        while (spellCDItr != m_spellIdMap.end())
        {
            auto& cd = spellCDItr->second;
            if (cd->IsSpellCDExpired(now) && cd->IsCatCDExpired(now)) // will not remove permanent CD
                spellCDItr = erase(spellCDItr);
            else
            {
                if (cd->m_category && cd->IsCatCDExpired(now))
                {
                    m_categoryMap.erase(cd->m_category);
                    cd->m_category = 0;
                }
                ++spellCDItr;
            }
        }
    }

    bool AddCooldown(TimePoint clockNow, uint32 spellId, uint32 duration, uint32 spellCategory = 0, uint32 categoryDuration = 0, uint32 itemId = 0, bool onHold = false)
    {
        RemoveBySpellId(spellId);
        auto resultItr = m_spellIdMap.emplace(spellId, std::move(std::unique_ptr<CooldownData>(new CooldownData(clockNow, spellId, duration, spellCategory, categoryDuration, itemId, onHold))));
        // do not overwrite one permanent category cooldown with another permanent category cooldown
        if (resultItr.second && spellCategory && categoryDuration)
        {
            auto catItr = FindByCategory(spellCategory);
            if (!onHold || catItr == m_spellIdMap.end() || !catItr->second->IsPermanent())
            {
                // we must keep original category cd owner for sake of client sync
                if (catItr != m_spellIdMap.end())
                {
                    catItr->second->SetCatCDExpireTime(std::chrono::milliseconds(categoryDuration) + clockNow);
                    catItr->second->m_typePermanent = false;
                    resultItr.first->second->m_category = 0;
                }
                else
                    m_categoryMap.emplace(spellCategory, resultItr.first);
            }
            else
                resultItr.first->second->m_category = 0;
        }

        return resultItr.second;
    }

    void RemoveBySpellId(uint32 spellId)
    {
        auto spellCDItr = m_spellIdMap.find(spellId);
        if (spellCDItr != m_spellIdMap.end())
        {
            auto& cdData = spellCDItr->second;
            if (cdData->m_category)
            {
                auto catCDItr = m_categoryMap.find(cdData->m_category);
                if (catCDItr != m_categoryMap.end())
                    m_categoryMap.erase(catCDItr);
            }
            m_spellIdMap.erase(spellCDItr);
        }
    }

    void RemoveByCategory(uint32 category)
    {
        auto spellCDItr = m_categoryMap.find(category);
        if (spellCDItr != m_categoryMap.end())
        {
            spellCDItr->second->second->m_category = 0;
            m_categoryMap.erase(spellCDItr);
        }
    }

    Iterator erase(ConstIterator spellCDItr)
    {
        auto& cdData = spellCDItr->second;
        if (cdData->m_category)
        {
            auto catCDItr = m_categoryMap.find(cdData->m_category);
            if (catCDItr != m_categoryMap.end())
                m_categoryMap.erase(catCDItr);
        }
        return m_spellIdMap.erase(spellCDItr);
    }

    ConstIterator FindBySpellId(uint32 id) const { return m_spellIdMap.find(id); }

    ConstIterator FindByCategory(uint32 category) const
    {
        auto itr = m_categoryMap.find(category);
        return itr != m_categoryMap.end() ? itr->second : end();
    }

    void clear()
    {
        m_spellIdMap.clear();
        m_categoryMap.clear();
    }

    ConstIterator begin() const { return m_spellIdMap.begin(); }
    ConstIterator end() const { return m_spellIdMap.end(); }
    bool IsEmpty() const { return m_spellIdMap.empty(); }
    size_t size() const { return m_spellIdMap.size(); }

private:
    spellIdMap m_spellIdMap;
    categoryMap m_categoryMap;
};

// Unit* victim, uint32 procAttacker, uint32 procVictim, uint32 procExtra, uint32 amount, WeaponAttackType attType, SpellEntry const* procSpell, bool dontTriggerSpecial

// External struct for passing on data
struct SpellModifier;
struct ProcSystemArguments
{
    Unit* pVictim;
    ObjectGuid victimGuid;

    uint32 procFlagsAttacker;
    uint32 procFlagsVictim;
    uint32 procExtra;

    uint32 amount; // contains full heal or full damage
    uint32 originalAmount; // before resist and absorb
    SpellEntry const* procSpell;
    WeaponAttackType attType;

    std::list<SpellModifier*> appliedSpellModifiers; // don't dereference pointers
    bool isSpellTriggeredByAuraOrItem;
    time_t procTime;

    explicit ProcSystemArguments(Unit* pVictim_, uint32 procFlagsAttacker_, uint32 procFlagsVictim_, uint32 procExtra_, uint32 amount_, uint32 originalAmount_, WeaponAttackType attType_ = BASE_ATTACK, SpellEntry const* procSpell_ = nullptr, Spell const* spell = nullptr);
};

// Needed because of SPELL_ATTR_EX3_INSTANT_TARGET_PROCS
// We need to call ProcDamageAndSpell twice
enum ProcessProcsAuraType
{
    PROC_PROCESS_INSTANT,
    PROC_PROCESS_DELAYED,
    PROC_PROCESS_ALL
};

// Intermediary absract class to hold all the common spell casting method between Units and GameObjects.
class SpellCaster : public WorldObject
{
public:
    // cooldown system
    virtual void AddGCD(SpellEntry const& spellEntry, uint32 forcedDuration = 0, bool updateClient = false);
    virtual bool HasGCD(SpellEntry const* spellEntry) const;
    void ResetGCD(SpellEntry const* spellEntry = nullptr);
    bool CheckLockout(SpellSchoolMask schoolMask) const;


    // Event handler
    EventProcessor m_Events;

protected:
    explicit SpellCaster() = default;


    GCDMap m_GCDCatMap;
    LockoutMap m_lockoutMap;


private:
};

inline SpellCaster* Object::ToSpellCaster() { return IsSpellCaster() ? static_cast<SpellCaster*>(this) : nullptr; }

inline SpellCaster const* Object::ToSpellCaster() const { return IsSpellCaster() ? static_cast<SpellCaster const*>(this) : nullptr; }

inline SpellCaster* ToSpellCaster(Object* object) { return object && object->IsSpellCaster() ? static_cast<SpellCaster*>(object) : nullptr; }

inline SpellCaster const* ToSpellCaster(Object const* object) { return object && object->IsSpellCaster() ? static_cast<SpellCaster const*>(object) : nullptr; }

#endif
