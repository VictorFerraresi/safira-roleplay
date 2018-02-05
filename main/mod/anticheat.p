// system_anticheat | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
Anticheat_CheckWeapons(playerid){
    new
        clientWeapon[13][2];
    for(new i = 0; i < 13; i++){
        GetPlayerWeaponData(playerid, i, clientWeapon[i][0], clientWeapon[i][1]);
    }

    for(new i = 0; i < 13; i++){
        new szDEBUG[500];
        if(clientWeapon[i][0] != gPlayerData[playerid][pWeapon][i]){
            format(szDEBUG, 500, "DIF WEAP. CLIENT: %d | SCRIPT: %d", clientWeapon[i][0], gPlayerData[playerid][pWeapon][i]);
            SendClientMessage(playerid, -1, szDEBUG);
            Player_ResetWeapons(playerid);
            return 1;
        }
        /*else if(clientWeapon[i][1] != gPlayerData[playerid][pAmmo][i]){
            format(szDEBUG, 500, "DIF AMMO. CLIENT: %d | SCRIPT: %d", clientWeapon[i][1], gPlayerData[playerid][pAmmo][i]);
            SendClientMessage(playerid, -1, szDEBUG);
        }*/
    }    
    return 1;
}

Anticheat_SetDelay(playerid, seconds){
    gPlayerData[playerid][pACDelay] = gettime() + seconds;
    return 1;
}

//------------------------------------------------------------------------------

//Hooks
hook OnPlayerUpdate(playerid){    
    if(gPlayerData[playerid][pACDelay] == 0 || gettime() - gPlayerData[playerid][pACDelay] > 0)
        Anticheat_CheckWeapons(playerid);
    return 1;
}

/*hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ){
    gPlayerData[playerid][pAmmo][GetWeaponSlot(weaponid)] --;
    SendClientMessage(playerid, -1, "1 AMMO DECREASE");
    return 1;
}*/

//------------------------------------------------------------------------------

