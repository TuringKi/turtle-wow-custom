#!/usr/bin/env python3
"""Compile the module's real LFT eligibility predicate against boundary doubles."""
from pathlib import Path
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
source = (repo / 'modules/mod-playerbots/src/playerbot/PlayerbotScripts.cpp').read_text()
start = source.index('        bool IsLFTBotCandidate(')
predicate = source[start:source.index('\n        }', start)+10].replace(' override', '')
code = r'''
#include <cassert>
#include <set>
struct Session {unsigned account=1181;unsigned GetAccountId(){return account;}};
struct Map {bool instance=false;bool Instanceable(){return instance;}};
struct PlayerbotAI {bool real=false,master=false;bool IsRealPlayer(){return real;}bool HasRealPlayerMaster(){return master;}};
struct Player {
 Session session;Map map;PlayerbotAI ai;bool hasSession=true,hasAI=true,group=false;
 bool world=true,alive=true,teleport=false,combat=false,taxi=false,bg=false,bgQueue=false;
 Session* GetSession()const{return hasSession?const_cast<Session*>(&session):nullptr;}
 Map* GetMap()const{return const_cast<Map*>(&map);}bool GetGroup()const{return group;}
 unsigned GetGUIDLow()const{return 1;}
 bool IsInWorld()const{return world;}bool IsAlive()const{return alive;}
 bool IsBeingTeleported()const{return teleport;}bool IsInCombat()const{return combat;}
 bool IsTaxiFlying()const{return taxi;}bool InBattleGround()const{return bg;}
 bool InBattleGroundQueue()const{return bgQueue;}
};
PlayerbotAI* GetBotAI(Player const* p){return p->hasAI?const_cast<PlayerbotAI*>(&p->ai):nullptr;}
struct Config {bool enabled=true;std::set<unsigned> accounts={1181};bool IsInRandomAccountList(unsigned id){return accounts.count(id);}}sPlayerbotAIConfig;
struct Manager {bool external=false;bool IsExternallyManaged(unsigned){return external;}}sRandomPlayerbotMgr;
struct Hooks {
''' + predicate + r'''
};
int main(){
 Hooks hook;Player p;assert(hook.IsLFTBotCandidate(&p));assert(!hook.IsLFTBotCandidate(nullptr));
 p.session.account=99;assert(!hook.IsLFTBotCandidate(&p));p.session.account=1181;
 for(bool Player::* flag:{&Player::hasSession,&Player::hasAI,&Player::world,&Player::alive}){
  p.*flag=false;assert(!hook.IsLFTBotCandidate(&p));p.*flag=true;
 }
 for(bool Player::* flag:{&Player::teleport,&Player::combat,&Player::taxi,&Player::bg,&Player::bgQueue}){
  p.*flag=true;assert(!hook.IsLFTBotCandidate(&p));p.*flag=false;
 }
 p.ai.real=true;assert(!hook.IsLFTBotCandidate(&p));p.ai.real=false;
 p.ai.master=true;assert(!hook.IsLFTBotCandidate(&p));p.ai.master=false;
 sRandomPlayerbotMgr.external=true;assert(!hook.IsLFTBotCandidate(&p));sRandomPlayerbotMgr.external=false;
 p.map.instance=true;assert(!hook.IsLFTBotCandidate(&p));p.group=true;assert(hook.IsLFTBotCandidate(&p));
 sPlayerbotAIConfig.enabled=false;assert(!hook.IsLFTBotCandidate(&p));
}
'''
with tempfile.TemporaryDirectory(prefix='lft-candidates-') as tmp:
    path = Path(tmp) / 'candidate.cpp'
    path.write_text(code)
    exe = Path(tmp) / 'candidate'
    subprocess.run(['g++', '-std=c++17', '-Wall', '-Wextra', str(path), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
print('PASS: registered accounts, real client/master exclusion, external reservations, offline/dead/transfer/combat/taxi/BG, solo instance and module disable')
