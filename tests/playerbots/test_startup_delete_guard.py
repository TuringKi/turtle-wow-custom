#!/usr/bin/env python3
"""Run production startup cleanup against fake databases; never connect to MySQL."""
from pathlib import Path
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[2]
source = (repo / 'modules/mod-playerbots/src/playerbot/RandomPlayerbotFactory.cpp').read_text()
start = source.index('    // check if scheduled for delete')
end = source.index('    if (!sPlayerbotAIConfig.randomBotAutoCreate)', start)
body = source[start:end]
fakes = r'''
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <list>
#include <sstream>
#include <string>
using uint32=uint32_t;
using std::find;
int writes=0; bool scheduled=false;
struct Field {uint32 GetUInt32() const{return 2;}};
struct Result {Field f;Field* Fetch(){return &f;} bool NextRow(){return false;}uint32 GetRowCount(){return 1;}} result;
struct Database {
 Result* Query(const char*) {return scheduled?&result:nullptr;}
 template<class... T> Result* PQuery(const char*,T...){return &result;}
 template<class... T> void PExecute(const char*,T...){++writes;}
 void Execute(const char*){++writes;}
} CharacterDatabase,LoginDatabase;
struct Config {bool deleteRandomBotAccounts=false;uint32 randomBotAccountCount=1;std::string randomBotAccountPrefix="TEST";} sPlayerbotAIConfig;
struct Logger {template<class... T> void outError(const char*,T...){} template<class... T> void outString(const char*,T...) {}} sLog;
struct ObjectGuid {ObjectGuid(int,uint32) {}};
const int HIGHGUID_PLAYER=0,SOCIAL_FLAG_FRIEND=1;
struct Player {static uint32 GetGuildIdFromDB(ObjectGuid){return 0;}static void DeleteFromDB(ObjectGuid,uint32,bool,bool){++writes;}};
struct Guild {uint32 GetLeaderGuid(){return 1;}} guild;
struct GuildMgr {Guild* GetGuildById(uint32){return &guild;}} sGuildMgr;
struct ObjectMgr {uint32 GetPlayerAccountIdByGUID(uint32){return 1;}} sObjectMgr;
struct BotMgr {void OnPlayerLoginError(uint32){}} sRandomPlayerbotMgr;
struct AccountMgr {void DeleteAccount(uint32){++writes;}uint32 GetCharactersCount(uint32){return 0;}} sAccountMgr;
struct BarGoLink {explicit BarGoLink(uint32){}void step(){}};
'''
cases = r'''
int main() {
 for(bool pending : {false,true}) {
  scheduled=pending;writes=0;sPlayerbotAIConfig.deleteRandomBotAccounts=false;
  cleanup();assert(writes==0);
 }
 scheduled=true;writes=0;sPlayerbotAIConfig.deleteRandomBotAccounts=true;
 cleanup();assert(writes>0);
}
'''
with tempfile.TemporaryDirectory(prefix='bot-delete-guard-') as directory:
    cpp=Path(directory)/'test.cpp';binary=Path(directory)/'test'
    cpp.write_text(fakes+'\nvoid cleanup() {\n'+body+'\n}\n'+cases)
    subprocess.run(['g++','-std=c++17','-Wall','-Wextra',str(cpp),'-o',str(binary)],check=True)
    subprocess.run([str(binary)],check=True)
print('PASS: deletion disabled with/without queued request; explicit opt-in retained')
