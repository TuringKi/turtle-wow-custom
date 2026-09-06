#!/usr/bin/env python3
"""Exercise compiled production LFT functions with in-memory world doubles.

No database, server, or client is needed. Network/group creation are captured
at the boundary; matching, role checks, offers and fill selection are real code.
"""
from pathlib import Path
import re
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
def read(path):
    return (repo / path).read_text()
def function(path, name):
    source = read(path)
    match = re.search(r'^[^\n]*LFTManager::' + name + r'\(', source, re.M)
    assert match, name
    end = source.index('\n}', match.start()) + 2
    return source[match.start():end] + '\n'

queue = 'src/game/LFT/LFTQeueue.cpp'
fill = 'src/game/LFT/LFTBotFill.cpp'
header = re.sub(r'^#include "[^\n]+\n', '', read('src/game/LFT/LFTMgr.h'), flags=re.M)
header = header.replace('class LFTManager\n{', 'class LFTManager\n{\npublic:').replace('private:', 'public:')
code = r'''
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <sstream>
using uint8=uint8_t; using uint32=uint32_t; using uint64=uint64_t;
struct ObjectGuid {
 unsigned id=0; ObjectGuid(unsigned v=0):id(v){}
 bool IsEmpty() const {return !id;}
 bool operator<(ObjectGuid o) const {return id<o.id;}
 bool operator==(ObjectGuid o) const {return id==o.id;}
 bool operator!=(ObjectGuid o) const {return id!=o.id;}
};
''' + header + r'''
enum { CONFIG_BOOL_LFT_BOTFILL_ENABLE, CONFIG_UINT32_LFT_BOTFILL_DELAY,
 CONFIG_UINT32_LFT_BOTFILL_LEVEL_BELOW, CONFIG_UINT32_LFT_BOTFILL_LEVEL_ABOVE,
 CONFIG_UINT32_LFT_BOTFILL_LEVEL_BELOW_HEALER, CONFIG_BOOL_ALLOW_TWO_SIDE_INTERACTION_GROUP };
const unsigned IN_MILLISECONDS=1000;
struct World {
 std::map<int,unsigned> config={{0,1},{1,60},{2,2},{3,6},{4,4},{5,0}};
 unsigned getConfig(int k) {return config[k];}
 time_t GetGameTime(){return time(nullptr);}
} sWorld;
struct Log {template<class... T> void outBasic(const char*,T...) {}} sLog;
struct Group {struct MemberSlot{ObjectGuid guid;}; std::vector<MemberSlot> members;
 const auto& GetMemberSlots(){return members;}};
struct Player {
 ObjectGuid guid; unsigned level=60,team=1; bool hardcore=false,candidate=true,machine=true;
 uint8 roles=4,allowed=4,forced=0; Group* group=nullptr; std::vector<std::string> messages;
 ObjectGuid GetObjectGuid() const{return guid;} const char* GetName() const{return "Fixture";}
 unsigned GetLevel() const{return level;} unsigned GetTeam() const{return team;}
 bool IsHardcore() const{return hardcore;} bool IsInWorld() const{return true;}
 bool IsAlive() const{return true;} bool InBattleGround()const{return false;}
 bool InBattleGroundQueue()const{return false;} Group* GetGroup()const{return group;}
};
struct Accessor {std::map<ObjectGuid,Player*> players; const auto& GetPlayers(){return players;}} sObjectAccessor;
bool Script_IsLFTBotCandidate(Player* p){return p->candidate;}
bool Script_IsMachineDriven(Player* p){return p->machine;}
uint8 Script_GetAllowedRoles(Player* p){return p->roles;}
void Script_SetForcedRole(Player* p,uint8 role){p->forced=role;}
unsigned completed=0;
bool teleportAllowed=true;
struct Config {bool GetBoolDefault(const char*,bool){return false;}} sConfig;
LFTManager::LFTManager():m_nextListingId(1),m_nextOfferId(1),m_nextQueueOrder(1),m_listingsLoaded(false),m_botFillTimer(0){}
Player* LFTManager::GetPlayer(ObjectGuid const& g)const {auto i=sObjectAccessor.players.find(g);return i==sObjectAccessor.players.end()?nullptr:i->second;}
uint8 LFTManager::AllowedRoleMask(Player const* p)const{return p->allowed;}
std::string LFTManager::ClassName(Player const*)const{return "Fixture";}
bool LFTManager::CanPlayersGroup(Player const* a,Player const* b)const{return a->team==b->team && a->hardcore==b->hardcore;}
void LFTManager::Send(Player* p,std::string const& m)const {p->messages.push_back(m);}
void LFTManager::SeedBotOnlyQueue(){} // Separate opt-in feature, disabled in this deployment.
Player* LFTManager::TakeFromBotOnlyGroup(uint8,QueuedPlayer const&,uint32,uint32){return nullptr;}
bool LFTManager::AddPlayerToGroup(Group*&,ObjectGuid const&,ObjectGuid const&){return true;}
void LFTManager::TeleportBotGroupToInstance(Offer const&){++completed;}
bool LFTManager::TeleportGroupToInstance(Offer const&){return teleportAllowed;}
'''
# Anonymous helpers are copied verbatim too.
q = read(queue)
code += q[q.index('namespace\n{'):q.index('void LFTManager::HandleQueueJoin')]
f = read(fill)
code += 'namespace {\n' + f[f.index('    bool ListsInstance'):f.index('\nbool LFTManager::IsFillBot')]
for name in ['IsFillBot', 'ForgetFillBot', 'RealPlayerWaitsFor', 'DropUnneededFillBots',
             'TakeBotAndRespecFor', 'FillInstanceWithBots', 'AcceptOffersForFillBots', 'UpdateBotFill']:
    code += function(fill, name)
for name in ['CanQueuedPlayersGroup', 'GetPartyMembers', 'GetQueueOrder', 'ParseRoleMask', 'JoinStrings',
             'StartRolecheck', 'HandleRolecheckResponse', 'EnqueueRolecheck', 'EnqueuePlayer',
             'SendQueueJoined', 'SendQueuedStatus', 'SendQueueLeft', 'TryMakeOffers',
             'TryBuildOfferForInstance', 'HandleOfferAccept', 'CompleteOffer', 'CancelOffer']:
    code += function(queue, name)
code += r'''
int main(){
 std::vector<Player> p(12);
 for(unsigned i=0;i<p.size();++i){p[i].guid=i+1;sObjectAccessor.players[p[i].guid]=&p[i];}
 p[0].candidate=false;p[0].machine=false;
 p[1].roles=p[1].allowed=1;p[2].roles=p[2].allowed=2;
 for(unsigned i=5;i<p.size();++i)p[i].candidate=false;
 auto enqueue=[&](LFTManager& m,unsigned i){m.EnqueuePlayer(&p[i],p[i].guid,{"Deadmines"},p[i].roles);};
 LFTManager m; enqueue(m,0);
 m.UpdateBotFill(5000);assert(m.m_queue.size()==1); // delay
 m.m_queue.at(p[0].guid).joinTime-=61;
 sWorld.config[0]=0;m.UpdateBotFill(5000);assert(m.m_queue.size()==1);
 sWorld.config[0]=1;m.UpdateBotFill(5000);assert(m.m_queue.size()==5);
 m.TryMakeOffers();assert(m.m_offers.size()==1);
 m.AcceptOffersForFillBots();assert(completed==0);assert(m.m_offers.begin()->second.accepted.size()==4);
 assert(!m.m_offers.begin()->second.accepted.count(p[0].guid));
 m.HandleOfferAccept(&p[0]);assert(completed==1 && m.m_offers.empty());
 m.DropUnneededFillBots();assert(m.m_fillBots.empty());
 assert(p[1].forced==1 && p[2].forced==2); // Successful match retains tank/healer strategy.
 LFTManager disabled;enqueue(disabled,0);
 disabled.FillInstanceWithBots("Deadmines",disabled.m_queue.at(p[0].guid));
 sWorld.config[0]=0;disabled.UpdateBotFill(5000);
 assert(disabled.m_fillBots.empty() && disabled.m_queue.size()==1);sWorld.config[0]=1;
 // Five DPS waiting must not suppress recruitment of a tank and healer.
 LFTManager crowded;for(unsigned i:{0u,5u,6u,7u,8u})enqueue(crowded,i);
 crowded.FillInstanceWithBots("Deadmines",crowded.m_queue.at(p[0].guid));
 crowded.TryMakeOffers();assert(crowded.m_offers.size()==1);
 assert(crowded.m_offers.begin()->second.roles.at(p[1].guid)==1);
 assert(crowded.m_offers.begin()->second.roles.at(p[2].guid)==2);
 // Offered players cannot be counted towards another waiting party.
 LFTManager reserved;enqueue(reserved,0);enqueue(reserved,1);reserved.m_playerOffers[p[1].guid]=99;
 p[9].candidate=true;p[9].roles=p[9].allowed=1;
 reserved.FillInstanceWithBots("Deadmines",reserved.m_queue.at(p[0].guid));
 assert(reserved.m_fillBots.count(p[9].guid));p[9].candidate=false;
 // Wrong faction, hardcore, and out-of-range tanks must not be recruited.
 for(int reason=0;reason<3;++reason){
  LFTManager invalid;enqueue(invalid,0);p[1].team=reason==0?2:1;
  p[1].hardcore=reason==1;p[1].level=reason==2?57:60;
  invalid.FillInstanceWithBots("Deadmines",invalid.m_queue.at(p[0].guid));
  assert(!invalid.m_queue.count(p[1].guid));invalid.TryMakeOffers();assert(invalid.m_offers.empty());
  invalid.m_queue.erase(p[0].guid);invalid.DropUnneededFillBots();assert(invalid.m_fillBots.empty());
 }
 p[1].team=1;p[1].hardcore=false;p[1].level=60;
 // Party bots answer their role popup; a real client (even with AI enabled)
 // still has to answer manually. Last response safely erases rolecheck.
 Group group;for(unsigned i=0;i<5;++i){group.members.push_back({p[i].guid});p[i].group=&group;}
 LFTManager party;party.StartRolecheck(&p[0],{"Deadmines"});
 assert(party.m_rolechecks.size()==1);assert(party.m_rolechecks.begin()->second.responses.size()==4);
 assert(!party.m_rolechecks.begin()->second.responses.count(p[0].guid));
 party.HandleRolecheckResponse(&p[0],{"C2S_ROLECHECK_RESPONSE","d"});
 assert(party.m_rolechecks.empty() && party.m_offers.size()==1);
 party.AcceptOffersForFillBots();assert(completed==1);
 party.HandleOfferAccept(&p[0]);assert(completed==2);
 // A rejected teleport must not send a successful offer completion.
 LFTManager rejected;rejected.StartRolecheck(&p[0],{"Deadmines"});
 rejected.HandleRolecheckResponse(&p[0],{"C2S_ROLECHECK_RESPONSE","d"});
 rejected.AcceptOffersForFillBots();teleportAllowed=false;
 rejected.HandleOfferAccept(&p[0]);assert(completed==2);
 assert(rejected.m_offers.empty() && rejected.m_queue.empty());
}
'''
with tempfile.TemporaryDirectory(prefix='lft-fill-') as tmp:
    source = Path(tmp) / 'workflow.cpp'
    source.write_text(code)
    exe = Path(tmp) / 'workflow'
    subprocess.run(['g++', '-std=c++17', '-Wall', '-Wextra', '-Wno-unused-function',
                    '-fsanitize=address,undefined', '-fno-omit-frame-pointer', str(source), '-o', str(exe)], check=True)
    subprocess.run([str(exe)], check=True)
print('PASS: LFT delay/disable, 1 tank + 1 healer + 3 DPS, manual human acceptance, crowded/offered queues, faction/hardcore/level, cancellation, bot party rolecheck (ASan/UBSan)')
