// system_server | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
function Server_Kick(playerid){
    Kick(playerid);
    return 1;
}

function Server_Ban(playerid){
    Ban(playerid);
    return 1;
}

function Server_Log(playerid, targetid, type, action[]){
    new temp[300], uip[16], tip[16];

    GetPlayerIp(playerid, uip, sizeof(uip));
    if(targetid != -1){
        GetPlayerIp(targetid, tip, sizeof(tip));
        mysql_format(hSQL, temp, sizeof(temp), "insert into `logs` (`user`, `target`, `type`, `action`, `userip`, `targetip`) VALUES ('%d', '%d', '%d', '%e', '%s', '%s')",
        Player_DBID(playerid),
        Player_DBID(targetid),
        type,
        action,
        uip,
        tip);
    } else {
        mysql_format(hSQL, temp, sizeof(temp), "insert into `logs` (`user`, `target`, `type`, `action`, `userip`, `targetip`) VALUES ('%d', '0', '%d', '%e', '%s', 'N/A')",
        Player_DBID(playerid),
        type,
        action,
        uip);
    }

    mysql_query(hSQL, temp);

    return 1;
}

function Server_Restart(){
    SendRconCommand("gmx");
    return 1;
}
//------------------------------------------------------------------------------

//Hooks

//------------------------------------------------------------------------------

//Timers

function TenSecondsTimer(){
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(gPlayerData[i][pScene] != Text3D:INVALID_3DTEXT_ID){
            if((gettime() - gPlayerData[i][pSceneCreated]) > 600){
                Delete3DTextLabel(gPlayerData[i][pScene]);
                gPlayerData[i][pScene] =  Text3D:INVALID_3DTEXT_ID;
                gPlayerData[i][pSceneCreated] = 0;
                SendClientMessage(i, C_COLOR_WARNING, "[AVISO] Sua cena foi deletada pois se passaram 10 minutos de sua criação.");
            }
        }
    }
}

//------------------------------------------------------------------------------

//Comandos
