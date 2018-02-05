// system_player | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções

Player_CheckAccount(playerid){
    new temp[120];

    TogglePlayerSpectating(playerid, 1);
    SetTimerEx("Player_CharSelectCamera", 200, false, "i", playerid);

    mysql_format(hSQL, temp, sizeof(temp), "select member_id from `members` where `name` = '%e' limit 1", Player_GetName(playerid));
    new Cache:result = mysql_query(hSQL, temp);

    if(cache_num_rows() > 0){
        new sqlID = cache_get_field_content_int(0, "member_id", hSQL);
        for(new i = 0; i < GetMaxPlayers(); i++){
            if(gAccountData[i][aSQLID] == sqlID && i != playerid){
                Player_Kick(playerid);   
                ShowPlayerDialog(playerid, DIALOG_UCPREDIR, DIALOG_STYLE_MSGBOX, "Ooops!", "Este usuário já está logado no servidor. A conta é sua? Você pode bloqueá-la imediatamente \
                    em nosso Fórum.\n\n           {FFFFFF}habbismo.com/ipb", "Confirmar", "");
                return 1;
            }
        }        
        Player_DisplayLogin(playerid, "Seja bem vindo ao Safira.\n\n {FFFFFF}Digite sua senha abaixo para autenticar-se");
        gPlayerData[playerid][pSQLID] = cache_get_field_content_int(0, "member_id", hSQL);
        gPlayerData[playerid][pScene] = Text3D:INVALID_3DTEXT_ID;
        gPlayerData[playerid][pDeadText] = Text3D:INVALID_3DTEXT_ID;
    }
    else{
        Player_Kick(playerid);
        ShowPlayerDialog(playerid, DIALOG_UCPREDIR, DIALOG_STYLE_MSGBOX, "Ooops!", "Este usuário não foi identificado em nosso banco de dados.\nVocê pode criar uma conta nova \
        em nosso Fórum.\n\n           {FFFFFF}habbismo.com/ipb", "Confirmar", "");
    }

    cache_delete(result, hSQL);
    return 1;
}

Player_DBID(playerid){
    return gPlayerData[playerid][pSQLID];
}

Player_Logged(playerid){
    if(gPlayerData[playerid][pLogged] == 1) return 1;
    else return 0;
}

Player_GetName(playerid){
    new temp[32];
    GetPlayerName(playerid, temp, sizeof(temp));
    return temp;
}

Player_GetRPName(playerid, bool:ignoreMask){
    new temp[30];
    if(gPlayerData[playerid][pMaskOn] == 0 || ignoreMask == true){
        GetPlayerName(playerid, temp, sizeof(temp));
        for(new i = 0; i < strlen(temp); i++){
            if(temp[i] == '_')
                temp[i] = ' ';
        }
    } else {
        format(temp, sizeof(temp), "Desconhecido_%d", gPlayerData[playerid][pMask]);
    }
    return temp;
}

Player_GetFactionID(playerid){
    return gPlayerData[playerid][pFaction];
}

Player_FactionRank(playerid){
    return gPlayerData[playerid][pFactionRank];
}

Player_GetJobID(playerid){
    return gPlayerData[playerid][pJob];
}

Player_DisplayLogin(playerid, displaytext[]){
    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "{0E9DBA}Login no Safira", displaytext, "Login", "Sair");
    return 1;
}

Player_Authenticate(playerid, password[]){
    new
        temp[256],
        hash[64],
        salt[12],
        salthash[64],
        finalhash[33],
        member_id;

    mysql_format(hSQL, temp, sizeof(temp), "select member_id, members_pass_hash, members_pass_salt from `members` where `name` = '%e' limit 1", Player_GetName(playerid));
    new Cache:result = mysql_query(hSQL, temp);

    cache_get_field_content(0, "members_pass_hash", finalhash, hSQL, 33);
    cache_get_field_content(0, "members_pass_salt", salt, hSQL, 12);     
    member_id = cache_get_field_content_int(0, "member_id", hSQL);


    hash = MD5_Hash(password, true);
    salthash = MD5_Hash(salt, true);
    strins(hash, salthash, 0);
    hash = MD5_Hash(hash, true);

    if(!strcmp(hash, finalhash)){
        new status = Player_GetAppStatus(member_id);
        if(status == 0){
            ShowPlayerDialog(playerid, DIALOG_APPSTATUS, DIALOG_STYLE_MSGBOX, "Ooops!", "Parece que este usuário foi {C60000}reprovado {A9C4E4}na avaliação administrativa.\nVocê pode \
             enviar outra aplicação pelo nosso fórum.\n\n           {FFFFFF}habbismo.com/ipb", "Confirmar", "");
            Player_Kick(playerid);                        
        } else if(status == 2) {
            ShowPlayerDialog(playerid, DIALOG_APPSTATUS, DIALOG_STYLE_MSGBOX, "Ooops!", "Parece que este usuário ainda não foi aprovado na avaliação administrativa.\nEste processo pode \
             levar de 1 hora à 2 dias.\nSe você não se lembra de ter preenchido esta aplicação, certifique-se de preenchê-la em nosso fórum.\n\n           {FFFFFF}habbismo.com/ipb", "Confirmar", "");
            Player_Kick(playerid);           
        } else {
            gAccountData[playerid][aSQLID] = member_id;
            format(gAccountData[playerid][aName], 32, "%s", Player_GetName(playerid));
            Player_ShowCharacterList(playerid);

            new logstr[128];
            format(logstr, sizeof(logstr), "[Login] O jogador %d realizou login com sucesso.", Player_DBID(playerid));
            Server_Log(playerid, -1, LOG_LOGIN, logstr);
        }
    } else {
        if(gPlayerData[playerid][pLoginFailed] >= 3){
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você atingiu o número de tentativas de login e foi kickado!");
            Player_Kick(playerid);

            new logstr[128];
            format(logstr, sizeof(logstr), "[Login] O jogador %d foi kickado por errar a senha 3 vezes.", Player_DBID(playerid));
            Server_Log(playerid, -1, LOG_LOGIN, logstr);
            return 1;
        }
        new temp2[80];
        gPlayerData[playerid][pLoginFailed] ++;
        format(temp2, sizeof(temp2), "Senha Incorreta! (%d/3)\n\n{FFFFFF}Digite sua senha abaixo para autenticar-se", gPlayerData[playerid][pLoginFailed]);
        Player_DisplayLogin(playerid, temp2);        
    }
    cache_delete(result, hSQL);
    return 1;
}

Player_GetCharacterCount(playerid){
    new temp[64];
    mysql_format(hSQL, temp, sizeof(temp), "select * from `character` where `id_account` = '%d'", gAccountData[playerid][aSQLID]);
    new 
        Cache:result = mysql_query(hSQL, temp),
        characters = cache_num_rows();

    cache_delete(result);

    return characters;    
}

Player_ShowCharacterList(playerid){
    new temp[80];

    mysql_format(hSQL, temp, sizeof(temp), "select name, id_faction from `character` where `id_account` = '%d'", gAccountData[playerid][aSQLID]);
    new Cache:result = mysql_query(hSQL, temp);

    new 
        rows = cache_num_rows(),
        index = 0,
        szCharacters[512];

    //Colocar sistema de criação de personagens pela última opção do dialog

    while(index < rows){
        new 
            szTemp[32],
            szFaction[50],
            szAux[128],
            factionid;

        cache_get_field_content(index, "name", szTemp, hSQL, 32);
        factionid = cache_get_field_content_int(index, "id_faction", hSQL);

        if(factionid == 0)
            szFaction = "Civil";
        else
            format(szFaction, sizeof(szFaction), "%s", gFactionData[factionid][fName]);  

        format(szAux, sizeof(szAux), "Entrar como {008AA3}%s{FFFFFF} (%s)%s", szTemp, szFaction, rows-index==1 ? ("\n \n") : ("\n"));
        strcat(szCharacters, szAux);
        index++;
    }

    strcat(szCharacters, "Criar um novo personagem");

    ShowPlayerDialog(playerid, DIALOG_CHARACTERS, DIALOG_STYLE_LIST, "Seleção de Personagens", szCharacters, "Selecionar", "Sair");

    cache_delete(result);

    return 1;
}

Player_GetAppStatus(member_id){
    new temp[80];

    mysql_format(hSQL, temp, sizeof(temp), "select field_12 from `pfields_content` where `member_id` = '%d' limit 1", member_id);
    new
        Cache:result = mysql_query(hSQL, temp),
        status[10];

    cache_get_field_content(0, "field_12", status, hSQL, 10);
    cache_delete(result, hSQL);

    if(!strcmp(status, "NULL")){
        return 2;
    }
    else if(!strcmp(status, "n"))
        return 0;        
    else
        return 1;    
}

Player_CharacterSave(playerid){
    new temp[600];

    mysql_format(hSQL, temp, sizeof(temp), "update `character` set\
     `admin` = '%d',\
     `level` = '%d',\
     `tutorial` = '%d',\
     `skin` = '%d',\
     `spawnX` = '%f',\
     `spawnY` = '%f',\
     `spawnZ` = '%f',\
     `spawnR` = '%f',\
     `id_faction` = '%d',\
     `factionrank` = '%d',\
     `rankname` = '%e',\
     `mask` = '%d',\
     `money` = '%d',\
     `spawnloc` = '%d',\
     `propertyspawn` = '%d',\
     `insideHouse` = '%d',\
     `insideBusiness` = '%d',\
     `leavereason` = '%d',\
     `toolkit` = '%d',\
     `cellphone` = '%d',\
     `interior` = '%d',\
     `vw` = '%d',\
     `death` = '%d'\
      where `id_character` = '%d'",

    gPlayerData[playerid][pAdmin],
    gPlayerData[playerid][pLevel],
    gPlayerData[playerid][pTutorial],
    gPlayerData[playerid][pSkin],
    gPlayerData[playerid][pSpawnX],
    gPlayerData[playerid][pSpawnY],
    gPlayerData[playerid][pSpawnZ],
    gPlayerData[playerid][pSpawnR],
    gPlayerData[playerid][pFaction],
    gPlayerData[playerid][pFactionRank],
    gPlayerData[playerid][pRankName],
    gPlayerData[playerid][pMask],
    gPlayerData[playerid][pMoney],
    gPlayerData[playerid][pSpawnLoc],
    gPlayerData[playerid][pPropertySpawn],
    gPlayerData[playerid][pInsideHouse],
    gPlayerData[playerid][pInsideBusiness],
    gPlayerData[playerid][pLeaveReason],
    gPlayerData[playerid][pToolkit],
    gPlayerData[playerid][pCellphone],
    gPlayerData[playerid][pInterior],
    gPlayerData[playerid][pVW],
    gPlayerData[playerid][pDeath],
    gPlayerData[playerid][pSQLID]);

    mysql_query(hSQL, temp);

    return 1;
}

Player_CharacterLoad(playerid, characterid){
    new temp[80];

    mysql_format(hSQL, temp, sizeof(temp), "select * from `character` where `id_character` = '%d' limit 1", characterid);
    new
        Cache:result = mysql_query(hSQL, temp);

    gPlayerData[playerid][pSQLID] = cache_get_field_content_int(0, "id_character", hSQL);
    gPlayerData[playerid][pACCID] = cache_get_field_content_int(0, "id_account", hSQL);
    cache_get_field_content(0, "name", gPlayerData[playerid][pName], hSQL, 32);
    gPlayerData[playerid][pAdmin] = cache_get_field_content_int(0, "admin", hSQL);
    gPlayerData[playerid][pLevel] = cache_get_field_content_int(0, "level", hSQL);
    gPlayerData[playerid][pTutorial] = cache_get_field_content_int(0, "tutorial", hSQL);
    gPlayerData[playerid][pSkin] = cache_get_field_content_int(0, "skin", hSQL);
    gPlayerData[playerid][pSpawnX] = cache_get_field_content_float(0, "spawnX", hSQL);
    gPlayerData[playerid][pSpawnY] = cache_get_field_content_float(0, "spawnY", hSQL);
    gPlayerData[playerid][pSpawnZ] = cache_get_field_content_float(0, "spawnZ", hSQL);
    gPlayerData[playerid][pSpawnR] = cache_get_field_content_float(0, "spawnR", hSQL);
    gPlayerData[playerid][pFaction] = cache_get_field_content_int(0, "id_faction", hSQL);
    gPlayerData[playerid][pFactionRank] = cache_get_field_content_int(0, "factionrank", hSQL);
    cache_get_field_content(0, "rankname", gPlayerData[playerid][pRankName], hSQL, 32);
    gPlayerData[playerid][pMask] = cache_get_field_content_int(0, "mask", hSQL);
    gPlayerData[playerid][pMoney] = cache_get_field_content_int(0, "money", hSQL);
    gPlayerData[playerid][pSpawnLoc] = cache_get_field_content_int(0, "spawnloc", hSQL);
    gPlayerData[playerid][pPropertySpawn] = cache_get_field_content_int(0, "propertyspawn", hSQL);
    gPlayerData[playerid][pInsideHouse] = cache_get_field_content_int(0, "insideHouse", hSQL);
    gPlayerData[playerid][pInsideBusiness] = cache_get_field_content_int(0, "insideBusiness", hSQL);
    gPlayerData[playerid][pLeaveReason] = cache_get_field_content_int(0, "leavereason", hSQL);
    gPlayerData[playerid][pToolkit] = cache_get_field_content_int(0, "toolkit", hSQL);
    gPlayerData[playerid][pCellphone] = cache_get_field_content_int(0, "cellphone", hSQL);
    gPlayerData[playerid][pInterior] = cache_get_field_content_int(0, "interior", hSQL);
    gPlayerData[playerid][pVW] = cache_get_field_content_int(0, "vw", hSQL);
    gPlayerData[playerid][pDeath] = cache_get_field_content_int(0, "death", hSQL);

    if(gPlayerData[playerid][pTutorial] != 0){
        TogglePlayerSpectating(playerid, 0);
        Player_PutOnWorld(playerid);
    }
    else{
        gPlayerData[playerid][pInTutorial] = 1;
        Player_Tutorial(playerid, 1);
    }

    SetPlayerScore(playerid, gPlayerData[playerid][pLevel]);  
    SetPlayerName(playerid, gPlayerData[playerid][pName]);    

    gPlayerData[playerid][pCellphoneCall] = -1;

    cache_delete(result); 

    return 1;
}

Player_PutOnWorld(playerid){
    TogglePlayerSpectating(playerid, 0);
    gPlayerData[playerid][pLogged] = 1;    

    SetSpawnInfo(playerid, 0, gPlayerData[playerid][pSkin], gPlayerData[playerid][pSpawnX], gPlayerData[playerid][pSpawnY], gPlayerData[playerid][pSpawnZ], gPlayerData[playerid][pSpawnR], 0, 0, 0, 0, 0, 0);
    if(gPlayerData[playerid][pLeaveReason] == 0){        
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você voltou à sua posição anterior devido à desconexão inesperada.");
    }

    SpawnPlayer(playerid);
    GivePlayerMoney(playerid, gPlayerData[playerid][pMoney]);
    SendClientMessage(playerid, -1, "{e61659}B{d897cf}E {b1ce95}H{0cc02d}A{4334f5}P{7f0a39}P{f0b020}Y{12efee}!");

    return 1;
}

Player_Tutorial(playerid, stage){
    switch(stage){
        case 1:{
            Player_CleanChat(playerid);
            SendClientMessage(playerid, C_COLOR_WHITE, "____________________________________________________[Parte 1]____________________________________________________");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_WHITE, "Pressione {49C912}Espaço {FFFFFF}para avançar o tutorial.");
            gPlayerData[playerid][pInTutorial] = 2;
        }
        case 2:{
            Player_CleanChat(playerid);
            SendClientMessage(playerid, C_COLOR_WHITE, "____________________________________________________[Parte 2]____________________________________________________");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_WHITE, "Pressione {49C912}Espaço {FFFFFF}para avançar o tutorial.");
            gPlayerData[playerid][pInTutorial] = 3;
        }
        case 3:{
            Player_CleanChat(playerid);
            SendClientMessage(playerid, C_COLOR_WHITE, "____________________________________________________[Parte 3]____________________________________________________");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_WHITE, "Pressione {49C912}Espaço {FFFFFF}para avançar o tutorial.");
            gPlayerData[playerid][pInTutorial] = 4;
        }
        case 4:{
            Player_CleanChat(playerid);
            SendClientMessage(playerid, C_COLOR_WHITE, "____________________________________________________[Parte 4]____________________________________________________");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_SYNTAX, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus sit amet lacus hendrerit tristique.");
            SendClientMessage(playerid, C_COLOR_WHITE, "Pressione {49C912}Espaço {FFFFFF}para terminar o tutorial.");
            gPlayerData[playerid][pInTutorial] = 5;
        }
        case 5:{
            Player_CleanChat(playerid);
            gPlayerData[playerid][pTutorial] = 1;
            TogglePlayerSpectating(playerid, 0);
            gPlayerData[playerid][pSpawnX] = DEFAULTSPAWNX;
            gPlayerData[playerid][pSpawnY] = DEFAULTSPAWNY;
            gPlayerData[playerid][pSpawnZ] =  DEFAULTSPAWNZ;
            gPlayerData[playerid][pSpawnR] = DEFAULTSPAWNR;
            gPlayerData[playerid][pInsideHouse] = -1;
            gPlayerData[playerid][pInsideBusiness] = -1;
            Player_PutOnWorld(playerid);
            SendClientMessage(playerid, C_COLOR_WHITE, "Vc terminou o tutorial. Vc e burraum.");
            gPlayerData[playerid][pInTutorial] = 0;
            Player_CharacterSave(playerid);
        }
        default:{
            SendClientMessage(playerid, C_COLOR_ERROR, "Erro crítico (0x00f). Contate um desenvolvedor.");
        }
    }
    return 1;
}

Player_CleanChat(playerid){
    for(new i = 0; i < 70; i++){
        SendClientMessage(playerid, -1, "");
    }

    return 1;
}

Player_ResetCharacterVariables(playerid){

    Delete3DTextLabel(gPlayerData[playerid][pScene]);
    Delete3DTextLabel(gPlayerData[playerid][pDeadText]);

    gPlayerData[playerid][pSQLID] = -1;
    gPlayerData[playerid][pOwner] = 0;
    gPlayerData[playerid][pAdmin] = 0;
    gPlayerData[playerid][pLogged] = 0;
    gPlayerData[playerid][pLoginFailed] = 0;
    gPlayerData[playerid][pTutorial] = 0;
    gPlayerData[playerid][pInTutorial] = 0;
    gPlayerData[playerid][pSkin] = 0;
    gPlayerData[playerid][pSpawnX] = 0.0;
    gPlayerData[playerid][pSpawnY] = 0.0;
    gPlayerData[playerid][pSpawnZ] = 0.0;
    gPlayerData[playerid][pSpawnR] = 0.0;
    gPlayerData[playerid][pFaction] = 0;
    gPlayerData[playerid][pFactionTog] = 0;
    gPlayerData[playerid][pFactionRank] = 0;
    gPlayerData[playerid][pMask] = 0;
    gPlayerData[playerid][pMaskOn] = 0;
    gPlayerData[playerid][pMoney] = 0;
    gPlayerData[playerid][pBlockPM] = 0;
    gPlayerData[playerid][pSpawnLoc] = 0;
    gPlayerData[playerid][pLeaveReason] = 4;
    gPlayerData[playerid][pFactionInvite] = 0;
    gPlayerData[playerid][pFacDuty] = 0;
    gPlayerData[playerid][pScene] = Text3D:INVALID_3DTEXT_ID;
    gPlayerData[playerid][pSceneCreated] = 0;
    gPlayerData[playerid][pInsideHouse] = -1;
    gPlayerData[playerid][pInsideBusiness] = -1;
    gPlayerData[playerid][pLogoutDelay] = 0;
    gPlayerData[playerid][pJob] = 0;
    gPlayerData[playerid][pVehRefueling] = 0;
    gPlayerData[playerid][pBusinessRefueling] = 0;
    gPlayerData[playerid][pRefuelingType] = 0;
    gPlayerData[playerid][pVehBreakingIn] = 0;
    gPlayerData[playerid][pVehBreakingInTime] = 0;
    gPlayerData[playerid][pToolkit] = 0;
    gPlayerData[playerid][pCellphone] = 0;
    gPlayerData[playerid][pCellphoneCall] = -1;
    gPlayerData[playerid][pCellphoneStatus] = 1;
    gPlayerData[playerid][pInterior] = 0;
    gPlayerData[playerid][pVW] = 0;
    gPlayerData[playerid][pDeath] = 0;
    gPlayerData[playerid][pDeadText] = Text3D:INVALID_3DTEXT_ID;

    ResetPlayerMoney(playerid);
    Player_ResetShotInfo(playerid);
    Player_ResetWeapons(playerid);

    gPlayerData[playerid][pACDelay] = 0;
    return 1;
}

Player_ResetAccountVariables(playerid){

    gAccountData[playerid][aSQLID] = -1;
    format(gAccountData[playerid][aName], 32, "");

    return 1;
}

Player_Kick(playerid){
    SetTimerEx("Server_Kick", 200, false, "i", playerid);

    return 1;
}

Player_Ban(playerid){
    SetTimerEx("Server_Ban", 200, false, "i", playerid);

    return 1;
}

Player_SendLongMsg(playerid, color, const msg[]) {
    if(strlen(msg) > 90) {
		new
            szAux1[210], szAux2[210], szAux3[210];
        format(szAux1, sizeof(szAux1), msg);
		format(szAux2, sizeof(szAux2), msg);
		strdel(szAux1, 90, 256);
		strdel(szAux2, 0, 90);
		format(szAux3, sizeof(szAux3), "%s ...", szAux1);
		SendClientMessage(playerid,color, szAux3);
		format(szAux3, sizeof(szAux3), "... %s", szAux2);
		SendClientMessage(playerid,color, szAux3);
		return true;
	}
	else {
	    SendClientMessage(playerid,color, msg);
	    return true;
	}
}
Player_SendLongMsgToAll(color, const msg[]){
    if(strlen(msg) > 90) {
		new
            szAux1[210], szAux2[210], szAux3[210];
        format(szAux1, sizeof(szAux1), msg);
		format(szAux2, sizeof(szAux2), msg);
		strdel(szAux1, 90, 256);
		strdel(szAux2, 0, 90);
		format(szAux3, sizeof(szAux3), "%s ...", szAux1);
		SendClientMessageToAll(color, szAux3);
		format(szAux3, sizeof(szAux3), "... %s", szAux2);
		SendClientMessageToAll(color, szAux3);
		return true;
	}
	else {
	    SendClientMessageToAll(color, msg);
	    return true;
	}
}

Player_SendLongAction(playerid, color, const act[]) {
    if(strlen(act) > 90) {
		new
            szAux1[210], szAux2[210], szAux3[210];
        format(szAux1, sizeof(szAux1), act);
		format(szAux2, sizeof(szAux2), act);
		strdel(szAux1, 90, 256);
		strdel(szAux2, 0, 90);
		format(szAux3, sizeof(szAux3), "%s ...", szAux1);
		SendClientMessage(playerid,color, szAux3);
		format(szAux3, sizeof(szAux3), "... %s ((%s))", szAux2, Player_GetRPName(playerid, false));
		SendClientMessage(playerid,color, szAux3);
		return true;
	}
	else {
	    SendClientMessage(playerid,color, act);
	    return true;
	}
}

Player_GetLevel(playerid){
    return gPlayerData[playerid][pLevel];
}

Player_GetMoney(playerid){
    return gPlayerData[playerid][pMoney];
}

Player_GiveMoney(playerid, amount){
    gPlayerData[playerid][pMoney] += amount;
    GivePlayerMoney(playerid, amount);
    return 1;
}

Player_IsNearPlayer(Float:range, playerid, target){
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    if(IsPlayerInRangeOfPoint(target, range, x, y, z))
        return true;
    return false;
}

Player_GetNearestHouse(playerid){
    new
        nearest = -1,
        Float:dist = 4.0;
    for(new i = 0; i < C_MAX_HOUSES; i++){
        if(IsPlayerInRangeOfPoint(playerid, dist, gHouseData[i][hDoorX], gHouseData[i][hDoorY], gHouseData[i][hDoorZ]) && gHouseData[i][hSQLID] > 0){
            nearest = i;
            dist = GetPlayerDistanceFromPoint(playerid, gHouseData[i][hDoorX], gHouseData[i][hDoorY], gHouseData[i][hDoorZ]);
        }
    }
    return nearest;
}

Player_GetNearestBusiness(playerid){
    new
        nearest = -1,
        Float:dist = 4.0;
    for(new i = 0; i < C_MAX_BUSINESSES; i++){
        if(IsPlayerInRangeOfPoint(playerid, dist, gBusinessData[i][bDoorX], gBusinessData[i][bDoorY], gBusinessData[i][bDoorZ]) && gBusinessData[i][bSQLID] > 0){
            nearest = i;
            dist = GetPlayerDistanceFromPoint(playerid, gBusinessData[i][bDoorX], gBusinessData[i][bDoorY], gBusinessData[i][bDoorZ]);
        }
    }
    return nearest;
}

Player_GetNearestVehicle(playerid){
    new
        nearest = -1,
        Float:dist = 4.0;
    for(new i = 1; i < MAX_VEHICLES; i++){
        new
            Float:x,
            Float:y,
            Float:z;
        GetVehiclePos(i, x, y, z);
        if(IsPlayerInRangeOfPoint(playerid, dist, x, y, z) && IsValidVehicle(i)){
            nearest = i;
            dist = GetPlayerDistanceFromPoint(playerid, x, y, z);
        }
    }
    return nearest;
}

Player_SetPosition(playerid, Float: x, Float: y, Float: z, Float: r = 0.0, Interior = 0, VW = 0, freezetime = 0){
    /*if(freezetime != 0){
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("TogglePlayerControllable", freezetime, false, "ii", playerid, 1);
    }*/
    SetPlayerInterior(playerid, Interior);
    SetPlayerVirtualWorld(playerid, VW);
    SetPlayerPos(playerid, x, y, z);
    SetPlayerFacingAngle(playerid, r);
    return 1;
}

Player_SetPositionWithVehicle(playerid, Float: x, Float: y, Float: z, Float: r = 0.0, Interior = 0, VW = 0, freezetime = 0){
    /*if(freezetime != 0){
        TogglePlayerControllable(playerid, 0);
        SetTimerEx("TogglePlayerControllable", freezetime, false, "ii", playerid, 1);
    }*/
    if(IsPlayerInAnyVehicle(playerid)){
        new vehicleid = GetPlayerVehicleID(playerid);
        SetVehiclePos(vehicleid, x, y, z);
        SetVehicleZAngle(vehicleid, r);
        LinkVehicleToInterior(vehicleid, Interior);
        SetVehicleVirtualWorld(vehicleid, VW);
    } else { 
        SetPlayerPos(playerid, x, y, z);
        SetPlayerFacingAngle(playerid, r);
    }
    SetPlayerInterior(playerid, Interior);
    SetPlayerVirtualWorld(playerid, VW);    
    return 1;
}

function Player_PrepareLogout(playerid){
    if(gPlayerData[playerid][pLogoutDelay] > 0){
        new
            szLogout[50];
        format(szLogout, sizeof(szLogout), "Desconectando-se em %d segundos.", gPlayerData[playerid][pLogoutDelay]);
        SetPlayerChatBubble(playerid, szLogout, C_COLOR_WARNING, 30.0, 1200);
        gPlayerData[playerid][pLogoutDelay]--;
    } else {
        Player_Logout(playerid);
        KillTimer(gPlayerData[playerid][pLogoutTimer]);
        gPlayerData[playerid][pLogoutTimer] = 0;
    }
    return 1;
}

stock Player_Logout(playerid){
    new
        szLogout[64];
    format(szLogout, sizeof(szLogout), "%s saiu do servidor. (Seleção de Personagens)", Player_GetRPName(playerid, true));
    
    gPlayerData[playerid][pInterior] = 0;
    gPlayerData[playerid][pVW] = 0;
    gPlayerData[playerid][pInsideHouse] = -1;
    gPlayerData[playerid][pInsideBusiness] = -1;

    Player_CharacterSave(playerid);
    Player_ResetCharacterVariables(playerid);
    Player_ResetTimers(playerid);    
    ProxDetector(10.0, playerid, szLogout, C_COLOR_WHITE, C_COLOR_WHITE, C_COLOR_WHITE, C_COLOR_WHITE, C_COLOR_WHITE);
    Player_ShowCharacterList(playerid);
    SetPlayerName(playerid, gAccountData[playerid][aName]);
    gPlayerData[playerid][pLogged] = 0;
    SetPlayerVirtualWorld(playerid, playerid+5000);
    SetPlayerInterior(playerid, 0);
    SetPlayerPos(playerid, 0, 0, 1000);
    TogglePlayerControllable(playerid, 0);
    TogglePlayerSpectating(playerid, 1);

    SetTimerEx("Player_CharSelectCamera", 200, false, "i", playerid);
    return 1;
}

Player_DealershipGiveVehicle(playerid, modelid, dealershipid){
    Vehicle_Create(modelid, Player_DBID(playerid), gBusinessData[dealershipid][bCarSpawnX], gBusinessData[dealershipid][bCarSpawnY], gBusinessData[dealershipid][bCarSpawnZ], gBusinessData[dealershipid][bCarSpawnR],
     1, 1, Vehicle_GeneratePlate(), Vehicle_GetTankSize(modelid));
}

Player_ShowVehicles(playerid, ownerid){
    new szTemp[128];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `id_vehicle`, `model`, `plate`, `gps`, `mileage`, `destroyed` from `vehicle` where `id_character` = '%d'", Player_DBID(ownerid));
    new 
        Cache:result = mysql_query(hSQL, szTemp),
        index = 0,
        rows = cache_num_rows();

    while(index < rows){
        new 
            vehicleid,
            model,
            plate[32],
            gps,
            Float: mileage,
            rightMileage,
            destroyed,
            szTemp2[128];

        vehicleid = cache_get_field_content_int(index, "id_vehicle", hSQL);
        model = cache_get_field_content_int(index, "model", hSQL);
        cache_get_field_content(index, "plate", plate, hSQL, 32);
        gps = cache_get_field_content_int(index, "gps", hSQL);
        mileage = cache_get_field_content_float(index, "mileage", hSQL);
        destroyed = cache_get_field_content_int(index, "destroyed", hSQL);

        new scriptID = Vehicle_GetScriptIDFromSql(vehicleid);

        if(scriptID != -1 && gVehicleData[scriptID][vSpawned] == 1){
            rightMileage = floatround((gVehicleData[scriptID][vMileage]/2000), floatround_floor);

            format(szTemp2, sizeof(szTemp2), "[%d] %s | Placa: [%s] | Quilometragem: %d KM", gVehicleData[scriptID][vID], GetVehicleName(model), plate, rightMileage);
            if(gps == 1){
                new 
                    pos[50],                
                    zone[MAX_ZONE_NAME];
                GetVehicle2DZone(gVehicleData[scriptID][vID], zone, MAX_ZONE_NAME);
                format(pos, sizeof(pos), " | Localização: %s", zone);
                strcat(szTemp2, pos);
            }
            SendClientMessage(playerid, C_COLOR_SUCCESS, szTemp2);

        } else if(destroyed == 1){
            rightMileage = floatround((mileage/2000), floatround_floor);

            format(szTemp2, sizeof(szTemp2), "[%d] %s | Placa: [%s] | Quilometragem: %d KM", vehicleid, GetVehicleName(model), plate, rightMileage);
            SendClientMessage(playerid, C_COLOR_ERROR, szTemp2);

        } else {
            rightMileage = floatround((mileage/2000), floatround_floor);

            format(szTemp2, sizeof(szTemp2), "[%d] %s | Placa: [%s] | Quilometragem: %d KM", vehicleid, GetVehicleName(model), plate, rightMileage);
            SendClientMessage(playerid, C_COLOR_ADMOFF, szTemp2);

        }

        index++;
    }

    cache_delete(result);

    return 1;
}

Player_SayToVehicle(playerid, szTalk[]){
    new vehicleid = GetPlayerVehicleID(playerid);
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(IsPlayerInVehicle(i, vehicleid)){
            Player_SendLongMsg(i, C_COLOR_CHATFADE1, szTalk);            
        }
    }
    return 1;
}

Player_ResetTimers(playerid){
    if(MileageTimer[playerid] != 0){
        KillTimer(MileageTimer[playerid]);
        MileageTimer[playerid] = 0;
    }

    if(RefuelingTimer[playerid] != 0){
        KillTimer(RefuelingTimer[playerid]);
        RefuelingTimer[playerid] = 0;
    }

    if(HotwireTimer[playerid] != 0){
        KillTimer(HotwireTimer[playerid]);
        HotwireTimer[playerid] = 0;
    }
    if(CellRingTimer[playerid] != 0){
        KillTimer(CellRingTimer[playerid]);
        CellRingTimer[playerid] = 0;
    }
    return 1;
}

Player_ShowInsuranceList(playerid){
    new temp[230];

    mysql_format(hSQL, temp, sizeof(temp), "select vehicle.id_vehicle, vehicle.model, vehicle_model_info.price from `vehicle` inner join `vehicle_model_info` on vehicle.model = vehicle_model_info.model \
        where `id_character` = '%d' and `destroyed` = 1", Player_DBID(playerid));
    new Cache:result = mysql_query(hSQL, temp);

    new 
        rows = cache_num_rows();

    if(cache_num_rows() != 0){                
        new
            index = 0,
            szVehicles[512];

        while(index < rows){
            new 
                szAux[128],
                vehicleid,
                model,
                price,
                Float:recoverPrice,
                intPrice;         
            
            vehicleid = cache_get_field_content_int(index, "id_vehicle", hSQL);
            model = cache_get_field_content_int(index, "model", hSQL);
            price = cache_get_field_content_int(index, "price", hSQL);

            recoverPrice = price*0.10;
            intPrice = floatround(recoverPrice, floatround_floor);

            format(szAux, sizeof(szAux), "[ID %d] %s ({009B19}$%d{FFFFFF})%s", vehicleid, GetVehicleName(model), intPrice, rows-index==1 ? ("") : ("\n"));         
            strcat(szVehicles, szAux);
            index++;
        }
        ShowPlayerDialog(playerid, DIALOG_INSURANCERECOVER, DIALOG_STYLE_LIST, "Lista de Veículos Destruídos", szVehicles, "Recuperar", "Sair");

    } else {
        SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Você não possui nenhum veículo destruído!");
    }    

    cache_delete(result);
    return 1;
}

function Player_CharSelectCamera(playerid){
    SetPlayerCameraPos(playerid, CHARCAMERAX, CHARCAMERAY, CHARCAMERAZ);
    SetPlayerCameraLookAt(playerid, CHARCAMERALOOKX, CHARCAMERALOOKY, CHARCAMERALOOKZ);
    return 1;
}

Player_ShowHouseList(playerid){
    new 
        szAux[30],
        szHouses[512],
        ownedHouses = Player_GetHousesOwned(playerid),
        count = 0;

    for(new i = 1; i < C_MAX_HOUSES; i++){
        if(gHouseData[i][hOwner] == Player_DBID(playerid)){
            count++;
            format(szAux, sizeof(szAux), "Casa ID %d%s", i, count-ownedHouses==0 ? ("") : ("\n"));
            strcat(szHouses, szAux);    
        }    
    }

    if(count == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui nenhuma casa.");

    ShowPlayerDialog(playerid, DIALOG_HOUSES, DIALOG_STYLE_LIST, "Selecione uma Casa", szHouses, "Selecionar", "Voltar");
    return 1;
}

Player_ShowBusinessList(playerid){
    new 
        szAux[30],
        szBusinesses[512],
        ownedBusinesses = Player_GetBusinessesOwned(playerid),
        count = 0;

    for(new i = 1; i < C_MAX_BUSINESSES; i++){
        if(gBusinessData[i][bOwner] == Player_DBID(playerid)){
            count++;
            format(szAux, sizeof(szAux), "Empresa ID %d%s", i, count-ownedBusinesses==0 ? ("") : ("\n"));
            strcat(szBusinesses, szAux); 
        }    
    }

    if(count == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui nenhuma empresa.");

    ShowPlayerDialog(playerid, DIALOG_BUSINESSES, DIALOG_STYLE_LIST, "Selecione uma Empresa", szBusinesses, "Selecionar", "Voltar");

    return 1;
}

Player_GetHousesOwned(playerid){
    new count = 0;
    for(new i = 0; i < C_MAX_HOUSES; i++){
        if(gHouseData[i][hOwner] == Player_DBID(playerid))
            count ++;
    }
    return count;
}

Player_GetBusinessesOwned(playerid){
    new count = 0;
    for(new i = 0; i < C_MAX_BUSINESSES; i++){
        if(gBusinessData[i][bOwner] == Player_DBID(playerid))
            count ++;
    }
    return count;
}

Player_IsDead(playerid){
    if(gPlayerData[playerid][pDeath] > 0)
        return 1;

    return 0;
}

Player_GetNearestHospital(playerid, &Float: x, &Float: y, &Float: z, &Float: r){
    new
        nearest = 0,
        Float:dist,
        houseid = gPlayerData[playerid][pInsideHouse],
        businessid = gPlayerData[playerid][pInsideBusiness],
        type;

    if(houseid != -1){                        
        dist = GetDistance(gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ],
         HospitalPositions[0][hospPosX], HospitalPositions[0][hospPosY], HospitalPositions[0][hospPosZ]);
        type = 1;
    } else if(businessid != -1){
        dist = GetDistance(gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ],
         HospitalPositions[0][hospPosX], HospitalPositions[0][hospPosY], HospitalPositions[0][hospPosZ]);
        type = 2;
    } else{
        dist = GetPlayerDistanceFromPoint(playerid, HospitalPositions[0][hospPosX], HospitalPositions[0][hospPosY], HospitalPositions[0][hospPosZ]);
        type = 3;
    }

    for(new i = 0; i < sizeof(HospitalPositions); i++){
        new 
            Float:aux;

        switch(type){
            case 1: aux = GetDistance(gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ],
             HospitalPositions[i][hospPosX], HospitalPositions[i][hospPosY], HospitalPositions[i][hospPosZ]);
            case 2: aux = GetDistance(gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ],
                HospitalPositions[i][hospPosX], HospitalPositions[i][hospPosY], HospitalPositions[i][hospPosZ]);
            case 3: aux = GetPlayerDistanceFromPoint(playerid, HospitalPositions[i][hospPosX], HospitalPositions[i][hospPosY], HospitalPositions[i][hospPosZ]);
        }

        if(aux < dist){
            dist = aux;
            nearest = i;
        }
    }
    x = HospitalPositions[nearest][hospPosX];
    y = HospitalPositions[nearest][hospPosY];
    z = HospitalPositions[nearest][hospPosZ];
    r = HospitalPositions[nearest][hospPosR];
    return 1;    
}

function Player_SpawnInHospital(playerid){
    new
        Float:x,
        Float:y,
        Float:z,
        Float:r;
    Player_GetNearestHospital(playerid, x, y, z, r);
    Player_SetPosition(playerid, x, y, z, r);    

    SetPlayerHealth(playerid, 100.0);
    TogglePlayerControllable(playerid, 1);
    ClearAnimations(playerid);
    TextDrawHideForPlayer(playerid, blackScreen);
    Delete3DTextLabel(gPlayerData[playerid][pDeadText]);
    gPlayerData[playerid][pDeadText] = Text3D:INVALID_3DTEXT_ID;
    gPlayerData[playerid][pInsideHouse] = -1;
    gPlayerData[playerid][pInsideBusiness] = -1;
    Player_ResetSpawnInfo(playerid);
    gPlayerData[playerid][pDeath] = 0;    
    return 1;
}

Player_ResetSpawnInfo(playerid){
    switch(gPlayerData[playerid][pSpawnLoc]){
        case SPAWN_CIVILIAN:{
            gPlayerData[playerid][pSpawnX] = DEFAULTSPAWNX;
            gPlayerData[playerid][pSpawnY] = DEFAULTSPAWNY;
            gPlayerData[playerid][pSpawnZ] = DEFAULTSPAWNZ;
            gPlayerData[playerid][pSpawnR] = DEFAULTSPAWNR;            
        }
        case SPAWN_FACTION:{
            gPlayerData[playerid][pSpawnX] = gFactionData[Player_GetFactionID(playerid)][fSpawnX];
            gPlayerData[playerid][pSpawnY] = gFactionData[Player_GetFactionID(playerid)][fSpawnY];
            gPlayerData[playerid][pSpawnZ] = gFactionData[Player_GetFactionID(playerid)][fSpawnZ];
            gPlayerData[playerid][pSpawnR] = gFactionData[Player_GetFactionID(playerid)][fSpawnR];
        }
        case SPAWN_HOUSE:{
            new houseid = gPlayerData[playerid][pPropertySpawn];
            gPlayerData[playerid][pSpawnX] = gHouseData[houseid][hInteriorX];
            gPlayerData[playerid][pSpawnY] = gHouseData[houseid][hInteriorX];
            gPlayerData[playerid][pSpawnZ] = gHouseData[houseid][hInteriorX];
            gPlayerData[playerid][pSpawnR] = gHouseData[houseid][hInteriorX];
            gPlayerData[playerid][pInterior] = gHouseData[houseid][hInt];
            gPlayerData[playerid][pVW] = gHouseData[houseid][hVW];
            gPlayerData[playerid][pInsideHouse] = houseid;
        }
        case SPAWN_BUSINESS:{
            new businessid = gPlayerData[playerid][pPropertySpawn];
            gPlayerData[playerid][pSpawnX] = gBusinessData[businessid][bInteriorX];
            gPlayerData[playerid][pSpawnY] = gBusinessData[businessid][bInteriorX];
            gPlayerData[playerid][pSpawnZ] = gBusinessData[businessid][bInteriorX];
            gPlayerData[playerid][pSpawnR] = gBusinessData[businessid][bInteriorX];
            gPlayerData[playerid][pInterior] = gBusinessData[businessid][bInt];
            gPlayerData[playerid][pVW] = gBusinessData[businessid][bVW];
            gPlayerData[playerid][pInsideBusiness] = businessid;    
        }
    } 
    return 1;
}

Player_ResetShotInfo(playerid){
    for(new i = 0; i < 11; i++){
        gShotData[playerid][sTorso][i] = 0;
        gShotData[playerid][sChest][i] = 0;
        gShotData[playerid][sLeftArm][i] = 0;
        gShotData[playerid][sRightArm][i] = 0;
        gShotData[playerid][sLeftLeg][i] = 0;
        gShotData[playerid][sRightLeg][i] = 0;
        gShotData[playerid][sHead][i] = 0;
    }
    return 1;
}

Player_GiveWeapon(playerid, weaponid, ammo){
    Anticheat_SetDelay(playerid, 5);

    new slot = GetWeaponSlot(weaponid);
    gPlayerData[playerid][pWeapon][slot] = weaponid;
    gPlayerData[playerid][pAmmo][slot] = ammo;
    GivePlayerWeapon(playerid, weaponid, ammo);    
    return 1;    
}

Player_RemoveWeapon(playerid, weaponid){
    Anticheat_SetDelay(playerid, 5);

    new 
        plyWeapons[12],
        plyAmmo[12];

    for(new slot = 0; slot != 12; slot++){
        new 
            wep,
            ammo;
        GetPlayerWeaponData(playerid, slot, wep, ammo);
        
        if(wep != weaponid)
            GetPlayerWeaponData(playerid, slot, plyWeapons[slot], plyAmmo[slot]);
    }

    Player_ResetWeapons(playerid);
    for(new slot = 0; slot != 12; slot++){
        Player_GiveWeapon(playerid, plyWeapons[slot], plyAmmo[slot]);
    }
    return 1;
}

Player_ResetWeapons(playerid){
    Anticheat_SetDelay(playerid, 5);

    for(new i = 0; i < 12; i++){
        gPlayerData[playerid][pWeapon][i] = 0;
        gPlayerData[playerid][pAmmo][i] = 0;        
    }
    ResetPlayerWeapons(playerid);
    return 1;
}

Player_ShowPlayerHelp(playerid){
    SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos Gerais]______________________________");
    SendClientMessage(playerid, C_COLOR_WHITE, "/b, /(g)ritar, /baixo, /(s)ussurrar, /me, /do, /ame, /ado, /pagar, /pm, /admins, /aceitar, /criarcena");
    SendClientMessage(playerid, C_COLOR_WHITE, "/deletarcena, /comprarcasa, /comprarempresa, /vender, /entrar, /sair, /mudarspawn");
    SendClientMessage(playerid, C_COLOR_WHITE, "/logout, /cancelarlogout, /trancar, /aceitarmorte, /checarferimentos");
    return 1;
}

//------------------------------------------------------------------------------

//Hooks
hook OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart){
    if(issuerid != INVALID_PLAYER_ID){
        new
            hitType;
        switch(weaponid){
            case 0 .. WEAPON_CANE:{
                hitType = HIT_TYPE_MELEE;
            }
            case WEAPON_COLT45, WEAPON_SILENCED:{
                hitType = HIT_TYPE_NINEMM;
            }
            case WEAPON_DEAGLE:{
                hitType = HIT_TYPE_DEAGLE;
            }
            case WEAPON_SHOTGUN .. WEAPON_SHOTGSPA:{
                hitType = HIT_TYPE_SHOTGUN;
            }
            case WEAPON_UZI, WEAPON_TEC9:{
                hitType = HIT_TYPE_MSMG;
            }
            case WEAPON_MP5:{
                hitType = HIT_TYPE_SMG;
            }
            case WEAPON_AK47:{
                hitType = HIT_TYPE_AK47;
            }
            case WEAPON_M4:{
                hitType = HIT_TYPE_M4;
            }
            case WEAPON_RIFLE:{
                hitType = HIT_TYPE_RIFLE;
            }
            case WEAPON_SNIPER:{
                hitType = HIT_TYPE_SNIPER;
            }
            default:{
                hitType = HIT_TYPE_MISC;
            }
        }

        switch(bodypart){
            case BODY_PART_TORSO: gShotData[playerid][sTorso][hitType]++;
            case BODY_PART_CHEST: gShotData[playerid][sChest][hitType]++;
            case BODY_PART_LEFT_ARM: gShotData[playerid][sLeftArm][hitType]++;
            case BODY_PART_RIGHT_ARM: gShotData[playerid][sRightArm][hitType]++;
            case BODY_PART_LEFT_LEG: gShotData[playerid][sLeftLeg][hitType]++;
            case BODY_PART_RIGHT_LEG: gShotData[playerid][sRightLeg][hitType]++;
            case BODY_PART_HEAD: gShotData[playerid][sHead][hitType]++;
        }
    }
    return 1;
}

hook OnPlayerDeath(playerid, killerid, reason){
    new logstr[128];

    if(killerid != 65535){        
        format(logstr, sizeof(logstr), "[Morte] O jogador %d matou o jogador %d. Arma: %d.", Player_DBID(killerid), Player_DBID(playerid), reason);
        Server_Log(killerid, playerid, LOG_DEATH, logstr);
    } else {
        format(logstr, sizeof(logstr), "[Morte] O jogador %d suicidou-se.", Player_DBID(playerid));
        Server_Log(playerid, -1, LOG_DEATH, logstr);    
    }

    GetPlayerPos(playerid, gPlayerData[playerid][pSpawnX], gPlayerData[playerid][pSpawnY], gPlayerData[playerid][pSpawnZ]);
    gPlayerData[playerid][pDeath] ++;
    gPlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
    gPlayerData[playerid][pVW] = GetPlayerVirtualWorld(playerid);
    Cellphone_FinishCall(playerid);
    return 1;
}

hook OnPlayerDisconnect(playerid, reason){

    gPlayerData[playerid][pLeaveReason] = reason;
    if(reason == 0 || Player_IsDead(playerid)){
        GetPlayerPos(playerid, gPlayerData[playerid][pSpawnX], gPlayerData[playerid][pSpawnY], gPlayerData[playerid][pSpawnZ]);
        GetPlayerFacingAngle(playerid, gPlayerData[playerid][pSpawnR]);
        gPlayerData[playerid][pInterior] = GetPlayerInterior(playerid);
        gPlayerData[playerid][pVW] = GetPlayerVirtualWorld(playerid);
    } else {
        gPlayerData[playerid][pInsideHouse] = -1;
        gPlayerData[playerid][pInsideBusiness] = -1;
        gPlayerData[playerid][pInterior] = 0;
        gPlayerData[playerid][pVW] = 0;
    }

    if(gPlayerData[playerid][pScene] != Text3D:INVALID_3DTEXT_ID){
        Delete3DTextLabel(gPlayerData[playerid][pScene]);
    }
    if(gPlayerData[playerid][pDeadText] != Text3D:INVALID_3DTEXT_ID){
        Delete3DTextLabel(gPlayerData[playerid][pDeadText]);
    }

    Cellphone_FinishCall(playerid);
    Player_ResetTimers(playerid);
    Player_CharacterSave(playerid);

    new logstr[128];
    format(logstr, sizeof(logstr), "[Login] O jogador %d se desconectou do servidor. Motivo: (%d)", Player_DBID(playerid), reason);
    Server_Log(playerid, -1, LOG_LOGIN, logstr);

    Player_ResetCharacterVariables(playerid);
    Player_ResetAccountVariables(playerid);

    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    switch(dialogid){
        case DIALOG_LOGIN:{
            if(!response){
                SendClientMessage(playerid, C_COLOR_WHITE, "Você optou por sair do servidor. Até mais!");
                Player_Kick(playerid);
                return 1;
            }
            Player_Authenticate(playerid, inputtext);
        }        
        case DIALOG_CHARACTERS:{
            if(!response){
                SendClientMessage(playerid, C_COLOR_WHITE, "Você optou por sair do servidor. Até mais!");
                Player_Kick(playerid);
                return 1;
            }    

            new characters = Player_GetCharacterCount(playerid);

            if(listitem < characters){   
                new temp[128];             
                mysql_format(hSQL, temp, sizeof(temp), "select id_character from `character` where `id_account` = '%d' limit %d,1", gAccountData[playerid][aSQLID], listitem);
                new 
                    Cache:result = mysql_query(hSQL, temp),            
                    character = cache_get_field_content_int(0, "id_character", hSQL);
                cache_delete(result);

                Player_CharacterLoad(playerid, character);
            } else if(listitem == characters){
                Player_ShowCharacterList(playerid);
            } else if(listitem-characters == 1){
                SendClientMessage(playerid, C_COLOR_LIGHTGREY, "Função não implementada.");
                Player_ShowCharacterList(playerid);
            }
            return 1;
        }        
        case DIALOG_CHOOSESPAWN:{
            if(!response){
                return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você cancelou a alteração do seu local de spawn.");
            }
            switch(listitem){
                case 0:{ //Civil
                    gPlayerData[playerid][pSpawnLoc] = SPAWN_CIVILIAN;
                    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você agora spawnará no spawn civil.");
                }
                case 1:{ //Facção
                    if(Player_GetFactionID(playerid) == 0)
                        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é de nenhuma facção.");
                    gPlayerData[playerid][pSpawnLoc] = SPAWN_FACTION;
                    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você agora spawnará no spawn da sua facção.");
                }
                case 2:{ //Casa
                    Player_ShowHouseList(playerid);                    
                }
                case 3:{ //Empresa
                    Player_ShowBusinessList(playerid);    
                }
            }
        }
        case DIALOG_HOUSES:{
            if(!response)
                return cmd_mudarspawn(playerid, "");

            new 
                aux = -1,
                houseid;

            for(new i = 1; i < C_MAX_HOUSES; i++){
                if(gHouseData[i][hOwner] == Player_DBID(playerid)){
                    aux ++;
                    if(aux == listitem){
                        houseid = i;
                        break;
                    }
                }    
            }     

            gPlayerData[playerid][pSpawnLoc] = SPAWN_HOUSE;
            gPlayerData[playerid][pPropertySpawn] = houseid;
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você agora spawnará nesta casa.");
        }
        case DIALOG_BUSINESSES:{
            if(!response)
                return cmd_mudarspawn(playerid, "");

            new 
                aux = -1,
                businessid;

            for(new i = 1; i < C_MAX_BUSINESSES; i++){
                if(gBusinessData[i][bOwner] == Player_DBID(playerid)){
                    aux ++;
                    if(aux == listitem){
                        businessid = i;
                        break;
                    }
                }    
            }     

            gPlayerData[playerid][pSpawnLoc] = SPAWN_BUSINESS;
            gPlayerData[playerid][pPropertySpawn] = businessid;
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você agora spawnará nesta empresa.");
        }
    }
    return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
    new
        vehID = Vehicle_GetScriptID(vehicleid),
        vehFaction = Vehicle_GetFactionID(vehID),
        vehJob = Vehicle_GetJobID(vehID);

    if(ispassenger == 0){
        if(vehFaction != 0 && vehFaction != Player_GetFactionID(playerid)){
            new
                Float:x,
                Float:y,
                Float:z;

            GetPlayerPos(playerid, x, y, z);            
            SetPlayerPos(playerid, x, y, z+0.5);        
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode entrar neste veículo. (Facção)");
        }
        else if(vehJob != 0 && vehJob != Player_GetJobID(playerid)){
            new
                Float:x,
                Float:y,
                Float:z;

            GetPlayerPos(playerid, x, y, z);            
            SetPlayerPos(playerid, x, y, z+0.5);        
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode entrar neste veículo. (Emprego)");
        }
    }
    return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate){
    if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT){ //Jogador saiu do veículo (como motorista)
        if(MileageTimer[playerid] != 0){
            KillTimer(MileageTimer[playerid]);
            MileageTimer[playerid] = 0;
        }
        if(RefuelingTimer[playerid] != 0){
            Vehicle_FinishRefuel(playerid, gPlayerData[playerid][pVehRefueling], gPlayerData[playerid][pBusinessRefueling], gPlayerData[playerid][pRefuelingType]);
        }
    } else if(oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER){ //Jogador entrou de motorista no veículo
        if(Vehicle_UsesFuel(GetVehicleModel(GetPlayerVehicleID(playerid))))
            MileageTimer[playerid] = SetTimerEx("Vehicle_MileageIncreaser", 1000, true, "i", playerid);
    }
    return 1;
}

function Player_OnPlayerModelSelection(playerid, response, listid, modelid){
    if(listid == boat_dealer_list || listid == plane_dealer_list || listid == motorcycle_dealer_list || listid == industry_dealer_list || listid == low_dealer_list || listid == medium_dealer_list || listid == high_dealer_list){
        if(response){
            new szCarInfo[300],
                price = Vehicle_GetDealershipPrice(modelid),
                tank = Vehicle_GetTankSize(modelid),
                trunk = Vehicle_GetTrunkSize(modelid),
                fuelType[26],
                economy = Vehicle_GetFuelEconomy(modelid);

            format(fuelType, sizeof(fuelType), "%s", Vehicle_GetFuelTypeString(modelid));

            format(szCarInfo, sizeof(szCarInfo), "Nome: {FFFFFF}%s\n{A9C4E4}Preço: {009B19}${FFFFFF}%d\n{A9C4E4}Capacidade do Tanque: {FFFFFF}%d Litros\n{A9C4E4}Porta-Malas: {FFFFFF}%d Litros\n\
                {A9C4E4}Tipo de Combustível: {FFFFFF}%s\n{A9C4E4}Autonomia: {FFFFFF}%d km/L",
                GetVehicleName(modelid), price, tank, trunk, fuelType, economy);

            SetPVarInt(playerid, "carModelBuying", modelid);
            SetPVarInt(playerid, "carPriceBuying", price);
        
            ShowPlayerDialog(playerid, DIALOG_CARBUY, DIALOG_STYLE_MSGBOX, "Informações do Veículo", szCarInfo, "Comprar", "Voltar");
        }
    }
    return 1;
}

hook OnPlayerSpawn(playerid){
    SetPlayerInterior(playerid, gPlayerData[playerid][pInterior]);
    SetPlayerVirtualWorld(playerid, gPlayerData[playerid][pVW]);

    if(Player_IsDead(playerid)){
        if(gPlayerData[playerid][pDeath] == 1){
            Player_SetPosition(playerid, gPlayerData[playerid][pSpawnX], gPlayerData[playerid][pSpawnY], gPlayerData[playerid][pSpawnZ], 0.0, gPlayerData[playerid][pInterior], gPlayerData[playerid][pVW]);
            SetPlayerSkin(playerid, gPlayerData[playerid][pSkin]);
            SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você está brutalmente ferido. Aguarde por socorro médico ou digite /aceitarmorte após 1 minuto.");
            TogglePlayerControllable(playerid, 0);
            ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 1, 1);
            SetPlayerHealth(playerid, 25.0);
            SetPlayerCameraPos(playerid,gPlayerData[playerid][pSpawnX]+3,gPlayerData[playerid][pSpawnY]+3,gPlayerData[playerid][pSpawnZ] +3);
            SetPlayerCameraLookAt(playerid,gPlayerData[playerid][pSpawnX],gPlayerData[playerid][pSpawnY],gPlayerData[playerid][pSpawnZ]);

            SetPVarInt(playerid, "DeathDelay", gettime());       
        }
        else if(gPlayerData[playerid][pDeath] >= 2){            
            SetPlayerSkin(playerid, gPlayerData[playerid][pSkin]);            
            DeletePVar(playerid, "DeathDelay");
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Você não resistiu aos ferimentos e morreu.");
            SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Aguarde 10 segundos para spawnar no hospital mais próximo.");
            SetPlayerHealth(playerid, 25.0);
            Player_ResetShotInfo(playerid);
            Player_SetPosition(playerid, gPlayerData[playerid][pSpawnX], gPlayerData[playerid][pSpawnY], gPlayerData[playerid][pSpawnZ], 0.0, gPlayerData[playerid][pInterior], gPlayerData[playerid][pVW]);
            ApplyAnimation(playerid, "WUZI", "CS_Dead_Guy", 4.1, 0, 1, 1, 1, 1, 1);
            
            TextDrawShowForPlayer(playerid, blackScreen);
            TogglePlayerControllable(playerid, 0);
            gPlayerData[playerid][pDeadText] = Create3DTextLabel("((Este jogador está morto))", C_COLOR_DEADTEXT, 0.0, 0.0, 0.0, 10.0, GetPlayerVirtualWorld(playerid), 1);
            Attach3DTextLabelToPlayer(gPlayerData[playerid][pDeadText], playerid, 0.0, 0.0, 0.3);
           
            SetTimerEx("Player_SpawnInHospital", 10000, false, "i", playerid);        
        }
    } else if(gPlayerData[playerid][pLeaveReason] == 0){
        Player_ResetSpawnInfo(playerid);
    }
    return 1;
}

hook OnPlayerText(playerid, text[]){
    if(!Player_Logged(playerid)){
        SendClientMessage(playerid, C_COLOR_ERROR, NOT_LOGGED);
        return 0;
    }
    new 
        szTalk[144],
        vehicleid = GetPlayerVehicleID(playerid);

    if(Cellphone_IsInCall(playerid)){        
        format(szTalk, sizeof (szTalk), "(Celular) %s diz: %s", Player_GetRPName(playerid, false), text);
        Player_SendLongMsg(gPlayerData[playerid][pCellphoneCall], C_COLOR_PHONECALL, szTalk);
        format(szTalk, sizeof (szTalk), "(Celular) %s diz: %s", Player_GetRPName(playerid, false), text);
    } else {
        format(szTalk, sizeof (szTalk), "%s diz: %s", Player_GetRPName(playerid, false), text);
    }


    if(IsPlayerInAnyVehicle(playerid) && !Vehicle_DontHaveWindows(GetVehicleModel(vehicleid)) && !Vehicle_HasWindowDown(vehicleid)){ //Está em um carro com as janelas fechadas
        Player_SayToVehicle(playerid, szTalk);
    } else {
        ProxDetector(5.0, playerid, szTalk, C_COLOR_CHATFADE1, C_COLOR_CHATFADE2, C_COLOR_CHATFADE3, C_COLOR_CHATFADE4, C_COLOR_CHATFADE5);
    }

    new logstr[128];
    format(logstr, sizeof(logstr), "[CHAT] O jogador %d disse: %s", Player_DBID(playerid), text);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
    if(Pressed(KEY_SPRINT) && gPlayerData[playerid][pInTutorial] >= 1){
        Player_Tutorial(playerid, gPlayerData[playerid][pInTutorial]);
        return 1;
    }
    if(Pressed(KEY_HANDBRAKE) && RefuelingTimer[playerid] != 0){
        Vehicle_FinishRefuel(playerid, gPlayerData[playerid][pVehRefueling], gPlayerData[playerid][pBusinessRefueling], gPlayerData[playerid][pRefuelingType]);
        return 1;
    }
    return 1;
}

//------------------------------------------------------------------------------

//Comandos

CMD:ajuda(playerid, params[]){
    new szParam[30];

    if(sscanf(params, "s[30]", szParam)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ajuda [parâmetro] -{C0C0C0} Exibe os comandos de certa classe");
        SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETROS] geral, faccao, veiculo, celular, casa");
        if(Admin_GetLevel(playerid) > 0)
            SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETRO ESPECIAL] admin");
        if(Player_FactionRank(playerid) >= 3)
            SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETRO ESPECIAL] lider");
        return 1;
    }

    if(!strcmp(szParam, "geral", true)){
        Player_ShowPlayerHelp(playerid);
    }
    else if(!strcmp(szParam, "faccao", true)){
        Faction_ShowPlayerHelp(playerid, 1);
    }
    else if(!strcmp(szParam, "admin", true)){
        if(Admin_GetLevel(playerid) > 0)
            Admin_ShowPlayerHelp(playerid);
        else
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }
    else if(!strcmp(szParam, "lider", true)){
        if(Player_FactionRank(playerid) >= 3)
            Faction_ShowPlayerHelp(playerid, 2);
        else
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }
    else if(!strcmp(szParam, "veiculo", true)){
        Vehicle_ShowPlayerHelp(playerid);
    }
    else if(!strcmp(szParam, "celular", true)){
        Cellphone_ShowCellphoneHelp(playerid);
    }
    else if(!strcmp(szParam, "casa", true)){
        House_ShowPlayerHelp(playerid);
    }
    else {
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }
    return 1;
}

CMD:b(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /b [Mensagem] -{C0C0C0} Envia uma mensagem em área no modo OOC");

    new szOOC[128];
    format(szOOC, sizeof(szOOC), "(( [%d] %s diz: %s ))", playerid, Player_GetRPName(playerid, true), szText);
    ProxDetector(5.0, playerid, szOOC, C_COLOR_OOCCHAT, C_COLOR_OOCCHAT, C_COLOR_OOCCHAT, C_COLOR_OOCCHAT, C_COLOR_OOCCHAT);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/b] O jogador %d disse: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:gritar(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /gritar [Mensagem] -{C0C0C0} Envia um grito no modo IC");

    new szScream[128];
    format(szScream, sizeof(szScream), "%s grita: %s", Player_GetRPName(playerid, false), szText);
    ProxDetector(15.0, playerid, szScream, C_COLOR_CHATFADE1, C_COLOR_CHATFADE2, C_COLOR_CHATFADE3, C_COLOR_CHATFADE4, C_COLOR_CHATFADE5);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/gritar] O jogador %d disse: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:g(playerid, params[]) return cmd_gritar(playerid,params);

CMD:baixo(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /baixo [Mensagem] -{C0C0C0} Envia uma mensagem baixa no modo IC");

    new 
        szLow[128],
        vehicleid = GetPlayerVehicleID(playerid);
    format(szLow, sizeof(szLow), "%s diz [baixo]: %s", Player_GetRPName(playerid, false), szText);    

    if(IsPlayerInAnyVehicle(playerid) && !Vehicle_DontHaveWindows(GetVehicleModel(vehicleid)) && !Vehicle_HasWindowDown(vehicleid)){ //Está em um carro com as janelas fechadas
        Player_SayToVehicle(playerid, szLow);
    } else {
        ProxDetector(3.0, playerid, szLow, C_COLOR_CHATFADE1, C_COLOR_CHATFADE2, C_COLOR_CHATFADE3, C_COLOR_CHATFADE4, C_COLOR_CHATFADE5);
    }

    new logstr[128];
    format(logstr, sizeof(logstr), "[/baixo] O jogador %d disse: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CHAT, logstr);

    return 1;
}

CMD:sussurrar(playerid, params[]){
    new
        target,
        szWhisper[128];

    if(sscanf(params, "us[128]", target, szWhisper))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /sussurrar [playerid] [mensagem] -{C0C0C0} Envia um sussurro à um jogador");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(playerid == target)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(!Player_IsNearPlayer(3.0, playerid, target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à este jogador.");

    new szToMessage[164];
    format(szToMessage, sizeof(szToMessage), "Sussurro de %s: %s", Player_GetRPName(playerid, false), szWhisper);
    Player_SendLongMsg(target, C_COLOR_WHISPER, szToMessage);
    format(szToMessage, sizeof(szToMessage), "Sussurro para %s: %s", Player_GetRPName(target, false), szWhisper);
    Player_SendLongMsg(playerid, C_COLOR_WHISPER, szToMessage);

    format(szToMessage, sizeof(szToMessage), "* %s sussurra algo para %s.", Player_GetRPName(playerid, false), Player_GetRPName(target, false));
    ProxDetectorAction(5.0, playerid, szToMessage, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/sussurrar] O jogador %d sussurrou para %d: %s", Player_DBID(playerid), Player_DBID(target), szWhisper);
    Server_Log(playerid, target, LOG_CHAT, logstr);

    return 1;
}

CMD:s(playerid, params[]) return cmd_sussurrar(playerid,params);

CMD:me(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /me [Ação] -{C0C0C0} Representa uma ação do seu personagem");

    new szAction[180];
    format(szAction, sizeof(szAction), "* %s %s", Player_GetRPName(playerid, false), szText);
    ProxDetectorAction(7.0, playerid, szAction, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/me] O jogador %d enviou a ação: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:eu(playerid, params[]) return cmd_me(playerid,params);

CMD:do(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /do [Informação] -{C0C0C0} Apresenta uma informação da cena");

    new szAction[164];
    format(szAction, sizeof(szAction), "* %s ((%s))", szText, Player_GetRPName(playerid, false));
    ProxDetector(7.0, playerid, szAction, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/do] O jogador %d enviou a ação: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:ame(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ame [Ação] -{C0C0C0} Representa uma ação do seu personagem com um chat flutuante sobre sua cabeça");

    new szAction[180];
    format(szAction, sizeof(szAction), "* %s %s", Player_GetRPName(playerid, false), szText);
    SetPlayerChatBubble(playerid, szAction, C_COLOR_ACTION, 100.0, 10000);

    format(szAction, sizeof(szAction), "> %s %s", Player_GetRPName(playerid, false), szText);
    Player_SendLongAction(playerid, C_COLOR_ACTION, szAction);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ame] O jogador %d enviou a ação: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CMD, logstr);
    return 1;
}

CMD:ado(playerid, params[]){
    new szText[128];

    if(sscanf(params, "s[128]", szText))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ado [Ação] -{C0C0C0} Apresenta uma informação da cena com um chat flutuante sobre sua cabeça");

    new szAction[180];
    format(szAction, sizeof(szAction), "* %s ((%s))", szText, Player_GetRPName(playerid, false));
    SetPlayerChatBubble(playerid, szAction, C_COLOR_ACTION, 100.0, 10000);

    format(szAction, sizeof(szAction), "> %s ((%s))", szText, Player_GetRPName(playerid, false));
    Player_SendLongMsg(playerid, C_COLOR_ACTION, szAction);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/ado] O jogador %d enviou a ação: %s", Player_DBID(playerid), szText);
    Server_Log(playerid, -1, LOG_CMD, logstr);
    return 1;
}

CMD:pagar(playerid, params[]){
    new
        target,
        amount,
        action[128];

    if(sscanf(params, "udS(default)[128]", target, amount, action))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /pagar [playerid] [quantia] [ação(opcional)] -{C0C0C0} Paga um jogador");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(playerid == target)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(!Player_IsNearPlayer(5.0, playerid, target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à este jogador.");
    if(Player_GetMoney(playerid) < amount)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui esta quantia.");
    if(amount < 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um valor acima de zero.");

    Player_GiveMoney(playerid, -amount);
    Player_GiveMoney(target, amount);

    new szAction[128];
    if(!strcmp(action, "default"))
        format(szAction, sizeof(szAction), "* %s retira $%d do bolso e entrega para %s.", Player_GetRPName(playerid, false), amount, Player_GetRPName(target, false));
    else
        format(szAction, sizeof(szAction), "* %s %s", Player_GetRPName(playerid, false), action);

    ProxDetectorAction(7.0, playerid, szAction, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/pagar] O jogador %d pagou para o jogador %d uma quantia de %d", Player_DBID(playerid), Player_DBID(target), amount);
    Server_Log(playerid, target, LOG_CMD, logstr);

    return 1;
}

CMD:pm(playerid, params[]){
    new
        target,
        szPrivate[128];

    if(sscanf(params, "us[128]", target, szPrivate))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /pm [playerid] [mensagem] -{C0C0C0} Envia uma mensagem privada à um jogador");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(playerid == target)
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_SELF);
    if(gPlayerData[target][pBlockPM])
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador está com as PMs bloqueadas.");

    new szToMessage[164];
    format(szToMessage, sizeof(szToMessage), "(( PM para %s(%d): %s ))", Player_GetRPName(target, true), target, szPrivate);
    Player_SendLongMsg(playerid, C_COLOR_PRIVATEMSGS, szToMessage);
    format(szToMessage, sizeof(szToMessage), "(( PM de %s(%d): %s ))", Player_GetRPName(playerid, true), playerid, szPrivate);
    Player_SendLongMsg(target, C_COLOR_PRIVATEMSGR, szToMessage);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/pm] O jogador %d enviou uma PM para %d: %s", Player_DBID(playerid), Player_DBID(target), szPrivate);
    Server_Log(playerid, target, LOG_CHAT, logstr);

    return 1;
}

CMD:admins(playerid, params[]){
    #pragma unused params
    
    SendClientMessage(playerid, C_COLOR_ADMOFF, "|________________[Administradores Online]________________|");
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(IsPlayerConnected(i)){
            if(gPlayerData[i][pAdmin] > 0){
                new szAdmTxt[70];
                if(gPlayerData[i][pAdmDuty]){
                    format(szAdmTxt, sizeof(szAdmTxt), "%s %s (%d) - Em Trabalho", Admin_GetRankName(i), Player_GetRPName(i, true), i);
                    SendClientMessage(playerid, C_COLOR_ADM, szAdmTxt);
                } else {
                    format(szAdmTxt, sizeof(szAdmTxt), "%s %s (%d) - Jogando", Admin_GetRankName(i), Player_GetRPName(i, true), i);
                    SendClientMessage(playerid, C_COLOR_ADMOFF, szAdmTxt);
                }
            }
        }
    }

    new logstr[128];
    format(logstr, sizeof(logstr), "[/admins] O jogador %d checou os administradores online.", Player_DBID(playerid));
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:aceitar(playerid, params[]){
    new szParam[30];

    if(sscanf(params, "s[30]", szParam)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /aceitar [parâmetro] -{C0C0C0} Aceita algo de algum jogador");
        return SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETROS] faccao, veiculo");
    }

    if(!strcmp(szParam, "faccao", true)){
        if(gPlayerData[playerid][pFactionInvite] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não foi convidado para nenhuma facção.");
        gPlayerData[playerid][pFaction] = gPlayerData[playerid][pFactionInvite];
        gPlayerData[playerid][pFactionRank] = 1;
        new szInvite[128];
        format(szInvite, sizeof(szInvite), "Você aceitou o convite e entrou para o(a) %s.", gFactionData[Player_GetFactionID(playerid)][fName]);
        SendClientMessage(playerid, C_COLOR_YELLOW, szInvite);
        gPlayerData[playerid][pFactionInvite] = 0;

        new logstr[128];
        format(logstr, sizeof(logstr), "[/aceitar] O jogador %d aceitou o convite para a facção %s.", Player_DBID(playerid), gFactionData[Player_GetFactionID(playerid)][fName]);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    } else if(!strcmp(szParam, "veiculo", true)){
        if(GetPVarInt(playerid, "SellingCarID") == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui nenhuma proposta de venda de veículo pendente.");

        if(!Player_IsNearPlayer(5.0, playerid, GetPVarInt(playerid, "playerSellingCar"))){
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo deste jogador");
            SendClientMessage(GetPVarInt(playerid, "playerSellingCar"), C_COLOR_ERROR, "[ERRO] O jogador tentou aceitar sua proposta mas não está perto de você.");
            DeletePVar(playerid, "playerSellingCar");
            DeletePVar(playerid, "SellingCarID");
            DeletePVar(playerid, "SellingCarPrice");
            return 1;
        }

        if(Player_GetMoney(playerid) < GetPVarInt(playerid, "SellingCarPrice")){
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro suficiente para comprar este veículo.");
            SendClientMessage(GetPVarInt(playerid, "playerSellingCar"), C_COLOR_ERROR, "[ERRO] O jogador tentou aceitar sua proposta mas não possui dinheiro suficiente.");
            DeletePVar(playerid, "playerSellingCar");
            DeletePVar(playerid, "SellingCarID");
            DeletePVar(playerid, "SellingCarPrice");
            return 1;
        }
        
        Player_GiveMoney(playerid, -GetPVarInt(playerid, "SellingCarPrice"));
        Player_GiveMoney(GetPVarInt(playerid, "playerSellingCar"), GetPVarInt(playerid, "SellingCarPrice"));
        new vehScriptID = Vehicle_GetScriptID(GetPVarInt(playerid, "SellingCarID"));

        gVehicleData[vehScriptID][vOwner] = Player_DBID(playerid);
        Vehicle_Save(vehScriptID);

        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você comprou este veículo com sucesso!");
        SendClientMessage(GetPVarInt(playerid, "playerSellingCar"), C_COLOR_SUCCESS, "[INFO] Você vendeu o seu veículo com sucesso!");        

        new logstr[128];
        format(logstr, sizeof(logstr), "[/aceitar] O jogador %d aceitou o carro ID %d do jogador %d por $%d.", Player_DBID(playerid), gVehicleData[vehScriptID][vSQLID], 
            Player_DBID(GetPVarInt(playerid, "playerSellingCar")), GetPVarInt(playerid, "SellingCarPrice"));
        Server_Log(playerid, GetPVarInt(playerid, "playerSellingCar"), LOG_CMD, logstr);

        DeletePVar(playerid, "playerSellingCar");
        DeletePVar(playerid, "SellingCarID");
        DeletePVar(playerid, "SellingCarPrice");
    }
    else {
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }

    return 1;
}

CMD:criarcena(playerid, params[]){
    new szScene[128];

    if(sscanf(params, "s[128]", szScene))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /criarcena [Texto] -{C0C0C0} Cria um texto flutuante com uma cena descritiva");

    if(gPlayerData[playerid][pScene] != Text3D:INVALID_3DTEXT_ID)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já possui uma cena criada, utilize /deletarcena.");
    new
        szCreatedScene[164],
        Float: x,
        Float: y,
        Float: z;

    GetPlayerPos(playerid, x, y, z);
    format(szCreatedScene, sizeof(szCreatedScene), "* %s *((%s))", szScene, Player_GetRPName(playerid, true));
    gPlayerData[playerid][pScene] = Create3DTextLabel(szCreatedScene, C_COLOR_ACTION, x, y, z+0.3, 15.0, GetPlayerVirtualWorld(playerid), 1);
    gPlayerData[playerid][pSceneCreated] = gettime();

    new logstr[128];
    format(logstr, sizeof(logstr), "[/criarcena] O jogador %d criou a cena: %s", Player_DBID(playerid), szScene);
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:deletarcena(playerid, params[]){
    #pragma unused params

    if(gPlayerData[playerid][pScene] == Text3D:INVALID_3DTEXT_ID)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui uma cena criada, utilize /criarcena.");

    Delete3DTextLabel(gPlayerData[playerid][pScene]);
    gPlayerData[playerid][pScene] = Text3D:INVALID_3DTEXT_ID;
    gPlayerData[playerid][pSceneCreated] = 0;

    new logstr[128];
    format(logstr, sizeof(logstr), "[/criarcena] O jogador %d deletou sua cena ativa.", Player_DBID(playerid));
    Server_Log(playerid, -1, LOG_CMD, logstr);

    return 1;
}

CMD:comprarcasa(playerid, params[]){
    #pragma unused params

    new houseid = Player_GetNearestHouse(playerid);

    if(houseid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma casa.");
    if(gHouseData[houseid][hOwner] != 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa já possui um dono.");
    if(gHouseData[houseid][hLevel] > Player_GetLevel(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui level suficiente para comprar esta casa.");
    if(gHouseData[houseid][hPrice] > Player_GetMoney(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro suficiente para comprar esta casa.");

    gHouseData[houseid][hOwner] = Player_DBID(playerid);
    Player_GiveMoney(playerid, -gHouseData[houseid][hPrice]);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você comprou esta casa! Digite /ajuda propriedade para mais informações.");
    House_RefreshIcon(houseid);
    House_Save(houseid);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/comprar] O jogador %d comprou a casa %d.", Player_DBID(playerid), gHouseData[houseid][hSQLID]);
    Server_Log(playerid, -1, LOG_CMD, logstr);
    return 1;
}

CMD:comprarempresa(playerid, params[]){
    #pragma unused params

    new businessid = Player_GetNearestBusiness(playerid);

    if(businessid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma empresa.");
    if(gBusinessData[businessid][bOwner] != 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa já possui um dono.");
    if(gBusinessData[businessid][bLevel] > Player_GetLevel(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui level suficiente para comprar esta empresa.");
    if(gBusinessData[businessid][bPrice] > Player_GetMoney(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro suficiente para comprar esta empresa.");

    gBusinessData[businessid][bOwner] = Player_DBID(playerid);
    Player_GiveMoney(playerid, -gBusinessData[businessid][bPrice]);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você comprou esta empresa! Digite /ajuda propriedade para mais informações.");
    Business_RefreshIcon(businessid);
    Business_Save(businessid);

    new logstr[128];
    format(logstr, sizeof(logstr), "[/comprar] O jogador %d comprou a empresa %d.", Player_DBID(playerid), gBusinessData[businessid][bSQLID]);
    Server_Log(playerid, -1, LOG_CMD, logstr);
    return 1;    
}

CMD:comprar(playerid, params[]){
    #pragma unused params

    new businessid = gPlayerData[playerid][pInsideBusiness];

    if(businessid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de uma empresa.");

    Business_ShowProducts(playerid, businessid);   
    return 1;
}

CMD:vender(playerid, params[]){
    new szParam[30];

    if(sscanf(params, "s[30]", szParam)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /vender [parâmetro] -{C0C0C0} Realiza a venda de algo");
        SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETROS] casa, empresa");
        return SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você receberá 75 por cento do preço original da propriedade. Este processo é irreversível.");
    }

    if(!strcmp(szParam, "casa", true)){
        new houseid = Player_GetNearestHouse(playerid);
        if(houseid == -1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma casa.");
        if(gHouseData[houseid][hOwner] != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa não é sua.");

        gHouseData[houseid][hOwner] = 0;

        if(gPlayerData[playerid][pSpawnLoc] == SPAWN_HOUSE && gPlayerData[playerid][pPropertySpawn] == houseid){
            gPlayerData[playerid][pPropertySpawn] = 0;   
            gPlayerData[playerid][pSpawnLoc] = SPAWN_CIVILIAN;            
        }
        new
            sellPrice = floatround(gHouseData[houseid][hPrice]*0.75, floatround_floor),
            szSold[64];

        Player_GiveMoney(playerid, sellPrice);
        format(szSold, sizeof(szSold), "[INFO] Você vendeu a sua casa por {FFFFFF}$%d{74BF75}!", sellPrice);
        SendClientMessage(playerid, C_COLOR_SUCCESS, szSold);
        House_RefreshIcon(houseid);
        House_Save(houseid);

        new logstr[128];
        format(logstr, sizeof(logstr), "[/vender] O jogador %d vendeu a casa %d por $%d.", Player_DBID(playerid), gHouseData[houseid][hSQLID], sellPrice);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    else if(!strcmp(szParam, "empresa", true)){
        new businessid = Player_GetNearestBusiness(playerid);
        if(businessid == -1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma empresa.");
        if(gBusinessData[businessid][bOwner] != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não é sua.");

        gBusinessData[businessid][bOwner] = 0;

        if(gPlayerData[playerid][pSpawnLoc] == SPAWN_BUSINESS && gPlayerData[playerid][pPropertySpawn] == businessid){
            gPlayerData[playerid][pPropertySpawn] = 0;   
            gPlayerData[playerid][pSpawnLoc] = SPAWN_CIVILIAN;            
        }
        new
            sellPrice = floatround(gBusinessData[businessid][bPrice]*0.75, floatround_floor),
            szSold[64];

        Player_GiveMoney(playerid, sellPrice);
        format(szSold, sizeof(szSold), "[INFO] Você vendeu a sua empresa por {FFFFFF}$%d{74BF75}!", sellPrice);
        SendClientMessage(playerid, C_COLOR_SUCCESS, szSold);
        Business_RefreshIcon(businessid);
        Business_Save(businessid);

        new logstr[128];
        format(logstr, sizeof(logstr), "[/vender] O jogador %d vendeu a empresa %d por $%d.", Player_DBID(playerid), gBusinessData[businessid][bSQLID], sellPrice);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    else {
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }

    return 1;
}

CMD:entrar(playerid, params[]){
    #pragma unused params

    new houseid = Player_GetNearestHouse(playerid);
    new businessid = Player_GetNearestBusiness(playerid);

    if(Player_IsDead(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_ALIVE);

    if(houseid == -1 && businessid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma entrada.");

    if(houseid != -1){

        if(gHouseData[houseid][hLocked] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa está trancada.");

        gPlayerData[playerid][pInsideHouse] = houseid;
        Player_SetPosition(playerid,
            gHouseData[houseid][hInteriorX],
            gHouseData[houseid][hInteriorY],
            gHouseData[houseid][hInteriorZ],
            gHouseData[houseid][hInteriorR],
            gHouseData[houseid][hInt],
            gHouseData[houseid][hVW],
            3000
        );
        new logstr[128];
        format(logstr, sizeof(logstr), "[/entrar] O jogador %d entrou na casa %d.", Player_DBID(playerid), gHouseData[houseid][hSQLID]);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    else if(businessid != -1){
        if(gBusinessData[businessid][bLocked] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa está trancada.");

        gPlayerData[playerid][pInsideBusiness] = businessid;
        Player_SetPosition(playerid,
            gBusinessData[businessid][bInteriorX],
            gBusinessData[businessid][bInteriorY],
            gBusinessData[businessid][bInteriorZ],
            gBusinessData[businessid][bInteriorR],
            gBusinessData[businessid][bInt],
            gBusinessData[businessid][bVW],
            3000
        );
        new logstr[128];
        format(logstr, sizeof(logstr), "[/entrar] O jogador %d entrou na empresa %d.", Player_DBID(playerid), gBusinessData[businessid][bSQLID]);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    return 1;
}

CMD:sair(playerid, params[]){
    #pragma unused params

    new houseid = gPlayerData[playerid][pInsideHouse];
    new businessid = gPlayerData[playerid][pInsideBusiness];

    if(houseid == -1 && businessid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a uma saída.");

    if(houseid != -1){
        if(!IsPlayerInRangeOfPoint(playerid, 2.0, gHouseData[houseid][hInteriorX], gHouseData[houseid][hInteriorY], gHouseData[houseid][hInteriorZ]))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à saída desta casa.");

        if(gHouseData[houseid][hLocked] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta casa está trancada.");

        gPlayerData[playerid][pInsideHouse] = -1;
        Player_SetPosition(playerid,
            gHouseData[houseid][hDoorX],
            gHouseData[houseid][hDoorY],
            gHouseData[houseid][hDoorZ],
            0.0,
            gHouseData[houseid][hIntDoor],
            gHouseData[houseid][hVWDoor]
        );

        new logstr[128];
        format(logstr, sizeof(logstr), "[/sair] O jogador %d saiu da casa %d.", Player_DBID(playerid), gHouseData[houseid][hSQLID]);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    else if(businessid != -1){
        if(!IsPlayerInRangeOfPoint(playerid, 2.0, gBusinessData[businessid][bInteriorX], gBusinessData[businessid][bInteriorY], gBusinessData[businessid][bInteriorZ]))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à saída desta empresa.");

        if(gBusinessData[businessid][bLocked] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa está trancada.");

        gPlayerData[playerid][pInsideBusiness] = -1;
        Player_SetPosition(playerid,
            gBusinessData[businessid][bDoorX],
            gBusinessData[businessid][bDoorY],
            gBusinessData[businessid][bDoorZ],
            0.0,
            gBusinessData[businessid][bIntDoor],
            gBusinessData[businessid][bVWDoor]
        );

        new logstr[128];
        format(logstr, sizeof(logstr), "[/sair] O jogador %d saiu da empresa %d.", Player_DBID(playerid), gBusinessData[businessid][bSQLID]);
        Server_Log(playerid, -1, LOG_CMD, logstr);
    }
    return 1;
}


CMD:logout(playerid, params[]){
    #pragma unused params
    if(Player_IsDead(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode deslogar enquanto estiver morto. (/aceitarmorte)");

    if(gPlayerData[playerid][pLogoutDelay] > 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já está em processo de logout.");
    gPlayerData[playerid][pLogoutDelay] = 1; //AUMENTAR PRA 15 DEPOIS
    SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você será enviado para a seleção de personagens em 15 segundos. Digite /cancelarlogout para cancelar.");
    TogglePlayerControllable(playerid, 0);
    gPlayerData[playerid][pLogoutTimer] = SetTimerEx("Player_PrepareLogout", 1000, true, "i", playerid);        
    return 1;
}

CMD:cancelarlogout(playerid, params[]){
    #pragma unused params

    if(gPlayerData[playerid][pLogoutDelay] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está em processo de logout.");

    KillTimer(gPlayerData[playerid][pLogoutTimer]);
    gPlayerData[playerid][pLogoutTimer] = 0;
    gPlayerData[playerid][pLogoutDelay] = 0;
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você cancelou o processo de logout com sucesso.");    
    TogglePlayerControllable(playerid, 1);
    return 1;
}

CMD:trancar(playerid, params[]){
    #pragma unused params

    new houseid = Player_GetNearestHouse(playerid);
    new businessid = Player_GetNearestBusiness(playerid);
    new vehicleid = Player_GetNearestVehicle(playerid);

    if(houseid == -1 && businessid == -1 && vehicleid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo a nada que possa trancar.");

    if(vehicleid != -1){
        new vehScriptID = Vehicle_GetScriptID(vehicleid);

        if(Vehicle_GetOwnerID(vehScriptID) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário deste veículo.");

        new
            engine,
            lights,
            alarm,
            doors,
            bonnet,
            boot,
            objective,
            szLock[32],
            Float: x,
            Float: y,
            Float: z;

        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        GetVehiclePos(vehicleid, x, y, z);

        if(gVehicleData[vehScriptID][vLocked] == 1){
            SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);
            gVehicleData[vehScriptID][vLocked] = 0;
            format(szLock, sizeof(szLock), "~g~%s Destrancado", GetVehicleName(GetVehicleModel(vehicleid)));
        } else {
            SetVehicleParamsEx(vehicleid, engine, lights, alarm, 1, bonnet, boot, objective);
            gVehicleData[vehScriptID][vLocked] = 1;
            format(szLock, sizeof(szLock), "~r~%s Trancado", GetVehicleName(GetVehicleModel(vehicleid)));           
        }  
        GameTextForPlayer(playerid, szLock, 1500, 3);  
        PlayerPlaySound(playerid, 1145, x, y, z);
    }
    else if(houseid != -1){
        if(House_GetOwnerID(houseid) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário desta casa.");

        if(gHouseData[houseid][hLocked] == 1){
            gHouseData[houseid][hLocked] = 0;
            GameTextForPlayer(playerid, "~g~Casa Destrancada", 1500, 3);            
        } else {
            gHouseData[houseid][hLocked] = 1;
            GameTextForPlayer(playerid, "~r~Casa Trancada", 1500, 3);
        } 
        PlayerPlaySound(playerid, 1145, gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ]);
    }
    else if(businessid != -1){
        if(Business_GetOwnerID(businessid) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário desta empresa.");

        if(gBusinessData[businessid][bLocked] == 1){
            gBusinessData[businessid][bLocked] = 0;
            GameTextForPlayer(playerid, "~g~Empresa Destrancada", 1500, 3);
        } else {
            gBusinessData[businessid][bLocked] = 1;
            GameTextForPlayer(playerid, "~r~Empresa Trancada", 1500, 3);
        } 
        PlayerPlaySound(playerid, 1145, gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ]);
    }
    return 1;
}

CMD:mudarspawn(playerid, params[]){
    #pragma unused params
    ShowPlayerDialog(playerid, DIALOG_CHOOSESPAWN, DIALOG_STYLE_LIST, "Escolha o seu local de Spawn", "Civil\nFacção\nCasa\nEmpresa", "Alterar", "Cancelar");
    return 1;
}

CMD:aceitarmorte(playerid, params[]){
    #pragma unused params
    if(!Player_IsDead(playerid) || gPlayerData[playerid][pDeath] == 2)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está brutalmente ferido.");

    new
        cooldown = gettime() - GetPVarInt(playerid, "DeathDelay");

    if(cooldown < 60){
        new
            szDelay[100];

        format(szDelay, sizeof(szDelay), "[ERRO] Você precisa esperar %d segundos antes de utilizar /aceitarmorte.", 60-(cooldown));
        return SendClientMessage(playerid, C_COLOR_ERROR, szDelay);
    }

    Player_GiveMoney(playerid, -500);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você aceitou morte e pagou $500 de despesas médicas.");
    SetPlayerHealth(playerid, 0);
    return 1;
}

CMD:checarferimentos(playerid, params[]){
    new
        target;

    if(sscanf(params, "u", target))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /checarferimentos [playerid] -{C0C0C0} Checa os ferimentos de um jogador");

    if(!IsPlayerConnected(target) || !Player_Logged(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, NOT_CONNECTED);
    if(!Player_IsNearPlayer(5.0, playerid, target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à este jogador.");
    if(!Player_IsDead(target))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não está brutalmente ferido.");

    new
        szWounds[1024],
        szAux[100];
    strcat(szWounds, "Parte do Corpo\tArma\tTiros\n");
    for(new i = 0; i < 11; i++){
        if(gShotData[target][sHead][i] > 0){
            format(szAux, sizeof(szAux), "CABEÇA\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sHead][i]);
            strcat(szWounds, szAux);
        }
        if(gShotData[target][sTorso][i] > 0){
            format(szAux, sizeof(szAux), "TORSO\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sTorso][i]);
            strcat(szWounds, szAux);
        }  
        if(gShotData[target][sChest][i] > 0){
            format(szAux, sizeof(szAux), "BARRIGA\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sChest][i]);
            strcat(szWounds, szAux);
        }
        if(gShotData[target][sLeftArm][i] > 0){
            format(szAux, sizeof(szAux), "BRAÇO ESQUERDO\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sLeftArm][i]);
            strcat(szWounds, szAux);
        }  
        if(gShotData[target][sRightArm][i] > 0){
            format(szAux, sizeof(szAux), "BRAÇO DIREITO\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sRightArm][i]);
            strcat(szWounds, szAux);
        }  
        if(gShotData[target][sLeftLeg][i] > 0){
            format(szAux, sizeof(szAux), "PERNA ESQUERDA\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sLeftLeg][i]);
            strcat(szWounds, szAux);
        }  
        if(gShotData[target][sRightLeg][i] > 0){
            format(szAux, sizeof(szAux), "PERNA DIREITA\t%s\t%d\n", Player_GetWeaponModelFromType(i), gShotData[target][sRightLeg][i]);
            strcat(szWounds, szAux);
        }  
    }

    if(!strcmp(szWounds, "Parte do Corpo\tArma\tTiros\n", true))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não possui ferimentos à bala aparentes.");

    ShowPlayerDialog(playerid, DIALOG_WOUNDS, DIALOG_STYLE_TABLIST_HEADERS, Player_GetRPName(target, true), szWounds, "Fechar", "");
    return 1;
}

Player_GetWeaponModelFromType(hittype){
    new
        model[20];

    switch(hittype){
        case HIT_TYPE_MISC: strcat(model, "Misc");
        case HIT_TYPE_MELEE: strcat(model, "Melee");
        case HIT_TYPE_NINEMM: strcat(model, "Colt 45");
        case HIT_TYPE_DEAGLE: strcat(model, "Desert Eagle");
        case HIT_TYPE_SHOTGUN: strcat(model, "Shotgun");
        case HIT_TYPE_MSMG: strcat(model, "Micro SMG");
        case HIT_TYPE_SMG: strcat(model, "SMG");
        case HIT_TYPE_AK47: strcat(model, "AK-47");
        case HIT_TYPE_M4: strcat(model, "M4");
        case HIT_TYPE_RIFLE: strcat(model, "Rifle");
        case HIT_TYPE_SNIPER: strcat(model, "Sniper");
    }
    return model;
}
