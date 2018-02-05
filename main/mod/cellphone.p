// system_cellphone | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções

Cellphone_DialNumber(playerid, phNumber){
    new
        owner = Cellphone_GetOwner(phNumber);

    PlayerPlaySound(playerid, 3600, 0.0, 0.0, 0.0);

    if(Cellphone_IsStatic(phNumber))
        return Cellphone_DialStaticNumber(playerid, phNumber);

    if(owner == playerid)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode ligar para você mesmo.");

    if(owner == -1)
        return SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Este número de telefone não existe ou está fora de área.");        

    if(Cellphone_IsInCall(owner))
        return SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Este número encontra-se ocupado no momento.");

    if(!Cellphone_IsOnline(owner))
        return SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Este número não pode receber chamadas no momento pois está desligado.");

    new
        szAux[128];

    format(szAux, sizeof(szAux), "[INFO]{FFFFFF} Você está ligando para %s.", Cellphone_GetContactName(playerid, phNumber));
    SendClientMessage(playerid, C_COLOR_SUCCESS, szAux);

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);
    cmd_do(owner,"O celular começa a tocar.");    
    format(szAux, sizeof(szAux), "[INFO] {FFFFFF}Identificador: %s. Digite {1BBAD6}/atender {FFFFFF}ou {1BBAD6}/desligar{FFFFFF}.", Cellphone_GetContactName(owner, gPlayerData[playerid][pCellphone]));
    SendClientMessage(owner, C_COLOR_SUCCESS, szAux);
    SetPVarInt(owner, "ReceivingCall", playerid);
    SetPVarInt(playerid, "DialingPlayer", owner);

    Cellphone_Ring(owner);

    CellRingTimer[owner] = SetTimerEx("Cellphone_Ring", 4000, true, "i", owner);
    return 1;
}

Cellphone_DialStaticNumber(playerid, phNumber){
    switch(phNumber){
        case PHONE_INSURANCE:{        
            SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Bem vindo à seguradora, como podemos te ajudar hoje?");                
            Player_ShowInsuranceList(playerid);
        }        
    }
    return 1;
}

function Cellphone_Ring(playerid){
    new
        Float:x,
        Float:y,
        Float:z;

    GetPlayerPos(playerid, x, y, z);

    for(new i = 0; i < GetMaxPlayers(); i++){
        if(Player_IsNearPlayer(10.0, playerid, i)){            
            PlayerPlaySound(i, 23000, x, y, z);
        }
    }
    return 1;
}

Cellphone_GetOwner(phNumber){
    for(new i = 0; i < GetMaxPlayers(); i++){
        if(gPlayerData[i][pCellphone] == phNumber)
            return i;
    }
    return -1;
}

Cellphone_IsInCall(playerid){
    if(gPlayerData[playerid][pCellphoneCall] == -1)
        return false;
    else
        return true;    
}

Cellphone_IsOnline(playerid){
    return gPlayerData[playerid][pCellphoneStatus];
}

Cellphone_FinishCall(playerid){
    if(Cellphone_IsInCall(playerid)){ //Já estava conversando com outra pessoa
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Você desligou a ligação.");
        SendClientMessage(gPlayerData[playerid][pCellphoneCall], C_COLOR_CHATFADE1, "Gravação diz: O outro lado desligou a ligação.");

        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
        SetPlayerSpecialAction(gPlayerData[playerid][pCellphoneCall], SPECIAL_ACTION_STOPUSECELLPHONE);

        gPlayerData[gPlayerData[playerid][pCellphoneCall]][pCellphoneCall] = -1;
        gPlayerData[playerid][pCellphoneCall] = -1; 

    } else if(GetPVarType(playerid, "ReceivingCall") != PLAYER_VARTYPE_NONE) { //Estava recebendo uma ligação
        if(CellRingTimer[playerid] != 0){
            KillTimer(CellRingTimer[playerid]);
            CellRingTimer[playerid] = 0;
        }

        SendClientMessage(GetPVarInt(playerid, "ReceivingCall"), C_COLOR_CHATFADE1, "Gravação diz: O outro lado desligou a ligação.");
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Você desligou a ligação.");        

        SetPlayerSpecialAction(GetPVarInt(playerid, "ReceivingCall"), SPECIAL_ACTION_STOPUSECELLPHONE);

        DeletePVar(GetPVarInt(playerid, "ReceivingCall"), "DialingPlayer");
        DeletePVar(playerid, "ReceivingCall");

    } else if(GetPVarType(playerid, "DialingPlayer") != PLAYER_VARTYPE_NONE){ //Estava ligando para um jogador
        if(CellRingTimer[GetPVarInt(playerid, "DialingPlayer")] != 0){
            KillTimer(CellRingTimer[GetPVarInt(playerid, "DialingPlayer")]);
            CellRingTimer[GetPVarInt(playerid, "DialingPlayer")] = 0;
        }

        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Você desligou a ligação.");
        SendClientMessage(GetPVarInt(playerid, "DialingPlayer"), C_COLOR_SUCCESS, "[INFO] {FFFFFF}A ligação foi cancelada.");
        DeletePVar(GetPVarInt(playerid, "DialingPlayer"), "ReceivingCall");
        DeletePVar(playerid, "DialingPlayer");

        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_STOPUSECELLPHONE);
    }
    return 1;
}

Cellphone_StartCall(playerid, targetid){
    gPlayerData[playerid][pCellphoneCall] = targetid;
    gPlayerData[targetid][pCellphoneCall] = playerid;

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USECELLPHONE);

    if(CellRingTimer[playerid] != 0){
        KillTimer(CellRingTimer[playerid]);
        CellRingTimer[playerid] = 0;
    }

    DeletePVar(playerid, "ReceivingCall");
    DeletePVar(targetid, "DialingPlayer");

    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}Você atendeu a ligação.");
    SendClientMessage(targetid, C_COLOR_SUCCESS, "[INFO] {FFFFFF}A ligação foi atendida.");
    return 1;
}

Cellphone_SendSms(senderNumber, receiverNumber, message[]){
    new
        receiver = Cellphone_GetOwner(receiverNumber),
        sender = Cellphone_GetOwner(senderNumber);

    if(receiver == sender)
        return SendClientMessage(sender, C_COLOR_ERROR, "[ERRO] Você não pode enviar um SMS para você mesmo.");        

    if(receiver == -1){
        if(!Cellphone_IsStatic(senderNumber))
            SendClientMessage(sender, C_COLOR_CHATFADE1, "Gravação diz: Este número de telefone não existe ou está fora de área."); 
        return 1;
    }   

    if(!Cellphone_IsOnline(receiver)){
        if(!Cellphone_IsStatic(senderNumber))
            SendClientMessage(sender, C_COLOR_CHATFADE1, "Gravação diz: Este número não pode receber chamadas no momento pois está desligado.");
        return 1;
    }

    new
        szSms[160];
    if(!Cellphone_IsStatic(senderNumber)){
        format(szSms, sizeof(szSms), "*SMS para %s: %s*", Cellphone_GetContactName(sender, receiverNumber), message);
        SendClientMessage(sender, C_COLOR_SMSS, szSms);
    }
    format(szSms, sizeof(szSms), "*SMS de %s: %s*", Cellphone_GetContactName(receiver, senderNumber), message);
    SendClientMessage(receiver, C_COLOR_SMSR, szSms);

    return 1;
}

Cellphone_GetContactName(playerid, phNumber){
    new
        name[60];

    switch(phNumber){
        case PHONE_INSURANCE: strins(name, "Seguro", 0);
        case PHONE_EMERGENCY: strins(name, "Emergência", 0);
        default:{
            new 
                temp[130];

            mysql_format(hSQL, temp, sizeof(temp), "select name from `character_contacts` where `phoneNumber` = '%d' and `id_character` = '%d' limit 1", phNumber, Player_DBID(playerid));
            new Cache:result = mysql_query(hSQL, temp);

            if(cache_num_rows() > 0){
                cache_get_field_content(0, "name", name, hSQL, 60);    
            }
            else{
                format(name, sizeof(name), "%d", phNumber);
            }

            cache_delete(result);
        }
    }    

    return name;
}

Cellphone_IsStatic(phNumber){
    if(phNumber == PHONE_INSURANCE || phNumber == PHONE_EMERGENCY)
        return 1;
    return 0;
}

Cellphone_ShowContactList(playerid){
    new temp[80];

    mysql_format(hSQL, temp, sizeof(temp), "select name, phoneNumber from `character_contacts` where `id_character` = '%d'", Player_DBID(playerid));
    new Cache:result = mysql_query(hSQL, temp);

    new 
        rows = cache_num_rows(),
        index = 0,
        szContacts[512];

    while(index < rows){
        new 
            szName[60],
            number,
            szAux[128];

        cache_get_field_content(index, "name", szName, hSQL, 60);
        number = cache_get_field_content_int(index, "phoneNumber", hSQL);

        format(szAux, sizeof(szAux), "%s - %d%s", szName, number, rows-index==1 ? ("") : ("\n"));
        strcat(szContacts, szAux);
        index++;
    }
    ShowPlayerDialog(playerid, DIALOG_CONTACTS, DIALOG_STYLE_LIST, "Meus Contatos", szContacts, "Selecionar", "Voltar");

    cache_delete(result);
    return 1;
}

Cellphone_CreateContact(playerid, phNumber, name[]){
    new 
        temp[200];

    mysql_format(hSQL, temp, sizeof(temp), "insert into `character_contacts` \
     (`id_character`, \      
      `phoneNumber`, \
      `name`) VALUES ('%d', '%d', '%s')",
    Player_DBID(playerid),
    phNumber,
    name);

    mysql_query(hSQL, temp);
    return 1;
}

Cellphone_ShowCellphoneHelp(playerid){
    SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos do Celular]______________________________");
    SendClientMessage(playerid, C_COLOR_WHITE, "/ligar, /desligar, /atender, /sms, /contatos");
    return 1;
}

//------------------------------------------------------------------------------

//Hooks

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    switch(dialogid){
        case DIALOG_CONTACTMANAGEMENT:{
            if(!response)
                return 1;      

            switch(listitem){
                case 0: Cellphone_ShowContactList(playerid);
                case 1: ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNUMBER, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o número do novo contato", "Avançar", "Cancelar");
            }
            return 1;
        }
        case DIALOG_ADDCONTACTNUMBER:{
            if(!response)
                return cmd_contatos(playerid, "");

            if(isnull(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNUMBER, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o número do novo contato\n{ED0202}Digite algum número!", "Avançar", "Cancelar");

            if(!IsNumeric(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNUMBER, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o número do novo contato\n{ED0202}Utilize apenas números!", "Avançar", "Cancelar");

            new 
                number = strval(inputtext);

            if(Cellphone_IsStatic(number) || number < 10000)
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNUMBER, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o número do novo contato\n{ED0202}Este número é inválido!", "Avançar", "Cancelar");

            new 
                temp[130];

            mysql_format(hSQL, temp, sizeof(temp), "select name from `character_contacts` where `phoneNumber` = '%d' and `id_character` = '%d' limit 1", number, Player_DBID(playerid));
            new Cache:result = mysql_query(hSQL, temp);

            if(cache_num_rows() > 0){
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNUMBER, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o número do novo contato\n{ED0202}Você já possui um contato com este número!", "Avançar", "Cancelar");   
            }
            else{
                SetPVarInt(playerid, "NewContactNumber", number);              
                ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNAME, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o nome do novo contato", "Concluir", "Cancelar");
            }
            cache_delete(result);                
        }
        case DIALOG_ADDCONTACTNAME:{
            if(!response){
                cmd_contatos(playerid, "");
                DeletePVar(playerid, "NewContactNumber");
                return 1;
            }

            if(isnull(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNAME, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o nome do novo contato\n{ED0202}Digite algum nome!", "Concluir", "Cancelar");

            if(strlen(inputtext) > 50)
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNAME, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o nome do novo contato\n{ED0202}Escolha um nome de até 50 caracteres!", "Concluir", "Cancelar");

            new 
                temp[130];

            mysql_format(hSQL, temp, sizeof(temp), "select phoneNumber from `character_contacts` where `name` = '%e' and `id_character` = '%d' limit 1", inputtext, Player_DBID(playerid));
            new Cache:result = mysql_query(hSQL, temp);

            if(cache_num_rows() > 0){
                return ShowPlayerDialog(playerid, DIALOG_ADDCONTACTNAME, DIALOG_STYLE_INPUT, "Criar Novo Contato", "Digite o nome do novo contato\n{ED0202}Você já possui um contato com este nome!", "Concluir", "Cancelar");   
            }
            else{
                Cellphone_CreateContact(playerid, GetPVarInt(playerid, "NewContactNumber"), inputtext);
                SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você adicionou um novo contato à sua lista de contatos.");
                DeletePVar(playerid, "NewContactNumber");
            }
            cache_delete(result);          
        }
        case DIALOG_CONTACTS:{
            if(!response)
                return cmd_contatos(playerid, "");

            new
                name[60],
                phNumber,
                temp[100];

            mysql_format(hSQL, temp, sizeof(temp), "select name, phoneNumber from `character_contacts` where `id_character` = '%d' limit %d,1", Player_DBID(playerid), listitem);
            new Cache:result = mysql_query(hSQL, temp);        

            cache_get_field_content(0, "name", name, hSQL, 60);
            phNumber = cache_get_field_content_int(0, "phoneNumber", hSQL);

            cache_delete(result);        
            SetPVarInt(playerid, "ContactNumber", phNumber);
            SetPVarString(playerid, "ContactName", name);

            ShowPlayerDialog(playerid, DIALOG_CONTACTSELECT, DIALOG_STYLE_LIST, name, "Ligar\nSMS\nDeletar", "Selecionar", "Voltar");
        }
        case DIALOG_CONTACTSELECT:{
            if(!response){
                Cellphone_ShowContactList(playerid);
                DeletePVar(playerid, "ContactNumber");
                DeletePVar(playerid, "ContactName");
                return 1;
            }

            new 
                phNumber[10],
                name[60];
            format(phNumber, sizeof(phNumber), "%d", GetPVarInt(playerid, "ContactNumber"));
            GetPVarString(playerid, "ContactName", name, sizeof(name));

            switch(listitem){
                case 0:{                    
                    cmd_ligar(playerid, phNumber);                                        
                }
                case 1:{
                    ShowPlayerDialog(playerid, DIALOG_CONTACTSMS, DIALOG_STYLE_INPUT, name, "Digite o SMS que deseja enviar", "Enviar", "Cancelar");
                }
                case 2:{
                    ShowPlayerDialog(playerid, DIALOG_CONTACTDELETE, DIALOG_STYLE_MSGBOX, name, "Você tem certeza de que deseja deletar este contato?", "Sim", "Não");
                }
            }            
        }
        case DIALOG_CONTACTSMS:{
            if(!response){
                Cellphone_ShowContactList(playerid);
                DeletePVar(playerid, "ContactNumber");                
                return 1;    
            }

            new 
                phNumber[10],
                name[60];
            format(phNumber, sizeof(phNumber), "%d", GetPVarInt(playerid, "ContactNumber"));
            GetPVarString(playerid, "ContactName", name, sizeof(name));

            if(isnull(inputtext))
                return ShowPlayerDialog(playerid, DIALOG_CONTACTSMS, DIALOG_STYLE_INPUT, name, "Digite o SMS que deseja enviar/n{ED0202}Digite alguma mensagem!", "Enviar", "Cancelar");        

            Cellphone_SendSms(gPlayerData[playerid][pCellphone], GetPVarInt(playerid, "ContactNumber"), inputtext);
            DeletePVar(playerid, "ContactNumber");
            DeletePVar(playerid, "ContactName");
        }
        case DIALOG_CONTACTDELETE:{
            if(!response){
                Cellphone_ShowContactList(playerid);
                DeletePVar(playerid, "ContactNumber");
                DeletePVar(playerid, "ContactName");
                return 1;                        
            }
            new
                temp[100];
            mysql_format(hSQL, temp, sizeof(temp), "delete from `character_contacts` where `phoneNumber` = %d and `id_character` = %d", GetPVarInt(playerid, "ContactNumber"), Player_DBID(playerid));
            mysql_query(hSQL, temp);
            Cellphone_ShowContactList(playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

//Comandos

CMD:ligar(playerid, params[]){
    if(gPlayerData[playerid][pCellphone] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui um celular.");

    if(Cellphone_IsInCall(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já está em uma ligação telefônica.");

    new
        phNumber;

    if(sscanf(params, "d", phNumber))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /ligar [número] -{C0C0C0} Liga para outro telefone/celular");

    if(phNumber < 10000)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um número de telefone/celular inválido (Menos de 5 dígitos).");

    Cellphone_DialNumber(playerid, phNumber);    
    return 1;
}

CMD:desligar(playerid, params[]){
    if(gPlayerData[playerid][pCellphone] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui um celular.");

    if(!Cellphone_IsInCall(playerid) && GetPVarType(playerid, "ReceivingCall") == PLAYER_VARTYPE_NONE && GetPVarType(playerid, "DialingPlayer") == PLAYER_VARTYPE_NONE)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está em uma ligação telefônica.");

    Cellphone_FinishCall(playerid);
    return 1;
}

CMD:atender(playerid, params[]){
    if(gPlayerData[playerid][pCellphone] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui um celular.");

    if(GetPVarType(playerid, "ReceivingCall") == PLAYER_VARTYPE_NONE)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Ninguém está te ligando no momento.");

    Cellphone_StartCall(playerid, GetPVarInt(playerid, "ReceivingCall"));
    return 1;
}

CMD:sms(playerid, params[]){
    if(gPlayerData[playerid][pCellphone] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui um celular.");

    if(Cellphone_IsInCall(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já está em uma ligação telefônica.");

    new
        phNumber,
        msg[128];

    if(sscanf(params, "ds[128]", phNumber, msg))
        return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /sms [número] -{C0C0C0} Envia um SMS para outro telefone/celular");

    if(phNumber < 10000)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um número de celular inválido (Menos de 5 dígitos).");

    Cellphone_SendSms(gPlayerData[playerid][pCellphone], phNumber, msg);
    return 1;
}

CMD:contatos(playerid, params[]){
    if(gPlayerData[playerid][pCellphone] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui um celular.");
    ShowPlayerDialog(playerid, DIALOG_CONTACTMANAGEMENT, DIALOG_STYLE_LIST, "Lista de Contatos", "Meus Contatos\nCriar Novo Contato", "Selecionar", "Sair");
    return 1;
}
