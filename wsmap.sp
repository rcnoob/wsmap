#include <sourcemod>
#include <sdktools>
#undef REQUIRE_EXTENSIONS
#include <regex>
#define REQUIRE_EXTENSIONS

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"

public Plugin myinfo = {
    name = "wsmap",
    author = "rcnoob",
    description = "!wsmap <id>",
    version = PLUGIN_VERSION,
    url = ""
};

bool g_bMapChanging = false;

public void OnPluginStart()
{
    RegConsoleCmd("sm_wsmap", Command_WSMap, "Change to a specific workshop map id");
    
    HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
}

public Action Command_WSMap(int client, int args)
{
    if (args < 1)
    {
        ReplyToCommand(client, "[SM] Usage: sm_wsmap <workshop_id>");
        return Plugin_Handled;
    }
    
    if (g_bMapChanging)
    {
        ReplyToCommand(client, "[SM] Map change already in progress. Please wait.");
        return Plugin_Handled;
    }
    
    char workshopId[32];
    GetCmdArg(1, workshopId, sizeof(workshopId));
    
    if (!IsNumeric(workshopId))
    {
        ReplyToCommand(client, "[SM] Invalid workshop ID. Please use numbers only.");
        return Plugin_Handled;
    }
    
    ChangeToWorkshopMap(client, workshopId);
    return Plugin_Handled;
}

void ChangeToWorkshopMap(int client, const char[] workshopId)
{
    g_bMapChanging = true;
    
    char clientName[MAX_NAME_LENGTH];
    GetClientName(client, clientName, sizeof(clientName));
    
    PrintToChatAll("[SM] %s is changing map to workshop map %s...", clientName, workshopId);
    PrintToServer("[SM] Changing to workshop map %s", workshopId);
    
    char workshopCmd[128];
    Format(workshopCmd, sizeof(workshopCmd), "host_workshop_map %s", workshopId);
    ServerCommand(workshopCmd);
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
    g_bMapChanging = false;
}

public void OnMapEnd()
{
    g_bMapChanging = false;
}

bool IsNumeric(const char[] str)
{
    int len = strlen(str);
    if (len == 0)
        return false;
    
    for (int i = 0; i < len; i++)
    {
        if (!IsCharNumeric(str[i]))
            return false;
    }
    
    return true;
}