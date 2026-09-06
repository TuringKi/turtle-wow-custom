#!/usr/bin/env python3
"""Compile the actual dungeon-exit follower decision against stateful doubles."""
from pathlib import Path
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
source = (repo / 'modules/mod-playerbots/src/playerbot/PlayerbotAI.cpp').read_text()
a = source.index('static bool FollowMasterOutOfDungeon(')
b = source.index('void PlayerbotAI::DoNextAction(', a)
assert 'if (FollowMasterOutOfDungeon(this))\n        return;' in source[b:]
pre = r'''
#include <cassert>
#include <string>
#include <set>
struct Map {
 bool dungeon=false, raid=false, instance=false;
 bool IsDungeon(){return dungeon;} bool IsRaid(){return raid;}
 bool Instanceable(){return instance;}
};
struct Group {bool raid=false; bool isRaidGroup(){return raid;}};
struct Session {bool logout=false; bool isLogingOut(){return logout;}};
struct Player {
 Group* group=nullptr; Map* map=nullptr; Session session;
 bool world=true, teleport=false, alive=true, combat=false, taxi=false;
 bool transport=false, bg=false, queue=false, hasSession=true, works=true;
 int calls=0; unsigned mapId=0, target=999; float x=1,y=2,z=3,o=4;
 Group* GetGroup(){return group;} Map* GetMap(){return map;}
 Session* GetSession(){return hasSession?&session:nullptr;}
 bool IsInWorld(){return world;} bool IsBeingTeleported(){return teleport;}
 bool IsAlive(){return alive;} bool IsInCombat(){return combat;}
 bool IsTaxiFlying(){return taxi;} bool GetTransport(){return transport;}
 bool InBattleGround(){return bg;} bool InBattleGroundQueue(){return queue;}
 unsigned GetGUIDLow(){return 1;} unsigned GetMapId(){return mapId;}
 float GetPositionX(){return x;} float GetPositionY(){return y;}
 float GetPositionZ(){return z;} float GetOrientation(){return o;}
 const char* GetName(){return "fixture";}
 bool TeleportTo(unsigned m,float a,float b,float c,float d){
  ++calls; assert(a==1 && b==2 && c==3 && d==4); target=m;
  if(works) teleport=true;
  return works;
 }
};
enum class BotState {BOT_STATE_NON_COMBAT};
struct PlayerbotAI {
 Player* bot; Player* master;
 bool real=false, humanMaster=true, movable=true;
 std::set<std::string> strategies={"follow"}; int stopped=0;
 Player* GetBot(){return bot;} Player* GetMaster(){return master;}
 bool IsRealPlayer(){return real;} bool HasRealPlayerMaster(){return humanMaster;}
 bool HasStrategy(const char* s,BotState){return strategies.count(s);}
 bool CanMove(){return movable;} void StopMoving(){++stopped;}
};
struct Manager {bool external=false; bool IsExternallyManaged(unsigned){return external;}} sRandomPlayerbotMgr;
struct Log {template<class... T> void outBasic(T...) {}} sLog;
struct Fixture {
 Map dungeon{true,false,true}, world; Group group; Player bot, master;
 PlayerbotAI ai{&bot,&master};
 Fixture(){bot.map=&dungeon;master.map=&world;bot.group=master.group=&group;bot.mapId=800;}
 void blocked(){assert(!FollowMasterOutOfDungeonProxy());assert(bot.calls==0);}
 bool FollowMasterOutOfDungeonProxy();
};
'''
main = r'''
bool Fixture::FollowMasterOutOfDungeonProxy(){return FollowMasterOutOfDungeon(&ai);}
int main(){
 {Fixture f;assert(FollowMasterOutOfDungeon(&f.ai));assert(f.bot.calls==1 && f.bot.target==0);
  assert(!FollowMasterOutOfDungeon(&f.ai));assert(f.bot.calls==1);
  f.bot.teleport=false;f.bot.map=&f.world;assert(!FollowMasterOutOfDungeon(&f.ai));assert(f.bot.calls==1);}
 for(bool Player::*flag : {&Player::combat,&Player::taxi,&Player::transport,&Player::bg,&Player::queue,&Player::teleport})
  for(int who=0;who<2;++who){Fixture f;(who?&f.master:&f.bot)->*flag=true;f.blocked();
   (who?&f.master:&f.bot)->*flag=false;assert(FollowMasterOutOfDungeon(&f.ai));}
 for(bool Player::*flag : {&Player::world,&Player::alive,&Player::hasSession})
  for(int who=0;who<2;++who){Fixture f;(who?&f.master:&f.bot)->*flag=false;f.blocked();}
 for(int who=0;who<2;++who){Fixture f;(who?&f.master:&f.bot)->session.logout=true;f.blocked();}
 {Fixture f;f.ai.real=true;f.blocked();}
 {Fixture f;f.ai.humanMaster=false;f.blocked();}
 {Fixture f;f.ai.master=nullptr;f.blocked();}
 {Fixture f;f.ai.movable=false;f.blocked();}
 {Fixture f;f.bot.group=nullptr;f.blocked();}
 {Fixture f;Group other;f.master.group=&other;f.blocked();}
 {Fixture f;f.group.raid=true;f.blocked();}
 {Fixture f;f.dungeon.raid=true;f.blocked();}
 {Fixture f;f.master.map=&f.dungeon;f.blocked();}
 {Fixture f;f.world.instance=true;f.blocked();}
 {Fixture f;f.bot.map=nullptr;f.blocked();}
 {Fixture f;f.master.map=nullptr;f.blocked();}
 {Fixture f;sRandomPlayerbotMgr.external=true;f.blocked();sRandomPlayerbotMgr.external=false;}
 for(const char* s:{"stay","guard"}){Fixture f;f.ai.strategies.insert(s);f.blocked();}
 {Fixture f;f.ai.strategies.clear();f.blocked();}
 {Fixture f;f.ai.strategies={"wander"};assert(FollowMasterOutOfDungeon(&f.ai));}
 {Fixture f;f.bot.works=false;assert(!FollowMasterOutOfDungeon(&f.ai));assert(!f.bot.teleport);
  f.bot.works=true;assert(FollowMasterOutOfDungeon(&f.ai));assert(f.bot.calls==2);}
}
'''
with tempfile.TemporaryDirectory(prefix='bot-exit-test-') as d:
    cpp, binary = Path(d)/'test.cpp', Path(d)/'test'
    cpp.write_text(pre + source[a:b] + main)
    subprocess.run(['g++','-std=c++17','-Wall','-Wextra','-fsanitize=address,undefined','-fno-omit-frame-pointer',str(cpp),'-o',str(binary)],check=True)
    subprocess.run([str(binary)],check=True)
print('PASS: dungeon exit, retries, transfer ACK boundary, stay/guard, identity and group restrictions')
