#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <kento_csgocolors>
#include <cstrike>

#pragma newdecls required

bool DEBUGGING = true;

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
	"gameafkbombdrop",
	"needdrop",
	"goa",
	"gob",
	"sorry"
}

#define MAXMODEL 200
char g_radioFiles[MAXMODEL][81][512];
char g_model[MAXMODEL][512];
int modelcount;

public Plugin myinfo =
{
	name = "[CS:GO] Custom Radio Sound",
	author = "Kento",
	version = "1.2",
	description = "Custom Radio Sound.",
	url = "http://steamcommunity.com/id/kentomatoryoshika/"
};

public void OnPluginStart() 
{
	// For disable default radio sound.
	AddNormalSoundHook(Event_SoundPlayed);
	
	// Grenades
	HookUserMessage(GetUserMessageId("RadioText"), RadioText, true);

	if(DEBUGGING)	RegAdminCmd("sm_radiomodels", Command_Model, ADMFLAG_ROOT);
}

void FindSampleByCmd(const char[] command, char[] sample, int maxlen)
{
	if(StrContains(command, "requestmove") != -1)						strcopy(sample, maxlen, "letsgo");
	else if(StrContains(command, "roundstart") != -1)						strcopy(sample, maxlen, "locknload");
	else if(StrContains(command, "sticktog") != -1)					strcopy(sample, maxlen, "regroup");	
	else if(StrContains(command, "sticktogetherteam") != -1)			strcopy(sample, maxlen, "regroup");	
	else if(StrContains(command, "sticktogether") != -1)				strcopy(sample, maxlen, "regroup");	
	else if(StrContains(command, "holdpos") != -1)					strcopy(sample, maxlen, "hold");	
	else if(StrContains(command, "affirmation") != -1)					strcopy(sample, maxlen, "affirmative");	
	else if(StrContains(command, "roger") != -1)						strcopy(sample, maxlen, "affirmative");	
	else if(StrContains(command, "cheer") != -1)						strcopy(sample, maxlen, "onarollbrag");	
	else if(StrContains(command, "compliment") != -1)				strcopy(sample, maxlen, "onarollbrag");	
	else if(StrContains(command, "enemyspot") != -1)					strcopy(sample, maxlen, "enemyspotted");	
	else if(StrContains(command, "seesenemy") != -1)					strcopy(sample, maxlen, "enemyspotted");	
	else if(StrContains(command, "takepoint") != -1)					strcopy(sample, maxlen, "followingfriend");
	else if(StrContains(command, "sectorclear") != -1)				strcopy(sample, maxlen, "clear");
	else if(StrContains(command, "getout") != -1)					strcopy(sample, maxlen, "bombtickingdown");
	else if(StrContains(command, "getoutofthere") != -1)				strcopy(sample, maxlen, "bombtickingdown");
	else if(StrContains(command, "fireinthehole") != -1)				strcopy(sample, maxlen, "grenade");
	else if(StrContains(command, "molotovinthehole") != -1)			strcopy(sample, maxlen, "molotov");
	else if(StrContains(command, "flashbanginthehole") != -1)		strcopy(sample, maxlen, "flashbang");
	else if(StrContains(command, "smokeinthehole") != -1)			strcopy(sample, maxlen, "smoke");
	else if(StrContains(command, "decoyinthehole") != -1)			strcopy(sample, maxlen, "decoy");
	else if(StrContains(command, "negativeno") != -1)				strcopy(sample, maxlen, "negative");
	else if(StrContains(command, "requestweapon") != -1)				strcopy(sample, maxlen, "needdrop");
	else if(StrContains(command, "gotoa") != -1)							strcopy(sample, maxlen, "goa");
	else if(StrContains(command, "gotob") != -1)							strcopy(sample, maxlen, "gob");
	else if(StrContains(command, "goa") != -1)							strcopy(sample, maxlen, "goa");
	else if(StrContains(command, "gob") != -1)							strcopy(sample, maxlen, "gob");
	else if(StrContains(command, "go") != -1)							strcopy(sample, maxlen, "letsgo");
	else strcopy(sample, maxlen, command);
}

// grenades, planting, defusing and bot chats are radio text
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
	
	if(DEBUGGING)	PrintToServer("RadioText");
	int client = PbReadInt(msg, "client");
	char model[512];
	GetClientModel(client, model, sizeof(model));
	int mid = FindModelIDByName(model);
	
	char buffer[64], sample[64];
	// for maps have zones
	PbReadString(msg, "params", buffer, sizeof(buffer), 1);
	// for maps doesn't have zones
	if( StrContains(buffer,"#Cstrike_TitlesTXT_") == -1 && StrContains(buffer,"#SFUI_TitlesTXT_") == -1)
		PbReadString(msg, "params", buffer, sizeof(buffer), 2);

	if(DEBUGGING)	PrintToServer("params %s", buffer);
	ReplaceString(buffer, sizeof(buffer), "#Cstrike_TitlesTXT_", "", false);
	ReplaceString(buffer, sizeof(buffer), "#SFUI_TitlesTXT_", "", false);
	ReplaceString(buffer, sizeof(buffer), "_", "", false);

	for(int i = 0; i <= strlen(buffer); ++i) 
	{ 
		buffer[i] = CharToLower(buffer[i]); 
	} 

	FindSampleByCmd(buffer, sample, sizeof(sample));
	int rid = FindRadioBySample(sample);

	if(DEBUGGING)	PrintToServer("buf: %s, sample: %s, mid %d, rid %d, playersNum: %d, model - %s", buffer, sample, mid, rid, playersNum, model);
	
	if(mid > -1 && rid > -1)
	{
		DataPack pack;
		CreateDataTimer(0.0, SendAudio, pack, TIMER_FLAG_NO_MAPCHANGE);
		
		pack.WriteCell(mid);
		pack.WriteCell(rid);
		pack.WriteCell(playersNum);
		
		for(int i = 0; i < playersNum; i++)
		{
			pack.WriteCell(players[i]);
			if(DEBUGGING)	PrintToServer("players %d, %N", i, players[i]);
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
	
	char sound[512];
	Format(sound, sizeof(sound), "*/%s", g_radioFiles[mid][rid]);
	EmitSound(players, playersNum, sound, SOUND_FROM_PLAYER, SNDCHAN_VOICE);
	
	// we don't need this
	// https://forums.alliedmods.net/showthread.php?p=2523676
	// delete pack;
}

public void OnMapStart() 
{
	LoadRadio();
}

// For disable default radio sound.
public Action Event_SoundPlayed(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags)
{
	// +playervophoenixclear02.wav
	// csgo/scripts/game_sound...
	
	// Is player voice
	// PrintToChatAll("%s", sample);
	// +player\vo\leet\threeenemiesleft03.wav
	if(DEBUGGING)	PrintToServer("Event_SoundPlayed: %s ", sample);
	if(StrContains(sample, "player") != -1 && IsValidEntity(entity) && entity > 0 && entity <= MaxClients)
	{
		ReplaceString(sample, sizeof(sample), ".wav", "", false);
		ReplaceString(sample, sizeof(sample), "_", "", false);

		char model[512];
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		int mid = FindModelIDByName(model);

		int rid = -1;
		
		// player/death1.wav
		if(StrContains(sample, "death") != -1){
			rid = FindRadioBySample("death");
			if(DEBUGGING)	PrintToServer("hook sample: death, mid %d, rid %d, model - %s", mid, rid, model);
		}
		else{
			char radio[4][64];
			ExplodeString(sample, "\\", radio, sizeof(radio), sizeof(radio[]));	
			FindSampleByCmd(radio[3], radio[3], sizeof(radio[]));
			rid = FindRadioBySample(radio[3]);
			if(DEBUGGING)	PrintToServer("hook sample: %s, mid %d, rid %d, model - %s", radio[3], mid, rid, model);
		}

		// Has this model and radio.
		if(mid > -1 && rid > -1)
		{
			int team = GetClientTeam(entity);
			char sound[512];
			Format(sound, sizeof(sound), "*/%s", g_radioFiles[mid][rid]);
			for(int i = 1; i <= sizeof(clients); i++)
			{
				if(IsValidClient(i) && GetClientTeam(i) == team)
				{
					EmitSoundToClient(i, sound, SOUND_FROM_PLAYER, SNDCHAN_VOICE, SNDLEVEL_NONE);
				}
			}
			
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

int FindRadioBySample(char [] sample)
{
	int r = -1;
	for (int i = 0; i < sizeof(g_radioSounds); i++)
	{
		if(StrContains(sample, g_radioSounds[i]) != -1){
			r = i;
			break;
		}
	}
	return r;
}

int FindModelIDByName(char [] model)
{
	int r = -1;
	for (int i = 0; i < modelcount; i++)
	{
		if(StrContains(model, g_model[i]) != -1) 
		{
			r = i;
			break;
		}
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
	
	char model[512], file[512];
	modelcount = 0;
	do
	{
		kv.GetSectionName(model, sizeof(model));
		strcopy(g_model[modelcount], sizeof(g_model[]), model);
		
		for (int i = 0; i < sizeof(g_radioSounds); i++)
		{
			kv.GetString(g_radioSounds[i], file, sizeof(file), "");
			
			char filepath[512];
			Format(filepath, sizeof(filepath), "sound/%s", file)
			AddFileToDownloadsTable(filepath);
			
			char soundpath[512];
			Format(soundpath, sizeof(soundpath), "*/%s", file);
			FakePrecacheSound(soundpath);
			
			strcopy(g_radioFiles[modelcount][i], sizeof(g_radioFiles[][]), file);
		}
		modelcount++;
	} while (kv.GotoNextKey());
	
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

public Action Command_Model(int client, int args){
	PrintToConsole(client, "Models: %d", modelcount);
	for (int i = 0; i < modelcount; i++)
	{
		PrintToConsole(client, "%d - %s", i, g_model[i]);
	}
	return Plugin_Handled;
}