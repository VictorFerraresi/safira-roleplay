// system_admin | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
Admin_GetLevel(playerid){
    return gPlayerData[playerid][pAdmin];
}

Admin_GetRankName(playerid){
    new szAdmRank[30];
    switch(gPlayerData[playerid][pAdmin]){
        case 1: szAdmRank = "Administrador 1";
        case 2: szAdmRank = "Administrador 2";
        case 3: szAdmRank = "Administrador 3";
        case 4: szAdmRank = "Administrador 4";
        case 5: szAdmRank = "Administrador 5";
        case 6: szAdmRank = "Administrador Líder";
        case 7: szAdmRank = "Administrador Chefe";
        case 8: szAdmRank = "Desenvolvedor";
        default: szAdmRank = "Administrador";
    }
    return szAdmRank;
}

Admin_SendMessage(color, text[]){
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(Admin_GetLevel(i) > 0)
            Player_SendLongMsg(i, color, text);
    }
    return 1;
}

Admin_ShowPlayerHelp(playerid){
    SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos de Administrador]______________________________");
    SendClientMessage(playerid, C_COLOR_WHITE, "/ir, /trazer, /kick, /ban, /atrabalho, /skin, /admfac, /a, /darlider, /o, /x, /y, /z");
    SendClientMessage(playerid, C_COLOR_WHITE, "/tapa, /ircoord, /criarcasa, /destruircasa, /criarempresa, /destruirempresa, /trazerveiculo");
    SendClientMessage(playerid, C_COLOR_WHITE, "/irveiculo, /gmx, /setarvida, /ircasa, /irempresa, /dararma");
    return 1;
}

//------------------------------------------------------------------------------

//Hooks
hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    switch(dialogid){
        case DIALOG_ADMFAC:{
            if(!response)
                return 1;

            SetPVarInt(playerid, "facEdit", listitem+1);
            ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[listitem+1][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar Spawn\nAlterar Local de Equipamentos",
             "Selecionar", "Cancelar");
        }
        case DIALOG_ADMFAC2:{
            if(!response){
                DeletePVar(playerid, "facEdit");
                return 1;
            }
            new facname[40];
            format(facname, sizeof(facname), "%s", gFactionData[GetPVarInt(playerid, "facEdit")][fName]);
            switch(listitem){
                case 0: ShowPlayerDialog(playerid, DIALOG_NOMEFAC, DIALOG_STYLE_INPUT, facname, "Digite o novo nome abaixo", "Confirmar", "Voltar");
                case 1: ShowPlayerDialog(playerid, DIALOG_ACROFAC, DIALOG_STYLE_INPUT, facname, "Digite o novo acrônimo abaixo", "Confirmar", "Voltar");
                case 2: ShowPlayerDialog(playerid, DIALOG_TIPOFAC, DIALOG_STYLE_LIST, facname, "Civil (0)\nPolicial (1)\nMedico(2)\nGoverno(3)\nGang(4)\nMafia(5)", "Confirmar", "Voltar");
                case 3: ShowPlayerDialog(playerid, DIALOG_CORFAC, DIALOG_STYLE_INPUT, facname, "Digite a nova cor (em Hexadecimal)", "Confirmar", "Voltar");
                case 4: ShowPlayerDialog(playerid, DIALOG_COFREFAC, DIALOG_STYLE_INPUT, facname, "Digite o valor que deseja setar no cofre", "Confirmar", "Voltar");
                case 5: ShowPlayerDialog(playerid, DIALOG_SPAWNFAC, DIALOG_STYLE_MSGBOX, facname, "O spawn da facção será alterado para sua posição atual. Deseja continuar?", "Sim", "Não");
                case 6: ShowPlayerDialog(playerid, DIALOG_EQUIPFAC, DIALOG_STYLE_MSGBOX, facname, "O local de equipamentos da facção será alterado para sua posição atual. Deseja continuar?", "Sim", "Não");
            }
        }
        case DIALOG_NOMEFAC:{
            if(!response){
                ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar \
                Spawn\nAlterar Local de Equipamentos", "Selecionar", "Cancelar");
                return 1;
            }
            if(strlen(inputtext) == 0){
                ShowPlayerDialog(playerid, DIALOG_NOMEFAC, DIALOG_STYLE_INPUT, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "O nome é muito curto! Digite outro nome", "Confirmar", "Voltar");
                return 1;
            }

            new fid = GetPVarInt(playerid, "facEdit");
            format(gFactionData[fid][fName], 40, "%s", inputtext);
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o nome da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_ACROFAC:{
            if(!response){
                ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar \
                Spawn\nAlterar Local de Equipamentos", "Selecionar", "Cancelar");
                return 1;
            }

            if(strlen(inputtext) == 0){
                ShowPlayerDialog(playerid, DIALOG_NOMEFAC, DIALOG_STYLE_INPUT, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "O acrônimo é muito curto! Digite outro acrônimo", "Confirmar", "Voltar");
                return 1;
            }

            if(strlen(inputtext) > 10){
                ShowPlayerDialog(playerid, DIALOG_NOMEFAC, DIALOG_STYLE_INPUT, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "O acrônimo é muito longo! Digite outro acrônimo", "Confirmar", "Voltar");
                return 1;
            }

            new fid = GetPVarInt(playerid, "facEdit");
            format(gFactionData[fid][fAcro], 10, "%s", inputtext);
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o acrônimo da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_TIPOFAC:{
            if(!response){
                ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar \
                Spawn\nAlterar Local de Equipamentos", "Selecionar", "Cancelar");
                return 1;
            }
            gFactionData[GetPVarInt(playerid, "facEdit")][fType] = listitem;
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o tipo da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_CORFAC:{
            if(!response){
                ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar \
                Spawn\nAlterar Local de Equipamentos", "Selecionar", "Cancelar");
                return 1;
            }
            if(strlen(inputtext) == 0){
                ShowPlayerDialog(playerid, DIALOG_CORFAC, DIALOG_STYLE_INPUT, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "A cor digitada é muito curta. Digite novamente", "Confirmar", "Voltar");
                return 1;
            }

            new fid = GetPVarInt(playerid, "facEdit");
            new color;
            if(!sscanf(inputtext, "h", color)){
                gFactionData[fid][fColor] = color;
                SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o a cor da facção com sucesso.");
            }
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_COFREFAC:{
            if(!response){
                ShowPlayerDialog(playerid, DIALOG_ADMFAC2, DIALOG_STYLE_LIST, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Alterar Nome\nAlterar Acrônimo\nAlterar Tipo\nAlterar Cor\nAlterar Cofre\nAlterar \
                Spawn\nAlterar Local de Equipamentos", "Selecionar", "Cancelar");
                return 1;
            }
            if(!IsNumeric(inputtext) || strval(inputtext) < 0){
                ShowPlayerDialog(playerid, DIALOG_CORFAC, DIALOG_STYLE_INPUT, gFactionData[GetPVarInt(playerid, "facEdit")][fName], "Digite somente números acima de 0", "Confirmar", "Voltar");
                return 1;
            }
            gFactionData[GetPVarInt(playerid, "facEdit")][fBank] = strval(inputtext);
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o valor do cofre da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_SPAWNFAC:{
            if(!response){
                SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você cancelou a troca de spawn da facção.");
                DeletePVar(playerid, "facEdit");
                return 1;
            }
            GetPlayerPos(playerid, gFactionData[GetPVarInt(playerid, "facEdit")][fSpawnX], gFactionData[GetPVarInt(playerid, "facEdit")][fSpawnY], gFactionData[GetPVarInt(playerid, "facEdit")][fSpawnZ]);
            GetPlayerFacingAngle(playerid, gFactionData[GetPVarInt(playerid, "facEdit")][fSpawnR]);
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o spawn da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
        case DIALOG_EQUIPFAC:{
            if(!response){
                SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você cancelou a troca do local de equipamentos da facção.");
                DeletePVar(playerid, "facEdit");
                return 1;
            }
            GetPlayerPos(playerid, gFactionData[GetPVarInt(playerid, "facEdit")][fEquipX], gFactionData[GetPVarInt(playerid, "facEdit")][fEquipY], gFactionData[GetPVarInt(playerid, "facEdit")][fEquipZ]);
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trocou o local de equipamentos da facção com sucesso.");
            DeletePVar(playerid, "facEdit");
        }
    }
    return 1;  
}

//------------------------------------------------------------------------------

//Comandos

CMD:ir(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new target;
    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ir [playerid] -{C0C0C0} Te leva à um jogador");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(target == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);

    new
        Float: x,
        Float: y,
        Float: z;

    GetPlayerPos(target, x, y, z);
    Player_SetPositionWithVehicle(playerid, x+1, y, z, 0.0, GetPlayerInterior(target), GetPlayerVirtualWorld(target));
    gPlayerData[playerid][pInsideHouse] = gPlayerData[target][pInsideHouse];
    gPlayerData[playerid][pInsideBusiness] = gPlayerData[target][pInsideBusiness];

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ir] O administrador %d foi até o jogador %d.", Player_DBID(playerid), Player_DBID(target));
    Server_Log(playerid, target, LOG_ADMIN, logstr);
    return 1;
}

CMD:trazer(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new target;
    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /trazer [playerid] -{C0C0C0} Traz um jogador até você");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(target == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);

    new
        Float: x,
        Float: y,
        Float: z;

    GetPlayerPos(playerid, x, y, z);
    Player_SetPositionWithVehicle(target, x+1, y, z, 0.0, GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid));
    gPlayerData[target][pInsideHouse] = gPlayerData[playerid][pInsideHouse];
    gPlayerData[target][pInsideBusiness] = gPlayerData[playerid][pInsideBusiness];

    new logstr[128];
    format(logstr, sizeof(logstr), "[/trazer] O administrador %d trouxe o jogador %d.", Player_DBID(playerid), Player_DBID(target));
    Server_Log(playerid, target, LOG_ADMIN, logstr);
    return 1;
}

CMD:kick(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        target,
        reason[50];

    if(sscanf(params, "us[50]", target, reason))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /kick [playerid] [motivo] -{C0C0C0} Kicka um jogador do servidor");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(target == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(Admin_GetLevel(playerid) < Admin_GetLevel(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, HIGHER_ADMIN);

    new temp[128];
    format(temp, sizeof(temp), "[Admin] %s foi kickado do servidor por %s, motivo: %s", Player_GetRPName(target, true), Player_GetRPName(playerid, true), reason);
    SendClientMessageToAll(C_COLOR_ADMINWARN, temp);
    Player_Kick(target);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/kick] O administrador %d kickou o jogador %d pelo motivo: %s.", Player_DBID(playerid), Player_DBID(target), reason);
    Server_Log(playerid, target, LOG_ADMIN, logstr);
    return 1;
}

CMD:ban(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        target,
        reason[50];

    if(sscanf(params, "us[50]", target, reason))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ban [playerid] [motivo] -{C0C0C0} Bane um jogador do servidor");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(target == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(Admin_GetLevel(playerid) < Admin_GetLevel(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, HIGHER_ADMIN);

    new temp[128];
    format(temp, sizeof(temp), "[Admin] %s foi banido do servidor por %s, motivo: %s", Player_GetRPName(target, true), Player_GetRPName(playerid, true), reason);
    SendClientMessageToAll(C_COLOR_ADMINWARN, temp);
    Player_Ban(target);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ban] O administrador %d baniu o jogador %d pelo motivo: %s.", Player_DBID(playerid), Player_DBID(target), reason);
    Server_Log(playerid, target, LOG_ADMIN, logstr);
    return 1;
}

CMD:atrabalho(playerid, params[]){
    #pragma unused params

    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    if(gPlayerData[playerid][pAdmDuty] == 0){
        gPlayerData[playerid][pAdmDuty] = 1;
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você entrou em trabalho administrativo.");
        SetPlayerColor(playerid, C_COLOR_ADM);
    } else {
        gPlayerData[playerid][pAdmDuty] = 0;
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você saiu do trabalho administrativo.");
        SetPlayerColor(playerid, C_COLOR_PLAYER);
    }

    new logstr[128];
    format(logstr, sizeof(logstr), "[/atrabalho] O administrador %d entrou/saiu de trabalho. (%d).", Player_DBID(playerid), gPlayerData[playerid][pAdmDuty]);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);

    return 1;
}

CMD:skin(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        target,
        skinid;

    if(sscanf(params, "ud", target, skinid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /skin [playerid] [skin id] -{C0C0C0} Troca a skin de um jogador");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    //if(skinid < 0 || skinid > 311 || skinid == 74)
        //return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você escolheu uma skinid inválida.");

    gPlayerData[target][pSkin] = skinid;
    SetPlayerSkin(target, skinid);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/skin] O administrador %d trocou a skin do jogador %d para %d.", Player_DBID(playerid), Player_DBID(target), skinid);
    Server_Log(playerid, target, LOG_ADMIN, logstr);

    return 1;
}

CMD:admfac(playerid, params[]){
    #pragma unused params

    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new szDialog[800];

    for(new i = 0; i < C_MAX_FACTIONS; i++){
        if(gFactionData[i][fSQLID] != 0){
            new szFName[50];
            format(szFName, sizeof(szFName), "%s\n", gFactionData[i][fName]);
            strcat(szDialog, szFName);
        }
    }
    ShowPlayerDialog(playerid, DIALOG_ADMFAC, DIALOG_STYLE_LIST, "Administração de Facções", szDialog, "Selecionar", "Cancelar");
    return 1;
}

CMD:a(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /a [mensagem] -{C0C0C0} Envia uma mensagem a todos administradores online");

    new szAdmChat[164];
    format(szAdmChat, sizeof(szAdmChat), "@ %s %s: %s", Admin_GetRankName(playerid), Player_GetRPName(playerid, true), szText);
    Admin_SendMessage(C_COLOR_ADMINCHAT, szAdmChat);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/a] O administrador %s disse: %s.", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);

    return 1;
}

CMD:darlider(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        target,
        factionid;

    if(sscanf(params, "ud", target, factionid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /darlider [playerid] [id da facção] -{C0C0C0} Torna o jogador líder de uma facção");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(factionid < 0 || factionid > C_MAX_FACTIONS)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um id entre 0 e 20.");

    gPlayerData[target][pFaction] = factionid;

    new
        logstr[128],
        szLeader[128];

    if(factionid == 0){
        gPlayerData[target][pFactionRank] = 0;
        format(logstr, sizeof(logstr), "[/darlider] O administrador %d removeu o jogador %d de líder da facção atual.", Player_DBID(playerid), Player_DBID(target));

        format(szLeader, sizeof(szLeader), "* O administrador %s te removeu de líder da facção atual.", Player_GetRPName(playerid, true), gFactionData[factionid][fName]);
        SendClientMessage(target, C_COLOR_YELLOW, szLeader);
        format(szLeader, sizeof(szLeader), "* Você removeu o jogador %s da liderança da facção atual.", Player_GetRPName(target, true), gFactionData[factionid][fName]);
        SendClientMessage(playerid, C_COLOR_YELLOW, szLeader);

        if(gPlayerData[target][pSpawnLoc] == SPAWN_FACTION)
            gPlayerData[target][pSpawnLoc] = SPAWN_CIVILIAN;            
    }
    else{
        gPlayerData[target][pFactionRank] = 4;
        format(logstr, sizeof(logstr), "[/darlider] O administrador %d setou o jogador %d para líder do(a) %s.", Player_DBID(playerid), Player_DBID(target), gFactionData[factionid][fName]);

        format(szLeader, sizeof(szLeader), "* O administrador %s te tornou líder do(a) %s.", Player_GetRPName(playerid, true), gFactionData[factionid][fName]);
        SendClientMessage(target, C_COLOR_YELLOW, szLeader);
        format(szLeader, sizeof(szLeader), "* Você tornou o jogador %s líder do(a) %s.", Player_GetRPName(target, true), gFactionData[factionid][fName]);
        SendClientMessage(playerid, C_COLOR_YELLOW, szLeader);
    }

    Server_Log(playerid, target, LOG_ADMIN, logstr);

    return 1;
}

CMD:o(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /o [mensagem] -{C0C0C0} Envia uma mensagem a todos jogadores online");

    new szOocChat[164];
    format(szOocChat, sizeof(szOocChat), "(( [OOC] %s: %s ))", Player_GetRPName(playerid, true), szText);
    Player_SendLongMsgToAll(C_COLOR_GLOBALOOC, szOocChat);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/o] O administrador %s disse: %s.", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:x(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new Coords;

    if(sscanf(params, "d", Coords))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /x [quantidade] -{C0C0C0} Altera sua coordenada X. (X = atual + quantidade)");

    if(Coords > 1000)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha uma quantidade menor que 1000.");

    new Float: x, Float: y, Float: z;

    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(playerid, x+Coords, y, z);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/x] O administrador %s alterou em %d sua coordenada X.", Player_DBID(playerid), Coords);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:y(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new Coords;

    if(sscanf(params, "d", Coords))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /y [quantidade] -{C0C0C0} Altera sua coordenada Y. (Y = atual + quantidade)");

    if(Coords > 1000)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha uma quantidade menor que 1000.");

    new Float: x, Float: y, Float: z;

    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(playerid, x, y+Coords, z);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/y] O administrador %s alterou em %d sua coordenada Y.", Player_DBID(playerid), Coords);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:z(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);

    new Coords;

    if(sscanf(params, "d", Coords))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /z [quantidade] -{C0C0C0} Altera sua coordenada Z. (Z = atual + quantidade)");

    if(Coords > 1000)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha uma quantidade menor que 1000.");

    new Float: x, Float: y, Float: z;

    GetPlayerPos(playerid, x, y, z);
    SetPlayerPos(playerid, x, y, z+Coords);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/z] O administrador %d alterou em %d sua coordenada Z.", Player_DBID(playerid), Coords);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:tapa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new target;
    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /tapa [playerid] -{C0C0C0} Dá um tapa no jogador, suspendendo-o no ar");
    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(target == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(Admin_GetLevel(playerid) < Admin_GetLevel(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, HIGHER_ADMIN);

    new
        Float: x,
        Float: y,
        Float: z;

    GetPlayerPos(target, x, y, z);
    SetPlayerPos(target, x, y, z+5);
    PlayerPlaySound(target, 1130, x, y, z+5);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/tapa] O administrador %d deu um tapa no jogador %d.", Player_DBID(playerid), Player_DBID(target));
    Server_Log(playerid, target, LOG_ADMIN, logstr);
    return 1;
}

CMD:ircoord(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        Float: x,
        Float: y,
        Float: z;
    if(sscanf(params, "fff", x, y, z))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ircoord [x] [y] [z] -{C0C0C0} Seta sua posição para as coordenadas X Y e Z escolhidas");

    SetPlayerPos(playerid, x, y, z);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ircoord] O administrador %d se teleportou às coordenadas X=%f Y=%f Z=%f.", Player_DBID(playerid), x, y, z);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:criarcasa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        price,
        level;
    if(sscanf(params, "dd", price, level))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /criarcasa [preço] [level] -{C0C0C0} Cria uma nova casa em sua posição");

    if(price < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um preço maior que 0.");        
    if(level < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um level maior que 0.");            

    if(House_GetNextFreeID() == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O servidor atingiu o limite de casas.");

    new 
        Float:x,
        Float:y,
        Float:z,
        vwdoor,
        intdoor,
        houseid = House_GetNextFreeID();

    GetPlayerPos(playerid, x, y, z);
    intdoor = GetPlayerInterior(playerid);
    vwdoor = GetPlayerVirtualWorld(playerid);

    House_Create(houseid, price, level, x, y, z, -42.59, 1405.47, 1084.43, 0.0, vwdoor, intdoor, houseid, 8);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você criou uma casa em sua posição com sucesso!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/criarcasa] O administrador %d criou a casa %d custando $%d.", Player_DBID(playerid), houseid, price);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:destruircasa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        houseid;
    if(sscanf(params, "d", houseid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /destruircasa [casa id] -{C0C0C0} Deleta uma casa permanentemente");

    if(houseid < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha um ID maior do que 1.");

    if(gHouseData[houseid][hSQLID] == 0)
       return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa não existe.");

    House_Delete(houseid);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você deletou esta casa com sucesso!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/destruircasa] O administrador %d destruiu a casa %d.", Player_DBID(playerid), houseid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;    
}

CMD:criarempresa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        price,
        level,
        type;
    if(sscanf(params, "ddd", price, level, type)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /criarempresa [preço] [level] [tipo] -{C0C0C0} Cria uma nova empresa em sua posição");
        SendClientMessage(playerid, C_COLOR_PARAMS, "[TIPOS] 0:NULL, 1:24/7, 2:BAR, 3:CLUB, 4:CASINO, 5:BOAT_DEALER, 6:PLANE_DEALER, 7:MOTORCYCLE_DEALER");
        SendClientMessage(playerid, C_COLOR_PARAMS, "[TIPOS] 8:INDUSTRY_DEALER, 9:LOW_DEALER, 10:MEDIUM_DEALER, 11:HIGH_DEALER 12:GAS_GENERAL");
        return SendClientMessage(playerid, C_COLOR_PARAMS, "[TIPOS] 13:GAS_KEROSENE, 14:FURNITURE");
    }

    if(price < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um preço maior que 0.");        
    if(level < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um level maior que 0.");  
    if(type < 0 || type > 14)          
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um tipo entre 0 e 11.");

    if(Business_GetNextFreeID() == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O servidor atingiu o limite de empresas.");

    new 
        Float:x,
        Float:y,
        Float:z,
        vwdoor,
        intdoor,
        businessid = Business_GetNextFreeID();

    GetPlayerPos(playerid, x, y, z);
    intdoor = GetPlayerInterior(playerid);
    vwdoor = GetPlayerVirtualWorld(playerid);

    Business_Create(businessid, price, level, x, y, z, -42.59, 1405.47, 1084.43, 0.0, vwdoor, intdoor, businessid, 8, type);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você criou uma empresa em sua posição com sucesso!");

    if(type == BTYPE_DEALERSHIP_BOAT || BTYPE_DEALERSHIP_PLANE || BTYPE_DEALERSHIP_MOTORCYCLE || BTYPE_DEALERSHIP_INDUSTRY || BTYPE_DEALERSHIP_LOW || BTYPE_DEALERSHIP_MEDIUM || BTYPE_DEALERSHIP_HIGH)
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Não se esqueça de setar o ponto de spawn dos veículos desta concessionária. (/editarempresa vspawn)");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/criarempresa] O administrador %d criou a empresa %d custando $%d.", Player_DBID(playerid), businessid, price);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:destruirempresa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        businessid;
    if(sscanf(params, "d", businessid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /destruirempresa [empresaid] -{C0C0C0} Deleta uma empresa permanentemente");

    if(businessid < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha um ID maior do que 1.");

    if(gBusinessData[businessid][bSQLID] == 0)
       return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não existe.");

    Business_Delete(businessid);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você deletou esta empresa com sucesso!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/destruirempresa] O administrador %d destruiu a empresa %d.", Player_DBID(playerid), businessid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;    
}

CMD:trazerveiculo(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        vehicleid;
    if(sscanf(params, "d", vehicleid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /trazerveiculo [veiculoid] -{C0C0C0} Traz um veículo até você");

    if(!IsValidVehicle(vehicleid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo não existe.");

    new
        Float:x,
        Float:y,
        Float:z;

    GetPlayerPos(playerid, x, y, z);
    SetVehiclePos(vehicleid, x, y+2, z);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você trouxe o veículo até você!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/trazerveiculo] O administrador %d trouxe o veículo %d.", Player_DBID(playerid), vehicleid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;     
}

CMD:irveiculo(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        vehicleid;
    if(sscanf(params, "d", vehicleid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /irveiculo [veiculoid] -{C0C0C0} Leva você até um veículo");

    if(!IsValidVehicle(vehicleid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo não existe.");

    new
        Float:x,
        Float:y,
        Float:z;

    GetVehiclePos(vehicleid, x, y, z);
    SetPlayerPos(playerid, x, y+2, z);

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você foi até o veículo!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/irveiculo] O administrador %d foi até o veículo %d.", Player_DBID(playerid), vehicleid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;     
}

CMD:gmx(playerid, params[]){
    if(Admin_GetLevel(playerid) < 7)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(!Player_Logged(i)) continue;
        Player_CharacterSave(i);
        Player_ResetCharacterVariables(i);
        Player_ResetTimers(i);
        SetPlayerName(i, gAccountData[i][aName]);        
    }

    SetTimer("Server_Restart", 1000, false); //Aumentar conforme não salvar mais

    new logstr[128];
    format(logstr, sizeof(logstr), "[/gmx] O administrador %d reiniciou o servidor.", Player_DBID(playerid));
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:setarvida(playerid, params[]){
    if(Admin_GetLevel(playerid) < 3)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);   

    new
        targetid,
        Float:health;

    if(sscanf(params, "uf", targetid, health))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /setarvida [playerid] [vida] -{C0C0C0} Seta a vida de um jogador");

    if(health < 0 || health > 100)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha uma vida entre 0 e 100.");
    if(!IsPlayerConnected(targetid) || !Player_Logged(targetid))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);        
    if(Admin_GetLevel(playerid) < Admin_GetLevel(targetid))
        return SendClientMessage(playerid, C_COLOR_ERROR, HIGHER_ADMIN);      

    SetPlayerHealth(targetid, health);
    new
        szHealth[80];

    format(szHealth, sizeof(szHealth), "[INFO] {FFFFFF}O administrador %s setou sua vida para %.2f", Player_GetRPName(playerid, true), health);
    SendClientMessage(targetid, C_COLOR_SUCCESS, szHealth);

    format(szHealth, sizeof(szHealth), "[INFO] {FFFFFF}Você setou a vida de %s para %.2f", Player_GetRPName(targetid, true), health);
    SendClientMessage(playerid, C_COLOR_SUCCESS, szHealth);
    return 1; 
}

CMD:ircasa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        houseid;
    if(sscanf(params, "d", houseid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ircasa [casaid] -{C0C0C0} Leva você até uma casa");

    if(houseid < 1 || houseid >= C_MAX_HOUSES)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha um ID de casa válido.");
    if(gHouseData[houseid][hSQLID] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa não existe.");

    Player_SetPosition(playerid, gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ], 0.0, gHouseData[houseid][hIntDoor], gHouseData[houseid][hVWDoor]);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você foi até a casa!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ircasa] O administrador %d foi até a casa %d.", Player_DBID(playerid), houseid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;
}

CMD:irempresa(playerid, params[]){
    if(Admin_GetLevel(playerid) < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        businessid;
    if(sscanf(params, "d", businessid))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /irempresa [empresaid] -{C0C0C0} Leva você até uma empresa");

    if(businessid < 1 || businessid >= C_MAX_BUSINESSES)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha um ID de empresa válido.");
    if(gBusinessData[businessid][bSQLID] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não existe.");

    Player_SetPosition(playerid, gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ], 0.0, gBusinessData[businessid][bIntDoor], gBusinessData[businessid][bVWDoor]);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você foi até a empresa!");

    new logstr[128];
    format(logstr, sizeof(logstr), "[/irempresa] O administrador %d foi até a empresa %d.", Player_DBID(playerid), businessid);
    Server_Log(playerid, -1, LOG_ADMIN, logstr);
    return 1;     
}

CMD:dararma(playerid, params[]){
    if(Admin_GetLevel(playerid) < 5)
        return SendClientMessage(playerid, C_COLOR_ERROR, NO_PERMISSION);
    new
        targetid,
        weapon,
        ammo;
    if(sscanf(params, "udd", targetid, weapon, ammo))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /dararma [playerid] [armaid] [munição] -{C0C0C0} Seta uma arma para um jogador");

    if(!IsPlayerConnected(targetid) || !Player_Logged(targetid))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(weapon < 1 || weapon > 46)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha um ID de arma válido.");
    if(ammo < 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Escolha uma quantia de munição maior ou igual a 0 (0 = Remove a arma do jogador).");

    new 
        logstr[128],
        szWeapon[128];

    if(ammo != 0){    
        Player_GiveWeapon(playerid, weapon, ammo);
        format(szWeapon, sizeof(szWeapon), "[INFO] {FFFFFF}Você setou uma arma ID %d para o jogador %s com %d munições.", weapon, Player_GetRPName(targetid, true), ammo);
        SendClientMessage(playerid, C_COLOR_SUCCESS, szWeapon);
        format(szWeapon, sizeof(szWeapon), "[INFO] {FFFFFF}O administrador %s te setou uma arma ID %d com %d munições.", Player_GetRPName(playerid, true), weapon, ammo);
        SendClientMessage(targetid, C_COLOR_SUCCESS, szWeapon);
        format(logstr, sizeof(logstr), "[/dararma] O administrador %d deu para o jogador %d a arma %d com %d balas.", Player_DBID(playerid), Player_DBID(targetid), weapon, ammo);
    } else {
        Player_RemoveWeapon(playerid, weapon);
        format(szWeapon, sizeof(szWeapon), "[INFO] {FFFFFF}Você removeu a arma ID %d do jogador %s.", weapon, Player_GetRPName(targetid, true));
        SendClientMessage(playerid, C_COLOR_SUCCESS, szWeapon);
        format(szWeapon, sizeof(szWeapon), "[INFO] {FFFFFF}O administrador %s removeu a sua arma ID %d.", Player_GetRPName(playerid, true), weapon);
        SendClientMessage(targetid, C_COLOR_SUCCESS, szWeapon);
        format(logstr, sizeof(logstr), "[/dararma] O administrador %d removeu do jogador %d a arma %d.", Player_DBID(playerid), Player_DBID(targetid), weapon);
    }
    
    Server_Log(playerid, targetid, LOG_ADMIN, logstr);
    return 1;
}
