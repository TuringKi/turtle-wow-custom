#!/usr/bin/env python3
"""Compile the production summon handler against stateful session/teleport doubles.

Covers command decisions, not a real map transfer or client protocol exchange.
"""
from pathlib import Path
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
source = (repo / 'modules/mod-playerbots/src/playerbot/PlayerbotMgr.cpp').read_text()
start = source.index('std::string PlayerbotHolder::HandleBotSummon(')
end = source.index('std::string PlayerbotHolder::HandleBotRemoveLogout(', start)
handler = source[start:end]
preamble = r'''
#include <cassert>
#include <cstdint>
#include <string>
using uint32 = uint32_t;
#define SC_LOG(...) ((void)0)
struct Map { bool instance=false; bool Instanceable() const {return instance;} } world, instance;
struct Session {
    uint32 account=1; bool loading=false, logout=false;
    uint32 GetAccountId() const {return account;}
    bool PlayerLoading() const {return loading;}
    bool isLogingOut() const {return logout;}
};
struct Player;
struct PlayerbotAI {
    Player* bot=nullptr; Player* master=nullptr;
    bool real=false, ackWorks=true; int acks=0;
    bool IsRealPlayer() const;
    Player* GetMaster() const {return master;}
    void HandleTeleportAck();
};
struct Player {
    uint32 guid=2; Session session; PlayerbotAI ai;
    bool hasSession=true, hasAI=true, inWorld=true, teleporting=false;
    bool combat=false, bg=false, queue=false, teleportWorks=true;
    Map* map=&world; int teleports=0;
    Player() {ai.bot=this;}
    const char* GetName() const {return "test";}
    Session* GetSession() {return hasSession?&session:nullptr;}
    uint32 GetObjectGuid() const {return guid;}
    bool IsBeingTeleported() const {return teleporting;}
    bool IsInWorld() const {return inWorld;}
    bool IsInCombat() const {return combat;}
    bool InBattleGround() const {return bg;}
    bool InBattleGroundQueue() const {return queue;}
    Map* GetMap() const {return map;}
    uint32 GetMapId() const {return map==&world?0:33;}
    float GetPositionX() const {return 1;}
    float GetPositionY() const {return 2;}
    float GetPositionZ() const {return 3;}
    float GetOrientation() const {return 0;}
    bool TeleportTo(uint32,float,float,float,float) {++teleports;return teleportWorks;}
};
bool PlayerbotAI::IsRealPlayer() const {assert(bot->hasSession);return real;}
void PlayerbotAI::HandleTeleportAck() {
    ++acks;
    if(ackWorks) {bot->teleporting=false;bot->inWorld=true;}
}
PlayerbotAI* GetBotAI(Player* p) {return p->hasAI?&p->ai:nullptr;}
struct ObjectMgr {uint32 GetPlayerAccountIdByGUID(uint32 guid) const {return guid;}} sObjectMgr;
struct Config {bool random=true;bool IsInRandomAccountList(uint32) const {return random;}} sPlayerbotAIConfig;
struct PlayerbotHolder {std::string HandleBotSummon(Player*,Player*,const std::string);};
'''
cases = r'''
int main() {
    PlayerbotHolder holder; Player master; master.guid=1; instance.instance=true;
    assert(holder.HandleBotSummon(nullptr,&master,"").find("offline")!=std::string::npos);
    {Player b; auto r=holder.HandleBotSummon(&b,&master,"");assert(r.find("ok") == 0 && b.teleports==1);}
    {Player b;b.inWorld=false;b.teleporting=true;
     auto r=holder.HandleBotSummon(&b,&master,"");assert(r.find("ok")==0 && b.ai.acks==1 && b.teleports==1);}
    {Player b;b.inWorld=false;b.teleporting=true;b.ai.ackWorks=false;
     auto r=holder.HandleBotSummon(&b,&master,"");assert(r.find("changing maps")!=std::string::npos && b.ai.acks==1 && b.teleports==0);}
    {Player b;b.inWorld=false;auto r=holder.HandleBotSummon(&b,&master,"");
     assert(r.find("live session")!=std::string::npos && b.ai.acks==0 && b.teleports==0);}
    {Player b;b.hasSession=false;auto r=holder.HandleBotSummon(&b,&master,"");
     assert(r.find("logging")!=std::string::npos && b.teleports==0);}
    {Player b;b.session.loading=true;holder.HandleBotSummon(&b,&master,"");assert(b.ai.acks==0 && b.teleports==0);}
    {Player b;b.ai.real=true;holder.HandleBotSummon(&b,&master,"");assert(b.ai.acks==0 && b.teleports==0);}
    {Player b;b.teleporting=true;b.inWorld=false;sPlayerbotAIConfig.random=false;
     holder.HandleBotSummon(&b,&master,"");assert(b.ai.acks==0 && b.teleports==0);sPlayerbotAIConfig.random=true;}
    {Player b;b.teleportWorks=false;auto r=holder.HandleBotSummon(&b,&master,"");assert(r.find("rejected")!=std::string::npos);}
    {Player b;b.combat=true;holder.HandleBotSummon(&b,&master,"");assert(b.teleports==0);}
    {Player b;b.map=&instance;holder.HandleBotSummon(&b,&master,"");assert(b.teleports==0);}
    {Player b;b.bg=true;holder.HandleBotSummon(&b,&master,"");assert(b.teleports==0);}
}
'''
with tempfile.TemporaryDirectory(prefix='bot-summon-test-') as directory:
    cpp = Path(directory) / 'test.cpp'
    binary = Path(directory) / 'test'
    cpp.write_text(preamble + handler + cases)
    subprocess.run(['g++', '-std=c++17', '-Wall', '-Wextra', '-Wno-unused-parameter', str(cpp), '-o', str(binary)], check=True)
    subprocess.run([str(binary)], check=True)
print('PASS: 13 summon state and restriction cases')
