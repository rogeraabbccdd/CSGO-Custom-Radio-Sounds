#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <kento_csgocolors>
#include <cstrike>

#pragma newdecls required

// csgo/scripts/game_sound_...
// ctmap_ and tmap_ are map positions for bots
char g_radioSounds[][] = {
	"affirmative",
	"agree",
	"blinded",
	"bombexploding",
	"bombsiteclear",
	"bombtickingdown",
	"clear",
	"clearedarea",
	"commanderdown",
	"coveringfriend",
	"coverme",
	"death",
	"decoy",
	"defendingbombsitea",
	"defendingbombsiteb",
	"defusingbomb",
	"disagree",
	"endclean",
	"endclose",
	"endsolid",
	"enemydown",
	"enemyspotted",
	"fallback",
	"flashbang",
	"followingfriend",
	"followme",
	"friendlyfire",
	"goingtodefendbombsite",
	"goingtoguardhostageescapezone",
	"goingtoguardloosebomb",
	"goingtoplantbomb",
	"goingtoplantbomba",
	"goingtoplantbombb",
	"grenade",
	"guardingloosebomb",
	"heardnoise",
	"help",
	"hold",
	"incombat",
	"inposition",
	"killedfriend",
	"lastmanstanding",
	"letsgo",
	"locknload",
	"lostenemy",
	"molotov",
	"needbackup",
	"negative",
	"negativeno",
	"niceshot",
	"noenemiesleft",
	"noenemiesleftbomb",
	"onarollbrag",
	"oneenemyleft",
	"onmyway",
	"peptalk",
	"pinneddown",
	"plantingbomb",
	"query",
	"regroup",
	"reportingin",
	"requestreport",
	"scaredemote",
	"smoke",
	"sniperkilled",
	"sniperwarning",
	"spottedbomber",
	"spottedloosebomb",
	"takingfire",
	"thanks",
	"theypickedupthebomb",
	"threeenemiesleft",
	"time",
	"twoenemiesleft",
	"waitingforhumantodefusebomb",
	"waitinghere",
	"whereisthebomb",
}

#define MAXMODEL 200
char g_radioFiles[MAXMODEL][80][1024];
char g_model[MAXMODEL][1024];
int modelcount;

public Plugin myinfo =
{
	name = "[CS:GO] Custom Radio Sound",
	author = "Kento",
	version = "1.0.1",
	description = "Custom Radio Sound.",
	url = "http://steamcommunity.com/id/kentomatoryoshika/"
};

public void OnPluginStart() 
{
	// For disable default radio sound.
	AddNormalSoundHook(Event_SoundPlayed);
	
	// Listeners for radio commands.
	AddRadioCommandListeners();
	
	// Grenades
	HookUserMessage(GetUserMessageId("RadioText"), RadioText, true);
}


char g_radioCommands[][] = 
{
    "go",
    "cheer",
    "fallback",
    "sticktog",
    "holdpos",
    "followme",
    "roger",
    "negative",
    "compliment",
    "thanks",
    "enemyspot",
    "needbackup",
    "takepoint",
    "sectorclear",
    "inposition",
    "takingfire",
    "reportingin",
    "getout",
    "enemydown",
    "coverme",
    "regroup"
};

public void AddRadioCommandListeners()
{
	for (int i = 0; i < sizeof(g_radioCommands); i++)
		AddCommandListener(Command_Radio, g_radioCommands[i]);
}

public Action Command_Radio(int client, const char[] command, int argc) 
{
	if(IsValidClient(client))
	{
		char model[1024], sample[1024];
		GetClientModel(client, model, sizeof(model));
		int mid = FindModelIDByName(model);
		FindSampleByCmd(command, sample, sizeof(sample));
		int rid = FindRadioBySample(sample);
/*
		PrintToConsole(client, "cmd model %s", model);
		PrintToConsole(client, "cmd mid %d", mid);
		PrintToConsole(client, "cmd rid %d", rid);
		PrintToConsole(client, "cmd sample %s", sample);
		PrintToConsole(client, "cmd command %s", command);
*/		
		if(mid > -1 && rid > -1)
		{
			int team = GetClientTeam(client);
			
			char sound[1024];
			Format(sound, sizeof(sound), "*/%s", g_radioFiles[mid][rid]);
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i) && GetClientTeam(i) == team)
				{
					EmitSoundToClient(i, sound, SOUND_FROM_PLAYER, SNDCHAN_VOICE, SNDLEVEL_NONE);
				}
			}
		}
	}
}

void FindSampleByCmd(const char[] command, char[] sample, int maxlen)
{
	if(StrEqual(command,  "go"))				strcopy(sample, maxlen, "letsgo");		
	else if(StrEqual(command, "fallback"))		strcopy(sample, maxlen, "fallback");		
	else if(StrEqual(command, "sticktog"))		strcopy(sample, maxlen, "regroup");	
	else if(StrEqual(command, "holdpos"))		strcopy(sample, maxlen, "hold");	
	else if(StrEqual(command, "followme"))		strcopy(sample, maxlen, "followme");	
	else if(StrEqual(command, "roger"))			strcopy(sample, maxlen, "affirmative");	
	else if(StrEqual(command, "negative"))		strcopy(sample, maxlen, "negative");
	else if(StrEqual(command, "cheer"))			strcopy(sample, maxlen, "onarollbrag");	
	else if(StrEqual(command, "compliment"))	strcopy(sample, maxlen, "onarollbrag");	
	else if(StrEqual(command, "thanks"))		strcopy(sample, maxlen, "thanks");	
	else if(StrEqual(command, "enemyspot"))		strcopy(sample, maxlen, "enemyspotted");	
	else if(StrEqual(command, "needbackup"))	strcopy(sample, maxlen, "needbackup");
	else if(StrEqual(command, "takepoint"))		strcopy(sample, maxlen, "followingfriend");
	else if(StrEqual(command, "sectorclear"))	strcopy(sample, maxlen, "clear");
	else if(StrEqual(command, "inposition"))	strcopy(sample, maxlen, "inposition");
	else if(StrEqual(command, "takingfire"))	strcopy(sample, maxlen, "takingfire");
	else if(StrEqual(command, "reportingin"))	strcopy(sample, maxlen, "reportingin");
	else if(StrEqual(command, "getout"))		strcopy(sample, maxlen, "bombtickingdown");
	else if(StrEqual(command, "enemydown"))		strcopy(sample, maxlen, "enemydown");
	else if(StrEqual(command, "coverme"))		strcopy(sample, maxlen, "coverme");
	else if(StrEqual(command, "regroup"))		strcopy(sample, maxlen, "regroup");
}

public Action RadioText(UserMsg msg_id, Handle msg, const int[] players, int playersNum, bool reliable, bool init)
{
	/*
	https://github.com/alliedmodders/hl2sdk/blob/csgo/public/game/shared/csgo/protobuf/cstrike15_usermessages.proto#L268
	------------------------------------
	optional int32 msg_dst = 1;
	optional int32 client = 2;
	optional string msg_name = 3;
	repeated string params = 4;
	
	params strings cs_bloodstrike
	------------------------------------
	0 - #ENTNAME[2]Tim
	1 - #Cstrike_TitlesTXT_Sector_clear

	params strings de_inferno
	------------------------------------
	0 - #ENTNAME[8]Tom
	1 - Middle
	2 - #SFUI_TitlesTXT_Smoke_in_the_hole
 	3 - auto
	
	csgo/resource/csgo_...
	------------------------------------
	"[english]SFUI_TitlesTXT_Fire_in_the_hole"	"Fire in the hole!"
	"[english]SFUI_TitlesTXT_Molotov_in_the_hole"	"FireBomb on the way!"
	"[english]SFUI_TitlesTXT_Flashbang_in_the_hole"	"Flashbang Out!"
	"[english]SFUI_TitlesTXT_Smoke_in_the_hole"	"Smoke Out!"
	"[english]SFUI_TitlesTXT_Decoy_in_the_hole"	"Decoy Out!"
	*/
	
	int client = PbReadInt(msg, "client");
	char model[1024];
	GetClientModel(client, model, sizeof(model));
	int mid = FindModelIDByName(model);
	
	char buffer[1024], sample[1024];
	PbReadString(msg, "params", buffer, sizeof(buffer), 1);
	
	if(StrContains(buffer, "#Cstrike_TitlesTXT"))
	{
		ReplaceString(buffer, 1024, "#Cstrike_TitlesTXT_", "", false);
	}
	else
	{
		PbReadString(msg, "params", buffer, sizeof(buffer), 2);
		ReplaceString(buffer, 1024, "#SFUI_TitlesTXT_", "", false);
	}
	
	if(StrContains(buffer, "Fire_in_the_hole") != -1)				strcopy(sample, 1024, "grenade");
	else if(StrContains(buffer, "Molotov_in_the_hole") != -1)		strcopy(sample, 1024, "molotov");
	else if(StrContains(buffer, "Flashbang_in_the_hole") != -1)		strcopy(sample, 1024, "flashbang");
	else if(StrContains(buffer, "Smoke_in_the_hole") != -1)			strcopy(sample, 1024, "smoke");
	else if(StrContains(buffer, "Decoy_in_the_hole") != -1)			strcopy(sample, 1024, "decoy");
	else	return Plugin_Continue;
	
	int rid = FindRadioBySample(sample);
	
	//PrintToConsoleAll("mid %d, rid %d", mid, rid);
	
	if(mid > -1 && rid > -1)
	{
		DataPack pack;
		CreateDataTimer(0.0, SendAudio, pack);
		
		pack.WriteCell(mid);
		pack.WriteCell(rid);
		pack.WriteCell(playersNum);
		
		for(int i = 0; i < playersNum; i++)
		{
			pack.WriteCell(players[i]);
		}

		pack.Reset();
	}
	
	return Plugin_Continue;
}

public Action SendAudio(Handle timer, DataPack pack)
{
	int mid = pack.ReadCell();
	int rid = pack.ReadCell();
	int playersNum = pack.ReadCell();
	int[] players = new int [playersNum];
	int count, client;
	for(int i = 0; i < playersNum; i++)
	{
		client = pack.ReadCell();
		if(IsValidClient(client) && !IsFakeClient(client))
		{
			players[count] = client;
			count++;
		}
	}
	playersNum = count;
	
	char sound[1024];
	Format(sound, sizeof(sound), "*/%s", g_radioFiles[mid][rid]);
				
	EmitSound(players, playersNum, sound, SOUND_FROM_PLAYER, SNDCHAN_VOICE);
	
	delete pack;
}

public void OnMapStart() 
{
	LoadRadio();
}

public Action Event_SoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	// +playervophoenixclear02.wav
	// csgo/scripts/game_sound...
	
	// Is player voice
	// PrintToConsoleAll("%s", sample);
	if(StrContains(sample, "+playervo") && IsValidEntity(entity) && entity > 0 && entity <= MaxClients)
	{
		char model[1024];
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		
		int mid = FindModelIDByName(model);
		
		// Has this model.
		if(mid > -1)
		{
			int rid = FindRadioBySample(sample);
			// Has radio
			if(rid > -1)
			{
				int team = GetClientTeam(entity);
			
				char sound[1024];
				Format(sound, sizeof(sound), "*/%s", g_radioFiles[mid][rid]);
				for(int i = 1; i <= MaxClients; i++)
				{
					if(IsValidClient(i) && GetClientTeam(i) == team)
					{
						EmitSoundToClient(i, sound, SOUND_FROM_PLAYER, SNDCHAN_VOICE, SNDLEVEL_NONE);
					}
				}
				
				return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}

int FindRadioBySample(char [] sample)
{
	int r = -1;
	for (int i = 0; i < sizeof(g_radioSounds); i++)
	{
		if(StrContains(sample, g_radioSounds[i]) != -1) r = i;
	}
	return r;
}

int FindModelIDByName(char [] model)
{
	int r = -1;
	for (int i = 0; i < modelcount; i++)
	{
		if(StrEqual(g_model[i], model)) r = i;
	}
	return r;
}

void LoadRadio()
{
	char Configfile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, Configfile, sizeof(Configfile), "configs/kento_radio.cfg");
	
	if (!FileExists(Configfile))
	{
		SetFailState("Fatal error: Unable to open configuration file \"%s\"!", Configfile);
	}
	
	KeyValues kv = CreateKeyValues("Radio");
	kv.ImportFromFile(Configfile);
	
	if(!kv.GotoFirstSubKey())
	{
		SetFailState("Fatal error: Unable to read configuration file \"%s\"!", Configfile);
	}
	
	char model[1024], file[1024];
	modelcount = 0;
	do
	{
		kv.GetSectionName(model, sizeof(model));
		strcopy(g_model[modelcount], sizeof(g_model[]), model);
		
		for (int i = 0; i < sizeof(g_radioSounds); i++)
		{
			kv.GetString(g_radioSounds[i], file, sizeof(file), "");
			
			char filepath[1024];
			Format(filepath, sizeof(filepath), "sound/%s", file)
			AddFileToDownloadsTable(filepath);
			
			char soundpath[1024];
			Format(soundpath, sizeof(soundpath), "*/%s", file);
			FakePrecacheSound(soundpath);
			
			strcopy(g_radioFiles[modelcount][i], sizeof(g_radioFiles[][]), file);
		}
		modelcount++;
	} while (kv.GotoNextKey());
	modelcount--;
	
	kv.Rewind();
	delete kv;
}

stock bool IsValidClient(int client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	if (!IsClientConnected(client)) return false;
	return IsClientInGame(client);
}

// https://wiki.alliedmods.net/Csgo_quirks
stock void FakePrecacheSound(const char[] szPath)
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}