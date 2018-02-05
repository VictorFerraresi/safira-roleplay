#include "lib\a_samp"
#include "main.h"

//Libs de Plugins
#include "lib\plugins\sscanf"
#include "lib\plugins\a_mysql"
#include "lib\plugins\crashdetect"
#include "lib\plugins\streamer"
#include "lib\plugins\gvar"

//Libs de Funções
#include "lib\YSI\y_hooks"
#include "lib\zcmd"
#include "lib\proxdetector"
#include "lib\MD5"
#include "lib\mSelection"
#include "lib\zones"

//Módulos Externos
#include "mod\colors.p"
#include "mod\player.p"
#include "mod\admin.p"
#include "mod\server.p"
#include "mod\faction.p"
#include "mod\property.p"
#include "mod\vehicle.p"
#include "mod\cellphone.p"
#include "mod\textdraws.p"
#include "mod\anticheat.p"
#include "mod\development.p"

//Mapas
#include "mod\maps\OficinaVinewood.p"
#include "mod\maps\BombasGasolina.p"
#include "mod\maps\ParadaOnibusGanton.p"


main(){
    printf("Main has been called.");
}

public OnGameModeInit(){
    Streamer_SetVisibleItems(STREAMER_TYPE_OBJECT, 700);
    DisableInteriorEnterExits();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(0);
    ManualVehicleEngineAndLights();

    hSQL = mysql_connect(SQL_HOST, SQL_USER, SQL_DB, SQL_PASS);    

    if(mysql_errno() != 0)
	   printf("[SQL] Não foi possivel realizar a conexão com %s! (%d)", SQL_HOST, mysql_errno());

    fSQL = mysql_connect(FSQL_HOST, FSQL_USER, FSQL_DB, FSQL_PASS);

    for(new i = 1; i < C_MAX_FACTIONS; i++){
        Faction_Load(i);
    }

    for(new i = 1; i < C_MAX_HOUSES; i++){
        House_Load(i);
    }

    for(new i = 1; i < C_MAX_BUSINESSES; i++){
        Business_Load(i);
    }

    Vehicle_LoadAllStatic();

    SetTimer("TenSecondsTimer", 10000, true);

    boat_dealer_list = LoadModelSelectionMenu("boat_dealerlist.txt");
    plane_dealer_list = LoadModelSelectionMenu("plane_dealerlist.txt");
    motorcycle_dealer_list = LoadModelSelectionMenu("motorcycle_dealerlist.txt");
    industry_dealer_list = LoadModelSelectionMenu("industry_dealerlist.txt");
    low_dealer_list = LoadModelSelectionMenu("low_dealerlist.txt");
    medium_dealer_list = LoadModelSelectionMenu("medium_dealerlist.txt");
    high_dealer_list =  LoadModelSelectionMenu("high_dealerlist.txt");  

    return 1;
}

public OnGameModeExit(){
    for(new i = 0; i < C_MAX_FACTIONS; i++){
        if(gFactionData[i][fSQLID] != 0)
            Faction_Save(i);
    }
    for(new i = 0; i < C_MAX_HOUSES; i++){
        if(gHouseData[i][hSQLID] != 0)
            House_Save(i);
    }
    for(new i = 0; i < C_MAX_BUSINESSES; i++){
        if(gBusinessData[i][bSQLID] != 0)
        Business_Save(i);
    }
    for(new i = 0; i < MAX_PLAYERS; i++){
        if(Player_Logged(i)){
            SetPlayerName(i, gAccountData[i][aName]);
        }
    }
    mysql_close(hSQL);
    mysql_close(fSQL);
    return 1;
}

public OnPlayerConnect(playerid){
    Player_ResetCharacterVariables(playerid);
    Player_ResetAccountVariables(playerid);
    SetPlayerColor(playerid, C_COLOR_PLAYER);
    Player_CheckAccount(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    return 1;
}

public OnPlayerSpawn(playerid){
    PreloadAnimLib(playerid,"AIRPORT");             
    PreloadAnimLib(playerid,"Attractors");          
    PreloadAnimLib(playerid,"BAR");         
    PreloadAnimLib(playerid,"BASEBALL");            
    PreloadAnimLib(playerid,"BD_FIRE");         
    PreloadAnimLib(playerid,"BEACH");           
    PreloadAnimLib(playerid,"benchpress");      
    PreloadAnimLib(playerid,"BF_injection");        
    PreloadAnimLib(playerid,"BIKED");           
    PreloadAnimLib(playerid,"BIKEH");         
    PreloadAnimLib(playerid,"BIKELEAP");          
    PreloadAnimLib(playerid,"BIKES");         
    PreloadAnimLib(playerid,"BIKEV");         
    PreloadAnimLib(playerid,"BIKE_DBZ");          
    PreloadAnimLib(playerid,"BLOWJOBZ");          
    PreloadAnimLib(playerid,"BMX");       
    PreloadAnimLib(playerid,"BOMBER");        
    PreloadAnimLib(playerid,"BOX");       
    PreloadAnimLib(playerid,"BSKTBALL");          
    PreloadAnimLib(playerid,"BUDDY");         
    PreloadAnimLib(playerid,"BUS");       
    PreloadAnimLib(playerid,"CAMERA");        
    PreloadAnimLib(playerid,"CAR");       
    PreloadAnimLib(playerid,"CARRY");         
    PreloadAnimLib(playerid,"CAR_CHAT");          
    PreloadAnimLib(playerid,"CASINO");        
    PreloadAnimLib(playerid,"CHAINSAW");          
    PreloadAnimLib(playerid,"CHOPPA");        
    PreloadAnimLib(playerid,"CLOTHES");           
    PreloadAnimLib(playerid,"COACH");         
    PreloadAnimLib(playerid,"COLT45");        
    PreloadAnimLib(playerid,"COP_AMBIENT");       
    PreloadAnimLib(playerid,"COP_DVBYZ");         
    PreloadAnimLib(playerid,"CRACK");         
    PreloadAnimLib(playerid,"CRIB");          
    PreloadAnimLib(playerid,"DAM_JUMP");          
    PreloadAnimLib(playerid,"DANCING");           
    PreloadAnimLib(playerid,"DEALER");        
    PreloadAnimLib(playerid,"DILDO");         
    PreloadAnimLib(playerid,"DODGE");         
    PreloadAnimLib(playerid,"DOZER");         
    PreloadAnimLib(playerid,"DRIVEBYS");          
    PreloadAnimLib(playerid,"FAT");       
    PreloadAnimLib(playerid,"FIGHT_B");           
    PreloadAnimLib(playerid,"FIGHT_C");           
    PreloadAnimLib(playerid,"FIGHT_D");           
    PreloadAnimLib(playerid,"FIGHT_E");           
    PreloadAnimLib(playerid,"FINALE");        
    PreloadAnimLib(playerid,"FINALE2");           
    PreloadAnimLib(playerid,"FLAME");         
    PreloadAnimLib(playerid,"Flowers");           
    PreloadAnimLib(playerid,"FOOD");          
    PreloadAnimLib(playerid,"Freeweights");       
    PreloadAnimLib(playerid,"GANGS");         
    PreloadAnimLib(playerid,"GHANDS");        
    PreloadAnimLib(playerid,"GHETTO_DB");         
    PreloadAnimLib(playerid,"goggles");           
    PreloadAnimLib(playerid,"GRAFFITI");          
    PreloadAnimLib(playerid,"GRAVEYARD");         
    PreloadAnimLib(playerid,"GRENADE");           
    PreloadAnimLib(playerid,"GYMNASIUM");         
    PreloadAnimLib(playerid,"HAIRCUTS");          
    PreloadAnimLib(playerid,"HEIST9");        
    PreloadAnimLib(playerid,"INT_HOUSE");         
    PreloadAnimLib(playerid,"INT_OFFICE");        
    PreloadAnimLib(playerid,"INT_SHOP");          
    PreloadAnimLib(playerid,"JST_BUISNESS");          
    PreloadAnimLib(playerid,"KART");          
    PreloadAnimLib(playerid,"KISSING");           
    PreloadAnimLib(playerid,"KNIFE");         
    PreloadAnimLib(playerid,"LAPDAN1");           
    PreloadAnimLib(playerid,"LAPDAN2");           
    PreloadAnimLib(playerid,"LAPDAN3");           
    PreloadAnimLib(playerid,"LOWRIDER");          
    PreloadAnimLib(playerid,"MD_CHASE");          
    PreloadAnimLib(playerid,"MD_END");        
    PreloadAnimLib(playerid,"MEDIC");         
    PreloadAnimLib(playerid,"MISC");          
    PreloadAnimLib(playerid,"MTB");       
    PreloadAnimLib(playerid,"MUSCULAR");          
    PreloadAnimLib(playerid,"NEVADA");        
    PreloadAnimLib(playerid,"ON_LOOKERS");        
    PreloadAnimLib(playerid,"OTB");       
    PreloadAnimLib(playerid,"PARACHUTE");         
    PreloadAnimLib(playerid,"PARK");          
    PreloadAnimLib(playerid,"PAULNMAC");          
    PreloadAnimLib(playerid,"ped");       
    PreloadAnimLib(playerid,"PLAYER_DVBYS");          
    PreloadAnimLib(playerid,"PLAYIDLES");         
    PreloadAnimLib(playerid,"POLICE");        
    PreloadAnimLib(playerid,"POOL");          
    PreloadAnimLib(playerid,"POOR");          
    PreloadAnimLib(playerid,"PYTHON");        
    PreloadAnimLib(playerid,"QUAD");          
    PreloadAnimLib(playerid,"QUAD_DBZ");          
    PreloadAnimLib(playerid,"RAPPING");           
    PreloadAnimLib(playerid,"RIFLE");         
    PreloadAnimLib(playerid,"RIOT");          
    PreloadAnimLib(playerid,"ROB_BANK");          
    PreloadAnimLib(playerid,"ROCKET");        
    PreloadAnimLib(playerid,"RUSTLER");           
    PreloadAnimLib(playerid,"RYDER");         
    PreloadAnimLib(playerid,"SCRATCHING");        
    PreloadAnimLib(playerid,"SHAMAL");        
    PreloadAnimLib(playerid,"SHOP");          
    PreloadAnimLib(playerid,"SHOTGUN");           
    PreloadAnimLib(playerid,"SILENCED");          
    PreloadAnimLib(playerid,"SKATE");         
    PreloadAnimLib(playerid,"SMOKING");           
    PreloadAnimLib(playerid,"SNIPER");        
    PreloadAnimLib(playerid,"SPRAYCAN");          
    PreloadAnimLib(playerid,"STRIP");         
    PreloadAnimLib(playerid,"SUNBATHE");          
    PreloadAnimLib(playerid,"SWAT");          
    PreloadAnimLib(playerid,"SWEET");         
    PreloadAnimLib(playerid,"SWIM");          
    PreloadAnimLib(playerid,"SWORD");         
    PreloadAnimLib(playerid,"TANK");          
    PreloadAnimLib(playerid,"TATTOOS");           
    PreloadAnimLib(playerid,"TEC");       
    PreloadAnimLib(playerid,"TRAIN");         
    PreloadAnimLib(playerid,"TRUCK");         
    PreloadAnimLib(playerid,"UZI");       
    PreloadAnimLib(playerid,"VAN");       
    PreloadAnimLib(playerid,"VENDING");           
    PreloadAnimLib(playerid,"VORTEX");        
    PreloadAnimLib(playerid,"WAYFARER");
    PreloadAnimLib(playerid,"WEAPONS");
    PreloadAnimLib(playerid,"WUZI"); 
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason){
}

public OnPlayerText(playerid, text[]){
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    return 1;
}

public OnPlayerRequestClass(playerid, classid){
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[]){
    if(!Player_Logged(playerid)){
        SendClientMessage(playerid, C_COLOR_ERROR, NOT_LOGGED);
        return 0;
    }
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success){
    if(!success){
        new szError[256];
        format(szError, sizeof(szError), "[ERRO] O comando que você digitou (%s) não existe. Utilize /ajuda para mais informações.", cmdtext);
        Player_SendLongMsg(playerid, C_COLOR_ERROR, szError);
        return 1;
    }
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
    return 1;
}

public OnPlayerModelSelection(playerid, response, listid, modelid){
    Player_OnPlayerModelSelection(playerid, response, listid, modelid);
    return 1;
}

public OnVehicleDeath(vehicleid, killerid){
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart){
    return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle){
	switch(errorid){
		case ER_SYNTAX_ERROR:{
			printf("Something is wrong in your syntax, query: %s",query);
		}
	}
	return 1;
}
