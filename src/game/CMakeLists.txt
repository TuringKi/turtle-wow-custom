# Copyright (C) 2005-2011 MaNGOS <http://getmangos.com/>
# Copyright (C) 2009-2011 MaNGOSZero <https://github.com/mangos/zero>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

set (game_SRCS 
    AccountMgr.cpp
    AuraRemovalMgr.cpp
    AutoBroadCastMgr.cpp
    Camera.cpp
    Conditions.cpp
    CreatureGroups.cpp
    CustomMerchantMgr.cpp
    DynamicVisibilityMgr.cpp
    DynamicVisibilityMgr.h
    DailyQuestHandler.cpp
    GameEventMgr.cpp
    GuardMgr.cpp
    GMTicketMgr.cpp
    GossipDef.cpp
    PerformanceMonitor.cpp
    HardcodedEvents.cpp
    HonorMgr.cpp
    ItemEnchantmentMgr.cpp
    LootMgr.cpp
    ObjectAccessor.cpp
    ObjectGridLoader.cpp
    ObjectGuid.cpp
    ObjectMgr.cpp
    ObjectPosSelector.cpp
    PlayerDump.cpp
    QuestDef.cpp
    ReputationMgr.cpp
    ScriptObjects.h
    ScriptMgr.cpp
    SocialMgr.cpp
    StatSystem.cpp
    TransmogMgr.cpp
    UnitAuraProcHandler.cpp
    Weather.cpp
    World.cpp
    WorldSession.cpp
    AI/AbilityTimer.cpp
    AI/AggressorAI.cpp
    AI/CreatureAI.cpp
    AI/CreatureAIRegistry.cpp
    AI/CreatureAISelector.cpp
    AI/CreatureEventAI.cpp
    AI/CreatureEventAIMgr.cpp
    AI/CritterAI.cpp
    AI/GenericSpellAI.cpp
    AI/GuardAI.cpp
    AI/GuardEventAI.cpp
    AI/NullCreatureAI.cpp
    AI/PetAI.cpp
    AI/PetEventAI.cpp
    AI/PlayerAI.cpp
    AI/ReactorAI.cpp
    AI/ScriptedAI.cpp
    AI/ScriptedEscortAI.cpp
    AI/ScriptedFollowerAI.cpp
    AI/ScriptedInstance.cpp
    AI/ScriptedPetAI.cpp
    AI/TotemAI.cpp
	Analysis/AccountAnalyser.cpp
    Autoscaling/AutoScaler.cpp
    AuctionHouse/AuctionHouseMgr.cpp
    AuctionHouse/AuctionHouseBotMgr.cpp
    Battlegrounds/BattleGround.cpp
    Battlegrounds/BattleGroundAB.cpp
    Battlegrounds/BattleGroundAV.cpp
    Battlegrounds/BattleGroundMgr.cpp
    Battlegrounds/BattleGroundWS.cpp
    Battlegrounds/BattleGroundBR.cpp
    Battlegrounds/BattleGroundSV.cpp
    Chat/Channel.cpp
    Chat/ChannelMgr.cpp
    Chat/Chat.cpp
    Chat/AsyncCommandHandlers.cpp
    Chat/WhisperTargetLimits.cpp
    Commands/Commands.cpp
    Database/CharacterDatabaseCache.cpp
    Database/CharacterDatabaseCleaner.cpp
    Database/DBCStores.cpp
    Database/SQLStorages.cpp
    Group/CreatureLinkingMgr.cpp
    Group/Group.cpp
    Group/GroupReference.cpp
    Guild/Guild.cpp
    Guild/GuildMgr.cpp
    Handlers/AddonHandler.cpp
    Handlers/AuctionHouseHandler.cpp
    Handlers/BattleGroundHandler.cpp
    Handlers/ChannelBroadcaster.cpp
    Handlers/ChannelHandler.cpp
    Handlers/CharacterHandler.cpp
    Handlers/ChatHandler.cpp
    Handlers/CombatHandler.cpp
    Handlers/DuelHandler.cpp
    Handlers/GMTicketHandler.cpp
    Handlers/GroupHandler.cpp
    Handlers/GuildHandler.cpp
    Handlers/ItemHandler.cpp
    Handlers/LFGHandler.cpp
    Handlers/LootHandler.cpp
    Handlers/MailHandler.cpp
    Handlers/MiscHandler.cpp
    Handlers/MovementHandler.cpp
    Handlers/NPCHandler.cpp
    Handlers/PetHandler.cpp
    Handlers/PetitionsHandler.cpp
    Handlers/QueryHandler.cpp
    Handlers/QuestHandler.cpp
    Handlers/SkillHandler.cpp
    Handlers/SpellHandler.cpp
    Handlers/TaxiHandler.cpp
    Handlers/TradeHandler.cpp
    HttpApi/ControllerRegistrar.cpp
    HttpApi/TestController.cpp
    HttpApi/TestController.hpp
    HttpApi/TransferController.cpp
    HttpApi/TransferController.hpp
    LFG/LFGMgr.cpp
    LFT/LFTBotFill.cpp
    LFT/LFTMgr.cpp
    LFT/LFTQeueue.cpp
    LFT/LFTTeleport.cpp
    LFT/LFTUserGroups.cpp
    Logging/DatabaseLogger.hpp
    Logging/DatabaseLogger.cpp
    Mail/Mail.cpp
    Mail/MassMailMgr.cpp
    MapNodes/AbstractPlayer.cpp
    MapNodes/MasterPlayer.cpp
    MapNodes/MasterPlayerChat.cpp
    Maps/GridMap.cpp
    Maps/GridNotifiers.cpp
    Maps/GridSearchers.cpp
    Maps/GridStates.cpp
    Maps/InstanceData.cpp
    Maps/Map.cpp
    Maps/MapManager.cpp
    Maps/MapPersistentStateMgr.cpp
    Maps/MapReference.cpp
    Maps/MoveMap.cpp
    Maps/PathFinder.cpp
    Maps/ScriptCommands.cpp
    Maps/ZoneScript.cpp
    Maps/ZoneScriptMgr.cpp
    Maps/Pool/PoolManager.cpp
    Movement/ConfusedMovementGenerator.cpp
    Movement/FearMovementGenerator.cpp
    Movement/FleeingMovementGenerator.cpp
    Movement/FollowerReference.cpp
    Movement/HomeMovementGenerator.cpp
    Movement/IdleMovementGenerator.cpp
    Movement/MotionMaster.cpp
    Movement/MovementGenerator.cpp
    Movement/MovementPacketSender.cpp
    Movement/PointMovementGenerator.cpp
    Movement/RandomMovementGenerator.cpp
    Movement/TargetedMovementGenerator.cpp
    Movement/WaypointManager.cpp
    Movement/WaypointMovementGenerator.cpp
    Movement/spline/MoveSpline.cpp
    Movement/spline/MoveSplineInit.cpp
    Movement/spline/packet_builder.cpp
    Movement/spline/spline.cpp
    Movement/spline/util.cpp
    Objects/Bag.cpp
    Objects/Corpse.cpp
    Objects/Creature.cpp
    Objects/DynamicObject.cpp
    Objects/GameObject.cpp
    Objects/Item.cpp
    Objects/Object.cpp
    Objects/Pet.cpp
    Objects/Player.cpp
    Objects/TemporarySummon.cpp
    Objects/Totem.cpp
    Objects/Unit.cpp
    Objects/SpellCaster.cpp
    Objects/UpdateData.cpp
    OutdoorPvP/OutdoorPvPEP.cpp
    OutdoorPvP/OutdoorPvPSI.cpp
    OutdoorPvP/Register.cpp
    PacketBroadcast/MovementBroadcaster.cpp
    PacketBroadcast/PlayerBroadcaster.cpp
    PlayerBots/PartyBotAI.cpp
    PlayerBots/CombatBotBaseAI.cpp
    PlayerBots/BattleBotAI.cpp
    PlayerBots/BattleBotWaypoints.cpp
    PlayerBots/PlayerBotAI.cpp
    PlayerBots/PlayerBotMgr.cpp
    Protocol/Opcodes.cpp
    Protocol/WorldSocket.cpp
    Protocol/WorldSocketMgr.cpp
    Protocol/Opcodes_1_12_1.h
    Spells/Spell.cpp
    Spells/SpellAuras.cpp
    Spells/SpellEffects.cpp
    Spells/SpellEntry.cpp
    Spells/SpellMgr.cpp
    Spells/SpellModMgr.cpp
    Threat/HostileRefManager.cpp
    Threat/ThreatManager.cpp
    Transports/Transport.cpp
    Transports/TransportMgr.cpp
    TWDebuff/TWDebuff.cpp
    vmap/BIH.cpp
    vmap/DynamicTree.cpp
    vmap/GameObjectModel.cpp
    vmap/MapTree.cpp
    vmap/ModelInstance.cpp
    vmap/TileAssembler.cpp
    vmap/VMapFactory.cpp
    vmap/VMapManager2.cpp
    vmap/WorldModel.cpp
    Shop/ShopMgr.cpp
    GuildBank/GuildBank.cpp
    AccountMgr.h
    AuraRemovalMgr.h
    AutoBroadCastMgr.h
    Camera.h
    Conditions.h
    CreatureGroups.h
    CustomMerchantMgr.h
    Formulas.h
    GuidObjectScaling.h
    GameEventMgr.h
    Geometry.h
    GuardMgr.h
    GMTicketMgr.h
    GossipDef.h
    HardcodedEvents.h
    HonorMgr.h
    ItemEnchantmentMgr.h
    Language.h
    LootMgr.h
    LoveIsInTheAir.h
    ObjectAccessor.h
    ObjectGridLoader.h
    ObjectGuid.h
    ObjectMgr.h
    ObjectPosSelector.h
    PlayerDump.h
    PerformanceMonitor.h
    QuestDef.h
    ReputationMgr.h
    ScriptedGossip.h
    ScriptMgr.h
    SharedDefines.h
    SocialMgr.h
    TransmogMgr.h
    UnitEvents.h
    Weather.h
    World.h
    WorldSession.h
	Analysis/AccountAnalyser.hpp
    AI/AbilityTimer.h
    AI/AggressorAI.h
    AI/CreatureAI.h
    AI/CreatureAIImpl.h
    AI/CreatureAIRegistry.h
    AI/CreatureAISelector.h
    AI/CreatureEventAI.h
    AI/CreatureEventAIMgr.h
    AI/CritterAI.h
	AI/GenericSpellAI.h
    AI/GameObjectAI.h
    AI/GuardAI.h
    AI/GuardEventAI.h
    AI/NullCreatureAI.h
    AI/PetAI.h
    AI/PetEventAI.h
    AI/PlayerAI.h
    AI/ReactorAI.h
    AI/ScriptedAI.h
    AI/ScriptedEscortAI.h
    AI/ScriptedFollowerAI.h
    AI/ScriptedGameObject.h
    AI/ScriptedInstance.h
    AI/ScriptedPetAI.h
    AI/TotemAI.h
    Anticheat/libanticheat.hpp
    Anticheat/Anticheat.h
    AuctionHouse/AuctionHouseMgr.h
    Battlegrounds/BattleGround.h
    Battlegrounds/BattleGroundAB.h
    Battlegrounds/BattleGroundAV.h
    Battlegrounds/BattleGroundMgr.h
    Battlegrounds/BattleGroundWS.h
    Battlegrounds/BattleGroundBR.h
    Battlegrounds/BattleGroundSV.h
    Chat/Channel.h
    Chat/ChannelMgr.h
    Chat/Chat.h
    Chat/AsyncCommandHandlers.h
    Chat/WhisperTargetLimits.h
    Commands/Nostalrius.h
    Database/CharacterDatabaseCache.h
    Database/CharacterDatabaseCleaner.h
    Database/DBCEnums.h
    Database/DBCfmt.h
    Database/DBCStores.h
    Database/DBCStructure.h
    Database/SQLStorages.h
    Group/CreatureLinkingMgr.h
    Group/Group.h
    Group/GroupReference.h
    Group/GroupRefManager.h
    Guild/Guild.h
    Guild/GuildMgr.h
    Handlers/AddonHandler.h
    Handlers/ChannelBroadcaster.h
    Handlers/NPCHandler.h
    Handlers/LFGHandler.h
    LFG/LFGMgr.h
    LFT/LFTMgr.h
    Mail/Mail.h
    Mail/MassMailMgr.h
    Maps/Cell.h
    Maps/CellImpl.h
    Maps/GridDefines.h
    Maps/GridMap.h
    Maps/GridMapDefines.h
    Maps/GridNotifiers.h
    Maps/GridNotifiersImpl.h
    Maps/GridSearchers.h
    Maps/GridStates.h
    Maps/InstanceData.h
    Maps/Map.h
    Maps/MapManager.h
    Maps/MapPersistentStateMgr.h
    Maps/MapReference.h
    Maps/MapRefManager.h
    Maps/MoveMap.h
    Maps/MoveMapSharedDefines.h
    Maps/Path.h
    Maps/PathFinder.h
    Maps/ZoneScript.h
    Maps/ZoneScriptMgr.h
    Maps/Pool/PoolManager.h
    Movement/ConfusedMovementGenerator.h
    Movement/FearMovementGenerator.h
    Movement/FleeingMovementGenerator.h
    Movement/FollowerReference.h
    Movement/FollowerRefManager.h
    Movement/HomeMovementGenerator.h
    Movement/IdleMovementGenerator.h
    Movement/MotionMaster.h
    Movement/MovementGenerator.h
    Movement/MovementGeneratorImpl.h
    Movement/MovementPacketSender.h
    Movement/PointMovementGenerator.h
    Movement/RandomMovementGenerator.h
    Movement/TargetedMovementGenerator.h
    Movement/WaypointManager.h
    Movement/WaypointMovementGenerator.h
    Movement/spline/MoveSpline.h
    Movement/spline/MoveSplineFlag.h
    Movement/spline/MoveSplineInit.h
    Movement/spline/MoveSplineInitArgs.h
    Movement/spline/packet_builder.h
    Movement/spline/spline.h
    Movement/spline/spline.impl.h
    Movement/spline/typedefs.h
    Objects/Bag.h
    Objects/Corpse.h
    Objects/Creature.h
    Objects/DynamicObject.h
    Objects/GameObject.h
    Objects/Item.h
    Objects/ItemPrototype.h
    Objects/Object.h
    Objects/Pet.h
    Objects/Player.h
    Objects/TemporarySummon.h
    Objects/Totem.h
    Objects/Unit.h
	Objects/UnitDefines.h
    Objects/UpdateData.h
    Objects/UpdateFields.h
    Objects/UpdateMask.h
    OutdoorPvP/OutdoorPvPEP.h
    OutdoorPvP/OutdoorPvPSI.h
    PacketBroadcast/MovementBroadcaster.h
    PacketBroadcast/PlayerBroadcaster.h
    # PlayerBots/PlayerBot{AI,Mgr}.h removed - Penqle stub binned
    Protocol/Opcodes.h
    Protocol/WorldSocket.h
    Protocol/WorldSocketMgr.h
    Spells/Spell.h
    Spells/SpellAuraDefines.h
    Spells/SpellAuras.h
    Spells/SpellClassMask.h
	Spells/SpellDefines.h
    Spells/SpellEntry.h
    Spells/SpellMgr.h
    Spells/SpellModMgr.h
    Threat/HostileRefManager.h
    Threat/ThreatManager.h
    Transports/Transport.h
    Transports/TransportMgr.h
    vmap/BIH.h
    vmap/BIHWrap.h
    vmap/DynamicTree.h
    vmap/GameObjectModel.h
    vmap/IVMapManager.h
    vmap/MapTree.h
    vmap/ModelInstance.h
    vmap/RegularGrid.h
    vmap/TileAssembler.h
    vmap/VMapDefinitions.h
    vmap/VMapFactory.h
    vmap/VMapManager2.h
    vmap/VMapTools.h
    vmap/WorldModel.h
    Shop/ShopMgr.h
    GuildBank/GuildBank.h

)

if((${CMAKE_VERSION} VERSION_LESS "3.16") OR USE_PCH_OLD)
  list(APPEND game_SRCS
      pchdef.cpp
      pchdef.h
  )
  include_directories(${CMAKE_CURRENT_BINARY_DIR})
endif()

if(WIN32)
  #allow exceptions in destructors
  if(MSVC)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /Zc:implicitNoexcept-")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /D__ACE_INLINE__")
  elseif(MINGW)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fpermissive")
  endif()
endif()

# Used in game ScriptMgr
if(USE_SCRIPTS)
  list(APPEND game_SRCS
      ${CMAKE_SOURCE_DIR}/src/scripts/ScriptLoader.cpp
      ${CMAKE_SOURCE_DIR}/src/scripts/ScriptLoader.h
  )
else()
  list(APPEND game_SRCS
      ${CMAKE_SOURCE_DIR}/src/scripts/ScriptLoader.h
  )
endif()

if(USE_DISCORD_BOT)
    list(APPEND game_SRCS
      DiscordBot/CommandRegistrar.cpp
      DiscordBot/GMCommandHandler.cpp
      DiscordBot/GMCommandHandler.hpp
      DiscordBot/LoginCommandHandler.cpp
      DiscordBot/LoginCommandHandler.hpp
      DiscordBot/PlayerCommandHandler.cpp
      DiscordBot/PlayerCommandHandler.hpp 
    )
endif()

if(USE_ANTICHEAT)
  list(APPEND game_SRCS
      Anticheat/Antispam/Antispam.cpp
      Anticheat/Antispam/Antispam.h
      Anticheat/Movement/Movement.cpp
      Anticheat/Movement/Movement.hpp
      Anticheat/Warden/Warden.cpp
      Anticheat/Warden/Warden.hpp
      Anticheat/Warden/WardenKeyGeneration.h
      Anticheat/Warden/WardenMac.cpp
      Anticheat/Warden/WardenMac.hpp
      Anticheat/Warden/WardenWin.cpp
      Anticheat/Warden/WardenWin.hpp
      Anticheat/Warden/WardenModule.cpp
      Anticheat/Warden/WardenModule.hpp
      Anticheat/Warden/WardenModuleMgr.cpp
      Anticheat/Warden/WardenModuleMgr.hpp
      Anticheat/Warden/WardenScan.cpp
      Anticheat/Warden/WardenScan.hpp
      Anticheat/Warden/WardenScanMgr.cpp
      Anticheat/Warden/WardenScanMgr.hpp
      Anticheat/AddonHandler.cpp
      Anticheat/AnticheatChatCommands.h
      Anticheat/AnticheatChatCommandsFunctions.cpp
      Anticheat/AnticheatChatCommandsFunctions.h
      Anticheat/SuspiciousStatisticMgr.h
      Anticheat/SuspiciousStatisticMgr.cpp
      Anticheat/Config.cpp
      Anticheat/Config.hpp
      Anticheat/cyclic.hpp
      Anticheat/dldist.hpp
      Anticheat/priority.hpp
      Anticheat/libanticheat.cpp
  )
  else()
    list(APPEND game_SRCS
        Anticheat/Anticheat.cpp
    )
endif()

if(BUILD_ELUNA)
  list(APPEND game_SRCS
    ElunaScriptBridge.cpp
    Eluna/CustomMethods.h
  )

  file(GLOB ELUNA_SRCS CONFIGURE_DEPENDS
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/*.cpp
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/*.h
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks/*.cpp
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks/*.h
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/methods/*.cpp
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/methods/VMangos/*.h
  )

  if(MSVC)
    # Eluna's parameter-pack name `Is` conflicts with its LuaRet<T>::Is
    # predicate in current MSVC. Build a generated, semantically identical
    # copy so the pinned submodule remains pristine.
    set(ELUNA_MSVC_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/eluna-msvc)
    file(MAKE_DIRECTORY ${ELUNA_MSVC_SOURCE_DIR})
    configure_file(
      ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks/SpellHooks.cpp
      ${ELUNA_MSVC_SOURCE_DIR}/SpellHooks.cpp
      COPYONLY
    )
    file(READ ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks/HookHelpers.h ELUNA_HOOK_HELPERS)
    string(FIND "${ELUNA_HOOK_HELPERS}" "size_t... Is" ELUNA_MSVC_RENAME_POSITION)
    if(NOT ELUNA_MSVC_RENAME_POSITION EQUAL -1)
      string(REPLACE "size_t... Is" "size_t... ReturnIndices" ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
      string(REPLACE "index_sequence<Is...>" "index_sequence<ReturnIndices...>" ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
      string(REPLACE "tuple_element_t<Is," "tuple_element_t<ReturnIndices," ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
      string(REPLACE "static_cast<int>(Is)" "static_cast<int>(ReturnIndices)" ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
      string(REPLACE "std::get<Is>" "std::get<ReturnIndices>" ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
      string(REPLACE "indices[Is]" "indices[ReturnIndices]" ELUNA_HOOK_HELPERS "${ELUNA_HOOK_HELPERS}")
    endif()
    file(WRITE ${ELUNA_MSVC_SOURCE_DIR}/HookHelpers.h "${ELUNA_HOOK_HELPERS}")
    list(REMOVE_ITEM ELUNA_SRCS ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks/SpellHooks.cpp)
    list(APPEND ELUNA_SRCS ${ELUNA_MSVC_SOURCE_DIR}/SpellHooks.cpp)
  endif()

  list(APPEND game_SRCS ${ELUNA_SRCS})
endif()


# playerbot
if(BUILD_LEGACY_PLAYERBOTS)

#Base files
file(GLOB Playerbot_Source ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/*.h)
source_group("Player Bot" FILES ${Playerbot_Source})
file(GLOB AHbot_Source ${CMAKE_SOURCE_DIR}/src/modules/Bots/ahbot/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/ahbot/*.h)
source_group("AH Bot" FILES ${AHbot_Source})

set(SRC_GRP_BOTS
    ${Playerbot_Source}
    ${AHbot_Source}
)
#Strategy files
file(GLOB Playerbot_Strategy ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/*.h)
source_group("Player Bot\\Strategies" FILES ${Playerbot_Strategy})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Strategy})

#Action files
file(GLOB Playerbot_Actions ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/actions/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/actions/*.h)
source_group("Player Bot\\Strategies\\Actions" FILES ${Playerbot_Actions})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Actions})

#Generic files
file(GLOB Playerbot_Generic ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/generic/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/generic/*.h)
source_group("Player Bot\\Strategies\\Generic" FILES ${Playerbot_Generic})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Generic})

#Trigger files
file(GLOB Playerbot_Triggers ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/triggers/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/triggers/*.h)
source_group("Player Bot\\Strategies\\Triggers" FILES ${Playerbot_Triggers})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Triggers})


#Value files
file(GLOB Playerbot_Values ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/values/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/values/*.h)
source_group("Player Bot\\Strategies\\Values" FILES ${Playerbot_Values})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Values})

## Class files
#Druid AI
file(GLOB Playerbot_Druid ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/druid/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/druid/*.h)
source_group("Player Bot\\Strategies\\Druid" FILES ${Playerbot_Druid})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Druid})

#Hunter AI
file(GLOB Playerbot_Hunter ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/hunter/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/hunter/*.h)
source_group("Player Bot\\Strategies\\Hunter" FILES ${Playerbot_Hunter})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Hunter})

#Mage AI
file(GLOB Playerbot_Mage ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/mage/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/mage/*.h)
source_group("Player Bot\\Strategies\\Mage" FILES ${Playerbot_Mage})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Mage})

#Paladin AI
file(GLOB Playerbot_Paladin ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/paladin/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/paladin/*.h)
source_group("Player Bot\\Strategies\\Paladin" FILES ${Playerbot_Paladin})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Paladin})

#Priest AI
file(GLOB Playerbot_Priest ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/priest/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/priest/*.h)
source_group("Player Bot\\Strategies\\Priest" FILES ${Playerbot_Priest})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Priest})

#Rogue AI
file(GLOB Playerbot_Rogue ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/rogue/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/rogue/*.h)
source_group("Player Bot\\Strategies\\Rogue" FILES ${Playerbot_Rogue})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Rogue})

#Shaman AI
file(GLOB Playerbot_Shaman ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/shaman/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/shaman/*.h)
source_group("Player Bot\\Strategies\\Shaman" FILES ${Playerbot_Shaman})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Shaman})

#Warlock AI
file(GLOB Playerbot_Warlock ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/warlock/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/warlock/*.h)
source_group("Player Bot\\Strategies\\Warlock" FILES ${Playerbot_Warlock})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Warlock})

#Warrior AI
file(GLOB Playerbot_Warrior ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/warrior/*.cpp ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/strategy/warrior/*.h)
source_group("Player Bot\\Strategies\\Warrior" FILES ${Playerbot_Warrior})
LIST(APPEND SRC_GRP_BOTS ${Playerbot_Warrior})

configure_file(${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot/aiplayerbot.conf.dist.in ${CMAKE_CURRENT_BINARY_DIR}/aiplayerbot.conf.dist)
endif()





include_directories(
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/AI
  ${CMAKE_CURRENT_SOURCE_DIR}/Anticheat
  ${CMAKE_CURRENT_SOURCE_DIR}/AuctionHouse
  ${CMAKE_CURRENT_SOURCE_DIR}/Battlegrounds
  ${CMAKE_CURRENT_SOURCE_DIR}/Chat
  ${CMAKE_CURRENT_SOURCE_DIR}/Commands
  ${CMAKE_CURRENT_SOURCE_DIR}/Database
  ${CMAKE_CURRENT_SOURCE_DIR}/Group
  ${CMAKE_CURRENT_SOURCE_DIR}/Guild
  ${CMAKE_CURRENT_SOURCE_DIR}/Handlers
  ${CMAKE_CURRENT_SOURCE_DIR}/LFG
  ${CMAKE_CURRENT_SOURCE_DIR}/LFT
  ${CMAKE_CURRENT_SOURCE_DIR}/Mail
  ${CMAKE_CURRENT_SOURCE_DIR}/MapNodes
  ${CMAKE_CURRENT_SOURCE_DIR}/MapNodes/Handlers
  ${CMAKE_CURRENT_SOURCE_DIR}/MapNodes/Serializers
  ${CMAKE_CURRENT_SOURCE_DIR}/Maps
  ${CMAKE_CURRENT_SOURCE_DIR}/Maps/Pool
  ${CMAKE_CURRENT_SOURCE_DIR}/Movement
  ${CMAKE_CURRENT_SOURCE_DIR}/Movement/spline
  ${CMAKE_CURRENT_SOURCE_DIR}/Objects
  ${CMAKE_CURRENT_SOURCE_DIR}/OutdoorPvP
  ${CMAKE_CURRENT_SOURCE_DIR}/PacketBroadcast
  ${CMAKE_CURRENT_SOURCE_DIR}/PlayerBots
  ${CMAKE_CURRENT_SOURCE_DIR}/Protocol
  ${CMAKE_CURRENT_SOURCE_DIR}/Spells
  ${CMAKE_CURRENT_SOURCE_DIR}/Threat
  ${CMAKE_CURRENT_SOURCE_DIR}/Transports
  ${CMAKE_CURRENT_SOURCE_DIR}/vmap
  ${CMAKE_SOURCE_DIR}/src/scripts
  ${CMAKE_SOURCE_DIR}/dep/include/g3dlite
  ${CMAKE_SOURCE_DIR}/dep/recastnavigation/Detour
  ${CMAKE_SOURCE_DIR}/dep/recastnavigation
  ${CMAKE_SOURCE_DIR}/dep/include
  ${CMAKE_SOURCE_DIR}/dep/libdeflate
  ${CMAKE_SOURCE_DIR}/src/framework
  ${CMAKE_SOURCE_DIR}/src/framework/Network
  ${CMAKE_SOURCE_DIR}/src/shared
  ${CMAKE_BINARY_DIR}
  ${CMAKE_BINARY_DIR}/src/shared
  ${MYSQL_INCLUDE_DIR}
  ${TBB_INCLUDE_DIRS}
  ${ACE_INCLUDE_DIR}
  ${OPENSSL_INCLUDE_DIR}
  ${CMAKE_SOURCE_DIR}/src/modules/Bots
  ${CMAKE_SOURCE_DIR}/src/modules/Bots/playerbot
  ${CMAKE_SOURCE_DIR}/src/modules/Bots/ahbot
)

if(WIN32)
  include_directories(
    ${CMAKE_SOURCE_DIR}/dep/include-windows
  )
endif()


source_group("Object"
  REGULAR_EXPRESSION .*
)

source_group("World/Handlers"
  REGULAR_EXPRESSION Mgr|Handler|Manager|Cell|Channel|Chat|Gossip|Grid|Instance|Map|Path|Pool|Script|Skill|Transports|Update|Weather|World
)

source_group("Motion generators"
  REGULAR_EXPRESSION MoveMap|MoveMapSharedDefines|Movement|Holder|Motion|Traveller
)

source_group("Server"
  REGULAR_EXPRESSION Socket|Session|Opcodes|DBC
  FILES
    SharedDefines.h
)

source_group("Tool"
  REGULAR_EXPRESSION DatabaseCleaner|Language|PlayerDump
)

source_group("References"
  REGULAR_EXPRESSION Reference|RefManager|ThreatManager
)

source_group("Anticheat"
  REGULAR_EXPRESSION Anticheat
)

source_group("DiscordBot"
  REGULAR_EXPRESSION DiscordBot
)

source_group("HttpApi"
  REGULAR_EXPRESSION HttpApi
)

if(BUILD_ELUNA)
  source_group("Eluna" FILES ${ELUNA_SRCS})
endif()


# playerbots host-hook stubs for non-bot builds.
# When BUILD_PLAYERBOTS=OFF, the host-hook call sites need stub implementations.
# With BUILD_PLAYERBOTS=ON, real implementations are in playerbots.lib.
if(NOT BUILD_PLAYERBOTS)
    list(APPEND game_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/PlayerbotStubs.cpp)
endif()

add_library(game STATIC
  ${game_SRCS}
  ${SRC_GRP_BOTS}
)


SET_TARGET_PROPERTIES(game PROPERTIES FOLDER "Game Libs")

target_link_libraries(game
  shared
  Detour
)

if(BUILD_ELUNA)
  target_link_libraries(game lualib)
  target_compile_definitions(game PUBLIC
    ENABLE_ELUNA
    ELUNA_EXPANSION=0
    ELUNA_VMANGOS
    ELUNA_USE_CUSTOM_METHODS
  )
  target_include_directories(game PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Eluna
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/hooks
    ${CMAKE_SOURCE_DIR}/src/modules/Eluna/methods/VMangos
  )

  install(
    DIRECTORY ${CMAKE_SOURCE_DIR}/src/modules/Eluna/extensions
    DESTINATION ${BIN_DIR}/lua_scripts
  )
endif()

if(WIN32)
	if (ENABLE_PROFILING)
		include_directories(
			${OPTICK_INCLUDE_DIR}
    )
	endif()
endif()

if(USE_DISCORD_BOT)
    target_link_libraries(game
	dpp
  )
  target_compile_definitions(game PUBLIC USING_DISCORD_BOT)
endif()

#add_dependencies(game revision.h)

# Generate precompiled header
if((${CMAKE_VERSION} VERSION_LESS "3.16") OR USE_PCH_OLD)
  if(USE_PCH)
    if(MSVC OR XCODE)
      if(MSVC)
        set(game_pch "${CMAKE_CURRENT_SOURCE_DIR}/pchdef.cpp")
      endif()
      add_native_precompiled_header(game ${CMAKE_CURRENT_SOURCE_DIR}/pchdef.h)
    elseif(CMAKE_COMPILER_IS_GNUCXX)
      add_precompiled_header(game ${CMAKE_CURRENT_SOURCE_DIR}/pchdef.h)
    endif()
  endif()
else()
  if(USE_PCH)
      target_precompile_headers(game PRIVATE
      Protocol/WorldSocket.h
      ../shared/Common.h

      Maps/MapManager.h
      ../shared/Log.h
      ObjectAccessor.h
      ObjectGuid.h
      Database/SQLStorages.h
      Protocol/Opcodes.h
      SharedDefines.h
      Guild/GuildMgr.h
      ObjectMgr.h
      ScriptMgr.h
      )
  endif()
endif()

# Independent of USE_PCH_OLD on purpose: on MSVC the old PCH implementation is
# the default, and a fallback that lived only in the modern branch never ran
# there (2026-09-04, found by a reader: -DUSE_PCH_OLD=OFF "must also be set").
# No PCH (USE_PCH=OFF - the usual escape from MSVC's PCH size limits, or a
# compiler without support): the sources still assume the precompiled set of
# headers is in scope, so force-include the same header instead. Identical
# semantics, just no .pch file. Without this a USE_PCH=OFF build died on
# 2026-09-04 in Eluna (Hooks.h has no base types under ELUNA_VMANGOS, ElunaLoader.cpp needs sMapMgr) and a handful of core headers.
if(NOT USE_PCH)
  if(MSVC)
    target_compile_options(game PRIVATE "/FI${CMAKE_CURRENT_SOURCE_DIR}/pchdef.h")
  else()
    target_compile_options(game PRIVATE "-include${CMAKE_CURRENT_SOURCE_DIR}/pchdef.h")
  endif()
endif()
