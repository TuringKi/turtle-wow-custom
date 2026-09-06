#!/usr/bin/env python3
"""Compile production command routing and use selection with small world doubles.
No server or database is started. --baseline=REV checks a historical revision.
"""
from pathlib import Path
import json
import re
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[2]
base = 'modules/mod-playerbots/src/playerbot/'
baseline = next((arg.split('=', 1)[1] for arg in sys.argv if arg.startswith('--baseline=')), None)
def read(path):
    if baseline:
        return subprocess.check_output(['git', 'show', baseline + ':' + path], cwd=repo, text=True)
    return (repo / path).read_text()
def body(path, begin, end):
    s = read(base + path)
    return s[s.index(begin):s.index(end, s.index(begin))]
def header(path):
    return re.sub(r'^#(?:include|pragma).*$', '', read(base + path), flags=re.M)
def run(code, name):
    with tempfile.TemporaryDirectory(prefix='bot-use-') as d:
        p = Path(d) / (name + '.cpp')
        p.write_text(code)
        exe = Path(d) / name
        subprocess.run(['g++', '-std=c++17', '-Wall', '-Wextra', '-Wno-unused-parameter', str(p), '-o', str(exe)], check=True)
        subprocess.run([str(exe)], check=True)

registry = read(base + 'strategy/triggers/ChatTriggerContext.h')
keys = re.findall(r'creators\["(u|use)"\].*?ChatCommandTrigger\(ai, "([^"]+)"\)', registry)
strategy = read(base + 'strategy/generic/ChatCommandHandlerStrategy.cpp')
listeners = re.findall(r'new TriggerNode\(\s*"([^"]+)",\s*NextAction::array\(0,\s*new NextAction\("use",', strategy)
route = r'''
#include <cassert>
#include <cstdint>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <vector>
using uint16 = uint16_t;
struct PlayerbotAI;
struct Player { const char* GetName() const {return "Test";} };
struct WorldPacket {uint16 GetOpcode() const {return 0;}};
struct Event {
 std::string source,param; Player* owner=nullptr;
 Event()=default;
 Event(std::string s,std::string p,Player* o):source(s),param(p),owner(o){}
 std::string getSource() const {return source;}
};
struct Trigger {
 bool triggered=false; std::string name,param; Player* owner=nullptr;
 Trigger(PlayerbotAI*,std::string n):name(n){}
 virtual ~Trigger()=default;
 std::string getName(){return name;}
 virtual void ExternalEvent(std::string p,Player* o=nullptr){param=p;owner=o;triggered=true;}
 virtual void ExternalEvent(WorldPacket&,Player*){}
 void ExternalEventForce(std::string p,Player* o){ExternalEvent(p,o);}
 virtual Event Check(){return Event();}
 virtual void Reset(){triggered=false;}
};
'''+header('strategy/triggers/ChatCommandTrigger.h')+r'''
struct Action {};
struct AiObjectContext {
 std::map<std::string,std::unique_ptr<Trigger>> triggers;
 std::set<std::string> actions={"use","open loot"}; Action action;
 Trigger* GetTrigger(std::string n){auto i=triggers.find(n);return i==triggers.end()?nullptr:i->second.get();}
 Action* GetAction(std::string n){return actions.count(n)?&action:nullptr;}
};
struct ChatHelper {
 static std::string parseValue(std::string,std::string){return "";}
 static bool parseable(std::string){return false;}
};
bool IsRealPlayer(Player* p){return p!=nullptr;}
'''+header('strategy/ExternalEventHelper.h')+r'''
using namespace ai;
struct PlayerbotAI {
 AiObjectContext context; std::string ran; Event event;
 AiObjectContext* GetAiObjectContext(){return &context;}
 void RecordMessages(bool,bool){}
 bool DoSpecificAction(std::string a,Event e,bool){ran=a;event=e;return true;}
 std::vector<std::string> GetRecordedMessages(){return {"ran"};}
} aiInstance;
PlayerbotAI* GetBotAI(Player*){return &aiInstance;}
std::vector<std::string> GetBotErrors(const char*){return {};}
struct PlayerbotHolder {
 std::string HandleConsoleCmd(Player*,Player*,const std::string);
 std::string HandleBotDo(Player*,Player*,const std::string);
};
'''+body('PlayerbotMgr.cpp','std::string PlayerbotHolder::HandleConsoleCmd(', 'std::string PlayerbotHolder::HandleBotTest(')+body('PlayerbotMgr.cpp','std::string PlayerbotHolder::HandleBotDo(', 'std::string PlayerbotHolder::HandleBotRecord(')+r'''
int main(){
 Player player,master; PlayerbotHolder holder; auto& ctx=aiInstance.context;
'''+''.join(f'ctx.triggers[{json.dumps(k)}]=std::make_unique<ChatCommandTrigger>(nullptr,{json.dumps(v)});\n' for k,v in keys).replace('\\n','\n')+r'''
 std::vector<std::string> listeners=LISTENERS;
 for(const std::string command : {"use go","u go","use 6948"}) {
  assert(holder.HandleConsoleCmd(&player,&master,command).find("Sending command")==0);
  int fired=0;
  for(auto& key:listeners){auto* t=ctx.GetTrigger(key);if(!t)continue;auto e=t->Check();
   if(!e.source.empty()){++fired;assert(e.owner==&master);assert(e.param==command.substr(command.find(' ')+1));}}
  assert(fired==1);
  for(auto& entry:ctx.triggers)entry.second->Reset();
 }
 for(const std::string command : {"use go","use 6948","use Some Object Name","open loot target","use"}) {
  assert(holder.HandleBotDo(&player,&master,command)=="ran\n");
  auto split=command.find(' ');
  if(command.find("open loot")==0){assert(aiInstance.ran=="open loot");assert(aiInstance.event.param=="target");}
  else {assert(aiInstance.ran=="use");assert(aiInstance.event.param==(split==std::string::npos?"":command.substr(split+1)));}
  assert(aiInstance.event.owner==&master);
 }
 assert(holder.HandleBotDo(&player,&master,"missing action")=="action not found");
}
'''
route=route.replace('LISTENERS','{'+','.join(json.dumps(x) for x in listeners)+'}')
if '--selection-only' not in sys.argv:
    run(route, 'routing')
    print('PASS: use/u queued dispatch, item parameter, direct actions with parameters', flush=True)

selection = r'''
#include <cassert>
#include <cstdint>
#include <list>
#include <map>
#include <string>
#include <vector>
using uint32=uint32_t; using ObjectGuid=int;
const int GAMEOBJECT_TYPE_GENERIC=5,GAMEOBJECT_FLAGS=1,GO_FLAG_NO_INTERACT=16;
const std::string LOS_GOS_PARAM="gos";
struct Unit {};
struct Item {uint32 entry;uint32 GetEntry(){return entry;}};
struct GameObject {
 int id;std::string name;float distance;int type=0;bool deleted=false,blocked=false;
 const char* GetName(){return name.c_str();}
 bool IsDeleted(){return deleted;}
 int GetGoType(){return type;}
 bool HasFlag(int,int){return blocked;}
};
struct Player:Unit {
 float GetDistance(GameObject* g){return g->distance;}
 ObjectGuid GetSelectionGuid(){return 0;}
 Item* GetItemByEntry(uint32){return nullptr;}
};
struct Event {Player* owner;std::string param;Player* getOwner(){return owner;}std::string getParam(){return param;}};
struct AI {
 std::list<ObjectGuid> nearby;std::map<int,GameObject*> objects;
 GameObject* GetGameObject(int g){return objects.count(g)?objects[g]:nullptr;}
 bool HasActivePlayerMaster(){return false;}
 Unit* GetUnit(ObjectGuid){return nullptr;}
 std::list<Item*> Inventory(std::string){return {};}
 void TellPlayerNoFacing(Player*,std::string){}
};
struct Chat {
 std::vector<uint32> parseItemsUnordered(std::string s,bool){return s.find("6948")!=std::string::npos?std::vector<uint32>{6948}:std::vector<uint32>{};}
 std::list<ObjectGuid> parseGameobjects(std::string s){return s.find("[object]")!=std::string::npos?std::list<ObjectGuid>{2}:std::list<ObjectGuid>{};}
};
struct LosModifierStruct{};
struct TellLosAction {
 static std::vector<LosModifierStruct> ParseLosModifiers(std::string){return {};}
 static std::list<GameObject*> GoGuidListToObjList(AI*,std::list<ObjectGuid>){return {};}
 static std::list<GameObject*> FilterGameObjects(Player*,std::list<GameObject*> a,std::vector<LosModifierStruct>){return a;}
};
#define AI_VALUE(type,key) ai->nearby
#define AI_VALUE2(type,key,arg) ai->Inventory(arg)
struct UseAction {
 AI* ai;Player* bot;Chat* chat;std::string name="use";int selected=0;uint32 usedItem=0;
 std::string getQualifier(){return "";}
 void MakeVerbose(bool){}
 bool Execute(Event&);
 bool UseGameObject(Player*,Event&,GameObject* g){selected=g->id;return true;}
 bool UseItem(Player*,uint32 id,GameObject* g){usedItem=id;selected=g->id;return true;}
 bool UseItem(Player*,uint32 id,Item*){usedItem=id;return true;}
 bool UseItem(Player*,uint32 id,Unit*){usedItem=id;return true;}
};
'''+body('strategy/actions/UseItemAction.cpp','bool UseAction::Execute(', 'bool UseAction::UseItem(Player* requester, uint32 itemId, Unit* target)')+r'''
int main(){
 Player p;Chat chat;AI ai;
 GameObject decor{1,"Decoration",1,GAMEOBJECT_TYPE_GENERIC},lever{2,"Lever",3},other{3,"Other",2};
 ai.objects={{1,&decor},{2,&lever},{3,&other}};ai.nearby={1,2,3};
 auto check=[&](std::string text,bool ok,int selected,uint32 item=0){
  UseAction use{&ai,&p,&chat};Event e{&p,text};assert(use.Execute(e)==ok);assert(use.selected==selected);assert(use.usedItem==item);
 };
 other.blocked=true;check("go",true,2);other.blocked=false;
 check("Lever",true,2);check("ever",true,2);check("missing",false,0);
 check("[object]",true,2);check("6948",true,0,6948);check("6948 [object]",true,2,6948);
 lever.deleted=true;other.blocked=true;check("go",false,0);
}
'''
run(selection, 'selection')
print('PASS: nearest interactive object, names, missing target, explicit link and inventory item isolation', flush=True)
