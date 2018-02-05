// system_faction | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
Faction_GetType(factionid){
    return gFactionData[factionid][fType];
}

Faction_Load(factionid){
    new szTemp[80];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `faction` where `id_faction` = '%d' limit 1", factionid);
    new Cache:result = mysql_query(hSQL, szTemp);

    if(!cache_get_row_count()){
        cache_delete(result);
        return 1;
    }

    gFactionData[factionid][fSQLID] = cache_get_field_content_int(0, "id_faction", hSQL);
    gFactionData[factionid][fType] = cache_get_field_content_int(0, "type", hSQL);
    gFactionData[factionid][fSpawnX] = cache_get_field_content_float(0, "spawnX", hSQL);
    gFactionData[factionid][fSpawnY] = cache_get_field_content_float(0, "spawnY", hSQL);
    gFactionData[factionid][fSpawnZ] = cache_get_field_content_float(0, "spawnZ", hSQL);
    gFactionData[factionid][fSpawnR] = cache_get_field_content_float(0, "spawnR", hSQL);
    gFactionData[factionid][fEquipX] = cache_get_field_content_float(0, "equipX", hSQL);
    gFactionData[factionid][fEquipY] = cache_get_field_content_float(0, "equipY", hSQL);
    gFactionData[factionid][fEquipZ] = cache_get_field_content_float(0, "equipZ", hSQL);

    cache_get_field_content(0, "name", gFactionData[factionid][fName], hSQL, 50);
    cache_get_field_content(0, "acro", gFactionData[factionid][fAcro], hSQL, 10);

    gFactionData[factionid][fBank] = cache_get_field_content_int(0, "bank", hSQL);

    gFactionData[factionid][fColor] = cache_get_field_content_int(0, "color", hSQL);

    gFactionData[factionid][fMaxRanks] = cache_get_field_content_int(0, "maxranks", hSQL);
    gFactionData[factionid][fStartRank] = cache_get_field_content_int(0, "startrank", hSQL);
    gFactionData[factionid][fTogChat] = cache_get_field_content_int(0, "togchat", hSQL);

    cache_delete(result);

    printf("[DEBUG] Facção %d (%s) carregada. (SQL: %d)", factionid, gFactionData[factionid][fName], gFactionData[factionid][fSQLID]);
    return 1;
}

Faction_Save(factionid){
    new szTemp[400];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "update `faction` set\
     `type` = '%d',\
     `spawnX` = '%f',\
     `spawnY` = '%f',\
     `spawnZ` = '%f',\
     `spawnR` = '%f',\
     `equipX` = '%f',\
     `equipY` = '%f',\
     `equipZ` = '%f',\
     `name` = '%s',\
     `acro` = '%s',\
     `bank` = '%d',\
     `color` = '%d',\
     `maxranks` = '%d',\
     `startrank` = '%d',\
     `togchat` = '%d'\
      where `id_faction` = '%d'",
    gFactionData[factionid][fType],
    gFactionData[factionid][fSpawnX],
    gFactionData[factionid][fSpawnY],
    gFactionData[factionid][fSpawnZ],
    gFactionData[factionid][fSpawnR],
    gFactionData[factionid][fEquipX],
    gFactionData[factionid][fEquipY],
    gFactionData[factionid][fEquipZ],
    gFactionData[factionid][fName],
    gFactionData[factionid][fAcro],
    gFactionData[factionid][fBank],
    gFactionData[factionid][fColor],
    gFactionData[factionid][fMaxRanks],
    gFactionData[factionid][fStartRank],
    gFactionData[factionid][fTogChat],
    gFactionData[factionid][fSQLID]);

    mysql_query(hSQL, szTemp);

    return 1;
}

Faction_SendMessage(factionid, color, msg[], bool:ignoreTog){
    for(new i = 0; i < GetMaxPlayers(); i++){    
        if(!gPlayerData[i][pFactionTog] || ignoreTog == true){
            if(Player_GetFactionID(i) == factionid)
                Player_SendLongMsg(i, color, msg);
        }
    }
}

Faction_ShowPlayerHelp(playerid, type){
    switch(type){
        case 1:{
            SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos de Facção]______________________________");
            SendClientMessage(playerid, C_COLOR_WHITE, "/(f)accao, /togf, /(d)epartamento, /trabalho, /(m)egafone");
        }
        case 2:{
            SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos de Líder]______________________________");
            SendClientMessage(playerid, C_COLOR_WHITE, "/convidar, /demitir, /cargo, /nomecargo");
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

//Hooks

//------------------------------------------------------------------------------

//Comandos

CMD:faccao(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    if(gPlayerData[playerid][pFactionTog])
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você está com o chat de facção silenciado (/togf).");
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /faccao [Mensagem] -{C0C0C0} Envia uma mensagem para sua facção");

    new szMessage[210];
    format(szMessage, sizeof(szMessage), "(( %s %s: %s ))", gPlayerData[playerid][pRankName], Player_GetRPName(playerid, true), szText);
    Faction_SendMessage(Player_GetFactionID(playerid), C_COLOR_FACTIONCHAT, szMessage, false);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/f] O jogador %d disse: %s.", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:f(playerid, params[]) return cmd_faccao(playerid,params);

CMD:togf(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    if(!gPlayerData[playerid][pFactionTog]){
        gPlayerData[playerid][pFactionTog] = 1;
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você silenciou o chat de sua facção (para você apenas).");
    } else {
        gPlayerData[playerid][pFactionTog] = 0;
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você habilitou o chat de sua facção (para você apenas).");
    }

    new logstr[128];
    format(logstr, sizeof(logstr), "[/togf] O jogador %d bloqueou/desbloqueou seu chat de facção (%d).", Player_DBID(playerid), gPlayerData[playerid][pFactionTog]);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:d(playerid, params[]){
    if(Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_POLICE && Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_MEDIC &&
    Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_GOV)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /departamento [Mensagem] -{C0C0C0} Envia uma mensagem para os departamentos do governo");

    new szMessage[210];
    format(szMessage, sizeof(szMessage), "**[%s] %s %s: %s**", gFactionData[Player_GetFactionID(playerid)][fAcro], gPlayerData[playerid][pRankName], Player_GetRPName(playerid, true), szText);
    for(new i = 0; i < C_MAX_FACTIONS; i++){
        if(gFactionData[i][fType] == FACTION_POLICE || gFactionData[i][fType] == FACTION_MEDIC || gFactionData[i][fType] == FACTION_GOV)
            Faction_SendMessage(i, C_COLOR_DPTCHAT, szMessage, true);
    }

    format(szMessage, sizeof (szMessage), "(Rádio) %s diz: %s", Player_GetRPName(playerid, false), szText);
    ProxDetectorNotToMe(5.0, playerid, szMessage, C_COLOR_CHATFADE1, C_COLOR_CHATFADE2, C_COLOR_CHATFADE3, C_COLOR_CHATFADE4, C_COLOR_CHATFADE5);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/d] O jogador %d disse: %s.", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:departamento(playerid, params[]) return cmd_d(playerid,params);

CMD:convidar(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0 || Player_FactionRank(playerid) < 3)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new target;

    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /convidar [playerid] -{C0C0C0} Convida um jogador para a sua facção");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(Player_GetFactionID(target) != 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador já está em uma facção.");
    if(gPlayerData[target][pFactionInvite] != 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador já tem um convite de facção ativo.");

    new szInvite[128];
    format(szInvite, sizeof(szInvite), "* O jogador %s te convidou para o(a) %s. Digite /aceitar faccao para aceitar o convite.", Player_GetRPName(playerid, true), gFactionData[Player_GetFactionID(playerid)][fName]);
    SendClientMessage(target, C_COLOR_YELLOW, szInvite);
    format(szInvite, sizeof(szInvite), "* Você convidou o jogador %s para entrar no(a) %s.", Player_GetRPName(target, true), gFactionData[Player_GetFactionID(playerid)][fName]);
    SendClientMessage(playerid, C_COLOR_YELLOW, szInvite);

    gPlayerData[target][pFactionInvite] = Player_GetFactionID(playerid);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/convidar] O jogador %d convidou o jogador %d para o(a) %s.", Player_DBID(playerid), Player_DBID(target), gFactionData[Player_GetFactionID(playerid)][fName]);
    Server_Log(playerid, target, LOG_CMD, logstr);

    return 1;
}

CMD:demitir(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0 || Player_FactionRank(playerid) < 3)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new target;

    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /demitir [playerid] -{C0C0C0} Demite um jogador de sua facção");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(Player_GetFactionID(target) != Player_GetFactionID(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não está em sua facção.");

    new szKickout[128];
    format(szKickout, sizeof(szKickout), "* O jogador %s te demitiu do(a) %s.", Player_GetRPName(playerid, true), gFactionData[Player_GetFactionID(playerid)][fName]);
    SendClientMessage(target, C_COLOR_YELLOW, szKickout);
    format(szKickout, sizeof(szKickout), "* Você demitiu o jogador %s do(a) %s.", Player_GetRPName(target, true), gFactionData[Player_GetFactionID(playerid)][fName]);
    SendClientMessage(playerid, C_COLOR_YELLOW, szKickout);

    gPlayerData[target][pFaction] = 0;
    gPlayerData[target][pFactionRank] = 0;

    if(gPlayerData[target][pSpawnLoc] == SPAWN_FACTION)
            gPlayerData[target][pSpawnLoc] = SPAWN_CIVILIAN;

    new logstr[128];
    format(logstr, sizeof(logstr), "[/demitir] O jogador %d demitiu o jogador %d do(a) %s.", Player_DBID(playerid), Player_DBID(target), gFactionData[Player_GetFactionID(playerid)][fName]);
    Server_Log(playerid, target, LOG_CMD, logstr);

    return 1;
}

CMD:cargo(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0 || Player_FactionRank(playerid) < 3)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new
        target,
        rank;

    if(sscanf(params, "ud", target, rank))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /cargo [playerid] [cargo] -{C0C0C0} Edita o cargo hierárquico do player na facção");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(Player_GetFactionID(target) != Player_GetFactionID(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não está em sua facção.");
    if(Player_FactionRank(playerid) < Player_FactionRank(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode utilizar este comando em um membro cujo cargo é maior que o seu.");
    if(rank < 1 || rank > 4)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um cargo entre 1 e 4.");

    new szNewRank[128];
    format(szNewRank, sizeof(szNewRank), "* O jogador %s setou o seu cargo na facção para %d.", Player_GetRPName(playerid, true), rank);
    SendClientMessage(target, C_COLOR_YELLOW, szNewRank);
    format(szNewRank, sizeof(szNewRank), "* Você setou o cargo do jogador %s na facção para %d.", Player_GetRPName(target, true), rank);
    SendClientMessage(playerid, C_COLOR_YELLOW, szNewRank);

    gPlayerData[target][pFactionRank] = rank;

    new logstr[128];
    format(logstr, sizeof(logstr), "[/cargo] O jogador %d setou o cargo do jogador %d para %d.", Player_DBID(playerid), Player_DBID(target), rank);
    Server_Log(playerid, target, LOG_CMD, logstr);

    return 1;
}

CMD:nomecargo(playerid, params[]){
    if(Player_GetFactionID(playerid) == 0 || Player_FactionRank(playerid) < 3)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new
        target,
        rank[40];

    if(sscanf(params, "us[40]", target, rank))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /nomecargo [playerid] [nome do cargo] -{C0C0C0} Edita a nomenclatura do cargo do jogador");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(Player_GetFactionID(target) != Player_GetFactionID(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não está em sua facção.");
    if(Player_FactionRank(playerid) < Player_FactionRank(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode utilizar este comando em um membro cujo cargo é maior que o seu.");

    new szNewRank[128];
    format(szNewRank, sizeof(szNewRank), "* O jogador %s setou o seu cargo nominal na facção para %s.", Player_GetRPName(playerid, true), rank);
    SendClientMessage(target, C_COLOR_YELLOW, szNewRank);
    format(szNewRank, sizeof(szNewRank), "* Você setou o cargo nominal do jogador %s na facção para %s.", Player_GetRPName(target, true), rank);
    SendClientMessage(playerid, C_COLOR_YELLOW, szNewRank);

    gPlayerData[target][pRankName] = rank;

    new logstr[128];
    format(logstr, sizeof(logstr), "[/nomecargo] O jogador %d setou o cargo nominal do jogador %d para %s.", Player_DBID(playerid), Player_DBID(target), rank);
    Server_Log(playerid, target, LOG_CMD, logstr);

    return 1;
}

CMD:membros(playerid, params[]){
    #pragma unused params

    if(Player_GetFactionID(playerid) == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "_____________[Membros Online]_____________");
    for(new i = 0; i <= GetPlayerPoolSize(); i++){
        if(Player_GetFactionID(playerid) == Player_GetFactionID(i)){
            new szMember[64];
            format(szMember, sizeof(szMember), "{1BBAD6}%s {FFFFFF}%s [ID: %d]", gPlayerData[i][pRankName], Player_GetRPName(i, true), i);
            SendClientMessage(playerid, C_COLOR_WHITE, szMember);
        }
    }

    return 1; 
}

CMD:trabalho(playerid, params[]){
    #pragma unused params

    if(Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_POLICE && Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_MEDIC &&
    Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_GOV)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new szDuty[210];

    if(!gPlayerData[playerid][pFacDuty]){
        format(szDuty, sizeof (szDuty), "[INFO] %s %s entrou em trabalho.", gPlayerData[playerid][pRankName], Player_GetRPName(playerid, false));
        gPlayerData[playerid][pFacDuty] = 1;
        SetPlayerColor(playerid, RemoverAlpha(gFactionData[Player_GetFactionID(playerid)][fColor]));
    } else {
        format(szDuty, sizeof (szDuty), "[INFO] %s %s saiu de trabalho.", gPlayerData[playerid][pRankName], Player_GetRPName(playerid, false));
        gPlayerData[playerid][pFacDuty] = 0;
        SetPlayerColor(playerid, C_COLOR_PLAYER);
    }

    Faction_SendMessage(Player_GetFactionID(playerid), C_COLOR_FACTIONWARN, szDuty, false);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/trabalho] O jogador %d entrou/saiu de trabalho na facção. (%d)", Player_DBID(playerid), gPlayerData[playerid][pFacDuty]);
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:megafone(playerid, params[]){
    if(Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_POLICE && Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_MEDIC &&
    Faction_GetType(gPlayerData[playerid][pFaction]) != FACTION_GOV)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /megafone [Mensagem] -{C0C0C0} Envia uma mensagem pelo megafone em área");

    new szMessage[210];
    format(szMessage, sizeof(szMessage), "**[%s %s:o< %s ]**", gPlayerData[playerid][pRankName], Player_GetRPName(playerid, true), szText);
    ProxDetector(15.0, playerid, szMessage, C_COLOR_MEGAPHONE, C_COLOR_MEGAPHONE, C_COLOR_MEGAPHONE, C_COLOR_MEGAPHONE, C_COLOR_MEGAPHONE);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/megafone] O jogador %d disse: %s.", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:m(playerid, params[]) return cmd_megafone(playerid,params);
