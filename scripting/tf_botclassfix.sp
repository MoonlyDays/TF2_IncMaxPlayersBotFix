#pragma semicolon 1

#include <dhooks>

public Plugin myinfo = 
{
	name = "[TF2] \"HandleCommand_JoinClass( undefined ) - invalid class name\" fix",
	author = "Moonly Days",
	description = "",
	version = "1.0.0",
	url = "https://github.com/MoonlyDays/TF2_IncMaxPlayersBotFix"
};

DynamicDetour hHandleJoinClass;
ConVar tf_bot_reevaluate_class_in_spawnroom;

public OnPluginStart()
{
    Handle hGameData = LoadGameConfigFile("tf2.botclassfix");
    if(hGameData == INVALID_HANDLE)
        SetFailState("tf2.botclassfix.txt not found");

    hHandleJoinClass = new DynamicDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_Ignore);
    if (!hHandleJoinClass)
        SetFailState("Failed to setup detour for CTFPlayer::HandleCommand_JoinClass");

    if(!hHandleJoinClass.SetFromConf(hGameData, SDKConf_Signature, "CTFPlayer::HandleCommand_JoinClass"))
        SetFailState("Failed to load CTFPlayer::HandleCommand_JoinClass from gamedata");
    delete hGameData;

    hHandleJoinClass.AddParam(HookParamType_CharPtr);
    hHandleJoinClass.AddParam(HookParamType_Bool);
    
    if (!hHandleJoinClass.Enable(Hook_Pre, CTFPlayer_HandleCommand_JoinClass))
        SetFailState("Failed to detour CTFPlayer::HandleCommand_JoinClass.");

    // Remove cheat option 
    tf_bot_reevaluate_class_in_spawnroom = FindConVar("tf_bot_reevaluate_class_in_spawnroom");
    tf_bot_reevaluate_class_in_spawnroom.SetBool(false);
}

// void CTFPlayer::HandleCommand_JoinClass()
public MRESReturn CTFPlayer_HandleCommand_JoinClass(DHookParam hParams) 
{
    char szClassName[PLATFORM_MAX_PATH]; 
    hParams.GetString(1, szClassName, sizeof(szClassName));
    if(StrEqual(szClassName, "undefined"))
    {
        hParams.SetString(1, "auto");
        return MRES_ChangedHandled;
    }

    return MRES_Ignored;
}