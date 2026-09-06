#!/usr/bin/env python3
"""Compile production entrance resolution and party teleport preflight.

World/session/database boundaries are doubles; no live database is touched.
The historical client fixture is deliberately not labelled as client 1.18.1.
"""
from pathlib import Path
import json
import re
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
reference = json.loads((repo / 'tests/playerbots/fixtures/lft-reference-0.0.3.3.json').read_text())
production = re.sub(r'^#include[^\n]*\n', '', (repo / 'src/game/LFT/LFTTeleport.cpp').read_text(), flags=re.M)
code = r'''
#include "LFTDungeonEntrances.h"
#include <cassert>
#include <cstdint>
#include <map>
#include <set>
#include <optional>
using uint32=uint32_t;using int32=int32_t;
using ObjectGuid=unsigned;
const int CHALLENGE_LUNATIC=1,CONFIG_BOOL_INSTANCE_IGNORE_LEVEL=1,CONDITION_FROM_AREATRIGGER=1;
const unsigned TELE_TO_FORCE_MAP_CHANGE=16;
struct WorldLocation {unsigned mapId=36;float x=-14,y=-385,z=62,o=1;};
struct AreaTriggerTeleport {unsigned requiredPhase=0,requiredLevel=10,requiredCondition=0;WorldLocation destination;};
struct MapEntry {unsigned mapType=1,maxPlayers=5;bool IsNonRaidDungeon()const{return mapType==1;}};
struct Storage {std::map<unsigned,MapEntry> entries;template<class T>T* LookupEntry(unsigned id){auto i=entries.find(id);return i==entries.end()?nullptr:&i->second;}}sMapStorage;
struct Objects {std::map<unsigned,AreaTriggerTeleport> portals;std::set<unsigned> triggers;
 AreaTriggerTeleport* GetAreaTriggerTeleport(unsigned id){auto i=portals.find(id);return i==portals.end()?nullptr:&i->second;}
 bool GetAreaTrigger(unsigned id){return triggers.count(id);}}sObjectMgr;
struct Spells {std::map<unsigned,WorldLocation> locations;WorldLocation* GetSpellTargetPosition(unsigned id){auto i=locations.find(id);return i==locations.end()?nullptr:&i->second;}}sSpellMgr;
struct Config {bool enabled=true;std::map<std::string,int> overrides;
 bool GetBoolDefault(const char*,bool){return enabled;}
 int GetIntDefault(const char* name,int def){auto i=overrides.find(name);return i==overrides.end()?def:i->second;}}sConfig;
struct World {unsigned phase=0;bool ignoreLevel=false;unsigned GetContentPhase(){return phase;}bool getConfig(int){return ignoreLevel;}}sWorld;
struct Log {template<class... T>void outError(const char*,T...){}template<class... T>void outBasic(const char*,T...){}}sLog;
struct Save {unsigned id=77;};
struct Bind {Save* state=nullptr;bool perm=false;};
struct Group {unsigned count=5,leader=1;bool raid=false;Bind bind;
 unsigned GetMembersCount(){return count;}bool isRaidGroup(){return raid;}unsigned GetLeaderGuid(){return leader;}
 Bind* GetBoundInstance(unsigned){return bind.state?&bind:nullptr;}
 void BindToInstance(Save* s,bool perm){bind={s,perm};}};
struct Player;
struct DungeonMap {Save save;unsigned mapId=36,count=0,capacity=5;bool canEnter=true;
 unsigned GetInstanceId(){return save.id;}Save* GetPersistanceState(){return &save;}
 unsigned GetPlayersCountExceptGMs(){return count;}unsigned GetMaxPlayers(){return capacity;}
 bool CanEnter(Player*);
};
struct Player {
 unsigned guid=0,level=60,calls=0,lastOptions=0;Group* group=nullptr;DungeonMap* map=nullptr;Bind personal;
 bool session=true,world=true,alive=true,teleport=false,combat=false,taxi=false,bg=false,bgQueue=false,gm=false,lunatic=false,condition=true,instanceCount=true,teleportResult=true;
 WorldLocation scheduled;
 bool GetSession(){return session;}bool IsInWorld(){return world;}Group* GetGroup(){return group;}
 bool IsAlive(){return alive;}bool IsBeingTeleported(){return teleport;}bool IsInCombat(){return combat;}
 bool IsTaxiFlying(){return taxi;}bool InBattleGround(){return bg;}bool InBattleGroundQueue(){return bgQueue;}
 bool IsGameMaster(){return gm;}bool HasChallenge(int){return lunatic;}unsigned GetLevel(){return level;}
 const char* GetName(){return "Fixture";}DungeonMap* GetMap(){return map;}
 unsigned GetObjectGuid(){return guid;}unsigned GetMapId(){return map?map->mapId:0;}
 unsigned GetInstanceId(){return map?map->save.id:0;}
 Bind* GetBoundInstance(unsigned){return personal.state?&personal:nullptr;}
 Save* GetBoundInstanceSaveForSelfOrGroup(unsigned){return personal.perm?personal.state:group->bind.state?group->bind.state:personal.state;}
 bool CheckInstanceCount(unsigned){return instanceCount;}
 bool TeleportTo(unsigned id,float x,float y,float z,float o,unsigned options){
  assert(group->bind.state);++calls;scheduled={id,x,y,z,o};lastOptions=options;return teleportResult;
 }
};
bool DungeonMap::CanEnter(Player* p){assert(p->map!=this);return canEnter;}
struct MapManager {DungeonMap target;bool valid=true,create=true;
 static bool IsValidMapCoord(unsigned,float x,float,float,float){return x==x;}
 DungeonMap* CreateMap(unsigned,Player*){return create?&target:nullptr;}}sMapMgr;
bool IsConditionSatisfied(unsigned,Player* p,DungeonMap*,Player*,int){return p->condition;}
struct ChatHandler {ChatHandler(Player*){}template<class... T>void PSendSysMessage(const char*,T...) {}};
struct LFTManager {
 struct Offer {std::string instance="The Deadmines";std::map<unsigned,unsigned> roles;std::set<unsigned> accepted;};
 std::map<unsigned,Player*> players;
 Player* GetPlayer(unsigned id)const {auto i=players.find(id);return i==players.end()?nullptr:i->second;}
 void Send(Player*,std::string const&)const{}
 bool ValidateTeleportDestinations(Player*,std::vector<std::string> const&)const;
 bool TeleportGroupToInstance(Offer const&);
};
''' + production + r'''
int main(){
 // Verify every display label and short code extracted from the reference UI.
'''
for row in reference['dungeons']:
    name, short = json.dumps(row['name']), json.dumps(row['code'])
    code += f'assert(LFT::FindDungeonEntrance({name})); assert(LFT::FindDungeonEntrance({name})==LFT::FindDungeonEntrance({short}));\n'
code += r'''
 assert(!LFT::FindDungeonEntrance("Scarlet Monastery"));
 assert(!LFT::FindDungeonEntrance("Dire Maul"));
 assert(!LFT::FindDungeonEntrance("Unknown Dungeon"));
 assert(LFT::FindDungeonEntrance("Scarlet Monastery Library")->trigger==614);
 assert(LFT::FindDungeonEntrance("Scarlet Monastery Cathedral")->trigger==610);
 assert(LFT::FindDungeonEntrance("Dire Maul East")->trigger==3183);
 assert(LFT::FindDungeonEntrance("Dire Maul West")->trigger==3186);
 assert(LFT::FindDungeonEntrance("Dire Maul North")->trigger==3189);
 auto choices=LFT::SplitDungeonChoices("Stratholme: Undead District:Caverns of Time: Black Morass:The Deadmines");
 assert(choices.size()==3 && choices[0]=="Stratholme: Undead District" && choices[2]=="The Deadmines");
 sObjectMgr.portals[78]={};sObjectMgr.triggers.insert(78);sMapStorage.entries[36]={};
 Group group;std::vector<Player> p(5);LFTManager mgr;LFTManager::Offer offer;
 for(unsigned i=0;i<5;++i){p[i].guid=i+1;p[i].group=&group;mgr.players[i+1]=&p[i];offer.roles[i+1]=i==0?1:i==1?2:4;offer.accepted.insert(i+1);}
 auto reset=[&]{for(auto& x:p)x.calls=0;group.bind={};};
 auto noMoves=[&]{for(auto& x:p)assert(!x.calls);};
 assert(mgr.ValidateTeleportDestinations(&p[0],{"The Deadmines"}));
 assert(!mgr.ValidateTeleportDestinations(&p[0],{"Scarlet Monastery"}));
 assert(mgr.TeleportGroupToInstance(offer));
 for(auto& x:p){assert(x.calls==1 && x.scheduled.mapId==36);assert(x.scheduled.z==62);}
 assert(group.bind.state==sMapMgr.target.GetPersistanceState());reset();
 offer.accepted.erase(5);assert(!mgr.TeleportGroupToInstance(offer));noMoves();offer.accepted.insert(5);
 for(bool Player::* f:{&Player::combat,&Player::teleport,&Player::taxi,&Player::bg,&Player::bgQueue}){
  p[4].*f=true;assert(!mgr.TeleportGroupToInstance(offer));noMoves();p[4].*f=false;
 }
 for(bool Player::* f:{&Player::alive,&Player::session,&Player::world,&Player::instanceCount}){
  p[4].*f=false;assert(!mgr.TeleportGroupToInstance(offer));noMoves();p[4].*f=true;
 }
 p[4].level=1;assert(!mgr.TeleportGroupToInstance(offer));noMoves();p[4].level=60;
 sObjectMgr.portals[78].requiredPhase=2;assert(!mgr.TeleportGroupToInstance(offer));noMoves();sObjectMgr.portals[78].requiredPhase=0;
 sObjectMgr.portals[78].requiredCondition=5;p[4].condition=false;
 assert(!mgr.TeleportGroupToInstance(offer));noMoves();p[4].condition=true;sObjectMgr.portals[78].requiredCondition=0;
 Save conflicting{88};p[4].personal={&conflicting,true};assert(!mgr.TeleportGroupToInstance(offer));noMoves();p[4].personal={};
 sMapMgr.target.count=1;assert(!mgr.TeleportGroupToInstance(offer));noMoves();sMapMgr.target.count=0;
 sMapMgr.target.canEnter=false;assert(!mgr.TeleportGroupToInstance(offer));noMoves();sMapMgr.target.canEnter=true;
 // Existing members must not trigger Map::CanEnter's already-in-map assertion;
 // someone in another copy of the same map requires a real map transfer.
 DungeonMap other;other.save.id=99;p[0].map=&sMapMgr.target;p[4].map=&other;
 sMapMgr.target.count=1;
 assert(mgr.TeleportGroupToInstance(offer));assert(p[0].lastOptions==0);assert(p[4].lastOptions==TELE_TO_FORCE_MAP_CHANGE);
 reset();p[0].map=nullptr;p[4].map=nullptr;sMapMgr.target.count=0;
 // Unknown aliases require explicit configuration; overworld and raids remain forbidden.
 sConfig.overrides["LFT.Teleport.Entrance.customdungeon"]=78;
 assert(mgr.ValidateTeleportDestinations(&p[0],{"Custom Dungeon"}));
 sMapStorage.entries[36].mapType=0;assert(!mgr.ValidateTeleportDestinations(&p[0],{"Custom Dungeon"}));
 sMapStorage.entries[36].mapType=2;assert(!mgr.ValidateTeleportDestinations(&p[0],{"Custom Dungeon"}));sMapStorage.entries[36].mapType=1;
 // Princess uses the actual Scepter portal destination while keeping dungeon entrance requirements.
 sObjectMgr.portals[3133]={};sObjectMgr.portals[3133].destination.mapId=349;sObjectMgr.portals[3133].requiredLevel=30;
 sObjectMgr.triggers.insert(3133);sMapStorage.entries[349]={};
 assert(!PartyEntrance("Maraudon Princess"));
 sSpellMgr.locations[21128]={349,419.84f,11.33f,-131.079f,0};
 auto princess=PartyEntrance("Maraudon Princess");assert(princess && princess->requiredLevel==30 && princess->destination.z<0);
 sConfig.enabled=false;assert(mgr.TeleportGroupToInstance(offer));noMoves();
}
'''
with tempfile.TemporaryDirectory(prefix='lft-party-') as tmp:
    source = Path(tmp) / 'test.cpp'
    source.write_text(code)
    exe = Path(tmp) / 'test'
    subprocess.run(['g++', '-std=c++17', '-Wall', '-Wextra', '-fsanitize=address,undefined',
                    '-fno-omit-frame-pointer', '-I', str(repo / 'src/game/LFT'), str(source), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
print('PASS: 34 historical UI labels/codes, distinct wings, colon labels, all-five acceptance, whole-party preflight, lockouts/capacity, shared binding, same-map transfer and Princess portal (ASan/UBSan)')
