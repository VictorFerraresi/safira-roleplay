// system_property | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
House_Load(houseid){
    new szTemp[80];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `house` where `id_house` = '%d' limit 1", houseid);
    new Cache:result = mysql_query(hSQL, szTemp);

    if(!cache_get_row_count()){
        cache_delete(result);
        return 1;
    }

    gHouseData[houseid][hSQLID] = cache_get_field_content_int(0, "id_house", hSQL);
    gHouseData[houseid][hDoorX] = cache_get_field_content_float(0, "doorX", hSQL);
    gHouseData[houseid][hDoorY] = cache_get_field_content_float(0, "doorY", hSQL);
    gHouseData[houseid][hDoorZ] = cache_get_field_content_float(0, "doorZ", hSQL);
    gHouseData[houseid][hInteriorX] = cache_get_field_content_float(0, "interiorX", hSQL);
    gHouseData[houseid][hInteriorY] = cache_get_field_content_float(0, "interiorY", hSQL);
    gHouseData[houseid][hInteriorZ] = cache_get_field_content_float(0, "interiorZ", hSQL);
    gHouseData[houseid][hInteriorR] = cache_get_field_content_float(0, "interiorR", hSQL);
    gHouseData[houseid][hOwner] = cache_get_field_content_int(0, "id_character", hSQL);
    gHouseData[houseid][hPrice] = cache_get_field_content_int(0, "price", hSQL);
    gHouseData[houseid][hVWDoor] = cache_get_field_content_int(0, "vwdoor", hSQL);
    gHouseData[houseid][hIntDoor] = cache_get_field_content_int(0, "intdoor", hSQL);
    gHouseData[houseid][hLevel] = cache_get_field_content_int(0, "level", hSQL);
    gHouseData[houseid][hVW] = cache_get_field_content_int(0, "vw", hSQL);
    gHouseData[houseid][hInt] = cache_get_field_content_int(0, "int", hSQL);
    gHouseData[houseid][hLocked] = cache_get_field_content_int(0, "locked", hSQL);

    gHouseData[houseid][hPickup] = CreateDynamicPickup(1273, 1, gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ]+0.2, gHouseData[houseid][hVWDoor], gHouseData[houseid][hIntDoor]);

    if(gHouseData[houseid][hOwner] == 0){
        new szForSale[200];

        format(szForSale, sizeof(szForSale), "[Casa]\nPropriedade à venda\nNúmero: {FFFFFF}%d\n{6FBC0C}Preço: {FFFFFF}$%d\n{6FBC0C}Level: {FFFFFF}%d\nDigite /comprarcasa para adquirir esta propriedade.",
         gHouseData[houseid][hSQLID], gHouseData[houseid][hPrice], gHouseData[houseid][hLevel]);

        gHouseData[houseid][hText] = CreateDynamic3DTextLabel(szForSale, C_COLOR_HOUSETEXT, gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ]+0.2, 10.0, INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID, 1, gHouseData[houseid][hVWDoor], gHouseData[houseid][hIntDoor]);
    } else {
        new szHasOwner[200];

        format(szHasOwner, sizeof(szHasOwner), "[Casa]\nNúmero: {FFFFFF}%d\n{6FBC0C}Esta casa possui um dono.",
         gHouseData[houseid][hSQLID], gHouseData[houseid][hPrice], gHouseData[houseid][hLevel]);

        gHouseData[houseid][hText] = CreateDynamic3DTextLabel(szHasOwner, C_COLOR_HOUSETEXT, gHouseData[houseid][hDoorX], gHouseData[houseid][hDoorY], gHouseData[houseid][hDoorZ]+0.2, 10.0, INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID, 1, gHouseData[houseid][hVWDoor], gHouseData[houseid][hIntDoor]);
    }

    cache_delete(result);

    printf("[DEBUG] Casa %d carregada. (SQL: %d)", houseid, gHouseData[houseid][hSQLID]);
    return 1;
}

House_Save(houseid){
    if(gHouseData[houseid][hSQLID] == 0)
        return 1;

    new szTemp[400];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "update `house` set\
     `doorX` = '%f',\
     `doorY` = '%f',\
     `doorZ` = '%f',\
     `interiorX` = '%f',\
     `interiorY` = '%f',\
     `interiorZ` = '%f',\
     `interiorR` = '%f',\
     `id_character` = '%d',\
     `price` = '%d',\
     `vwdoor` = '%d',\
     `intdoor` = '%d',\
     `vw` = '%d',\
     `int` = '%d',\
     `level` = '%d',\
     `locked` = '%d'\
      where `id_house` = '%d'",
    gHouseData[houseid][hDoorX],
    gHouseData[houseid][hDoorY],
    gHouseData[houseid][hDoorZ],
    gHouseData[houseid][hInteriorX],
    gHouseData[houseid][hInteriorY],
    gHouseData[houseid][hInteriorZ],
    gHouseData[houseid][hInteriorR],
    gHouseData[houseid][hOwner],
    gHouseData[houseid][hPrice],
    gHouseData[houseid][hVWDoor],
    gHouseData[houseid][hIntDoor],
    gHouseData[houseid][hVW],
    gHouseData[houseid][hInt],
    gHouseData[houseid][hLevel],
    gHouseData[houseid][hLocked],
    gHouseData[houseid][hSQLID]);

    mysql_query(hSQL, szTemp);

    return 1;
}

House_RefreshIcon(houseid){
    new szNewText[200];

    if(gHouseData[houseid][hOwner] == 0){
        format(szNewText, sizeof(szNewText), "[Casa]\nPropriedade à venda\nNúmero: {FFFFFF}%d\n{6FBC0C}Preço: {FFFFFF}$%d\n{6FBC0C}Level: {FFFFFF}%d\nDigite /comprarcasa para adquirir esta propriedade.",
         gHouseData[houseid][hSQLID], gHouseData[houseid][hPrice], gHouseData[houseid][hLevel]);

        UpdateDynamic3DTextLabelText(gHouseData[houseid][hText], C_COLOR_HOUSETEXT, szNewText);
    } else {
        format(szNewText, sizeof(szNewText), "[Casa]\nNúmero: {FFFFFF}%d\n{6FBC0C}Esta casa possui um dono.",
         gHouseData[houseid][hSQLID], gHouseData[houseid][hPrice], gHouseData[houseid][hLevel]);

        UpdateDynamic3DTextLabelText(gHouseData[houseid][hText], C_COLOR_HOUSETEXT, szNewText);
    }
    return 1;
}

House_GetNextFreeID(){
    for(new i = 1; i < C_MAX_HOUSES; i++){
        if(gHouseData[i][hSQLID] == 0)
            return i;
    }
    return -1;
}

House_Create(houseid, price, level, Float:doorX, Float:doorY, Float:doorZ, Float:interiorX, Float:interiorY, Float:interiorZ, Float:interiorR, vwdoor, intdoor, vw, int){
    new 
      temp[512];

    mysql_format(hSQL, temp, sizeof(temp), "insert into `house` \
     (`id_house`, \      
      `doorX`, \
      `doorY`, \
      `doorZ`, \
      `interiorX`, \
      `interiorY`, \
      `interiorZ`, \
      `interiorR`, \
      `price`, \
      `vwdoor`, \
      `intdoor`, \
      `vw`, \
      `int`, \
      `level`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d', '%d')",
    houseid,
    doorX,
    doorY,
    doorZ,
    interiorX,
    interiorY,
    interiorZ,
    interiorR,
    price,
    vwdoor,
    intdoor,
    vw,
    int,
    level);

    mysql_query(hSQL, temp);

    House_Load(houseid);    

    return 1;
}

House_Delete(houseid){
    DestroyDynamicPickup(gHouseData[houseid][hPickup]);
    DestroyDynamic3DTextLabel(gHouseData[houseid][hText]);

    gHouseData[houseid][hSQLID] = 0;
    gHouseData[houseid][hDoorX] = 0.0;
    gHouseData[houseid][hDoorY] = 0.0;
    gHouseData[houseid][hDoorZ] = 0.0;
    gHouseData[houseid][hInteriorX] = 0.0;
    gHouseData[houseid][hInteriorY] = 0.0;
    gHouseData[houseid][hInteriorZ] = 0.0;
    gHouseData[houseid][hInteriorR] = 0.0;
    gHouseData[houseid][hOwner] = 0;
    gHouseData[houseid][hPrice] = 0;
    gHouseData[houseid][hPickup] = 0;
    gHouseData[houseid][hText] = Text3D:INVALID_3DTEXT_ID;
    gHouseData[houseid][hVWDoor] = 0;
    gHouseData[houseid][hIntDoor] = 0;
    gHouseData[houseid][hVW] = 0;
    gHouseData[houseid][hInt] = 0;
    gHouseData[houseid][hLevel] = 0;
    gHouseData[houseid][hLocked] = 0;

    new temp[256];

    mysql_format(hSQL, temp, sizeof(temp), "delete from `house` where `id_house` = %d", houseid);
    mysql_query(hSQL, temp);

    return 1;
}

House_GetOwnerID(houseid){
    return gHouseData[houseid][hOwner];
}

House_ShowPlayerHelp(playerid){
    SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos de Casa]______________________________");
    SendClientMessage(playerid, C_COLOR_WHITE, "/itens");
    return 1;
}

Business_Load(businessid){
    new szTemp[80];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `business` where `id_business` = '%d' limit 1", businessid);
    new Cache:result = mysql_query(hSQL, szTemp);

    if(!cache_get_row_count()){
        cache_delete(result);
        return 1;
    }

    gBusinessData[businessid][bSQLID] = cache_get_field_content_int(0, "id_business", hSQL);
    gBusinessData[businessid][bDoorX] = cache_get_field_content_float(0, "doorX", hSQL);
    gBusinessData[businessid][bDoorY] = cache_get_field_content_float(0, "doorY", hSQL);
    gBusinessData[businessid][bDoorZ] = cache_get_field_content_float(0, "doorZ", hSQL);
    gBusinessData[businessid][bInteriorX] = cache_get_field_content_float(0, "interiorX", hSQL);
    gBusinessData[businessid][bInteriorY] = cache_get_field_content_float(0, "interiorY", hSQL);
    gBusinessData[businessid][bInteriorZ] = cache_get_field_content_float(0, "interiorZ", hSQL);
    gBusinessData[businessid][bInteriorR] = cache_get_field_content_float(0, "interiorR", hSQL);
    gBusinessData[businessid][bCarSpawnX] = cache_get_field_content_float(0, "carSpawnX", hSQL);
    gBusinessData[businessid][bCarSpawnY] = cache_get_field_content_float(0, "carSpawnY", hSQL);
    gBusinessData[businessid][bCarSpawnZ] = cache_get_field_content_float(0, "carSpawnZ", hSQL);
    gBusinessData[businessid][bCarSpawnR] = cache_get_field_content_float(0, "carSpawnR", hSQL);
    gBusinessData[businessid][bOwner] = cache_get_field_content_int(0, "id_character", hSQL);
    gBusinessData[businessid][bPrice] = cache_get_field_content_int(0, "price", hSQL);
    gBusinessData[businessid][bVWDoor] = cache_get_field_content_int(0, "vwdoor", hSQL);
    gBusinessData[businessid][bIntDoor] = cache_get_field_content_int(0, "intdoor", hSQL);
    gBusinessData[businessid][bVW] = cache_get_field_content_int(0, "vw", hSQL);
    gBusinessData[businessid][bInt] = cache_get_field_content_int(0, "int", hSQL);
    gBusinessData[businessid][bLevel] = cache_get_field_content_int(0, "level", hSQL);
    gBusinessData[businessid][bLocked] = cache_get_field_content_int(0, "locked", hSQL);
    gBusinessData[businessid][bType] = cache_get_field_content_int(0, "type", hSQL);
    gBusinessData[businessid][bSafe] = cache_get_field_content_int(0, "safe", hSQL);
    gBusinessData[businessid][bFuelPrice][FUEL_GASOLINE] = cache_get_field_content_int(0, "gasolinePrice", hSQL);
    gBusinessData[businessid][bFuelPrice][FUEL_ETHANOL] = cache_get_field_content_int(0, "ethanolPrice", hSQL);
    gBusinessData[businessid][bFuelPrice][FUEL_DIESEL] = cache_get_field_content_int(0, "dieselPrice", hSQL);
    gBusinessData[businessid][bFuelPrice][FUEL_KEROSENE] = cache_get_field_content_int(0, "kerosenePrice", hSQL);    

    gBusinessData[businessid][bPickup] = CreateDynamicPickup(1272, 1, gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ]+0.2, gBusinessData[businessid][bVWDoor], gBusinessData[businessid][bIntDoor]);

    if(gBusinessData[businessid][bOwner] == 0){
        new szForSale[200];

        format(szForSale, sizeof(szForSale), "[Empresa]\nPropriedade à venda\nNúmero: {FFFFFF}%d\n{6FBC0C}Preço: {FFFFFF}$%d\n{6FBC0C}Level: {FFFFFF}%d\nDigite /comprarempresa para adquirir esta propriedade.",
         gBusinessData[businessid][bSQLID], gBusinessData[businessid][bPrice], gBusinessData[businessid][bLevel]);

        gBusinessData[businessid][bText] = CreateDynamic3DTextLabel(szForSale, C_COLOR_BUSINESSTEXT, gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ]+0.2, 10.0, INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID, 1, gBusinessData[businessid][bVWDoor], gBusinessData[businessid][bIntDoor]);
    } else {
        new szHasOwner[200];

        format(szHasOwner, sizeof(szHasOwner), "[Empresa]\nNúmero: {FFFFFF}%d\n{6FBC0C}Esta empresa possui um dono.",
         gBusinessData[businessid][bSQLID], gBusinessData[businessid][bPrice], gBusinessData[businessid][bLevel]);

        gBusinessData[businessid][bText] = CreateDynamic3DTextLabel(szHasOwner, C_COLOR_BUSINESSTEXT, gBusinessData[businessid][bDoorX], gBusinessData[businessid][bDoorY], gBusinessData[businessid][bDoorZ]+0.2, 10.0, INVALID_PLAYER_ID,
        INVALID_VEHICLE_ID, 1, gBusinessData[businessid][bVWDoor], gBusinessData[businessid][bIntDoor]);
    }

    cache_delete(result);

    printf("[DEBUG] Empresa %d carregada. (SQL: %d)", businessid, gBusinessData[businessid][bSQLID]);
    return 1;
}

Business_Save(businessid){
    new szTemp[600];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "update `business` set\
     `doorX` = '%f',\
     `doorY` = '%f',\
     `doorZ` = '%f',\
     `interiorX` = '%f',\
     `interiorY` = '%f',\
     `interiorZ` = '%f',\
     `interiorR` = '%f',\
     `carSpawnX` = '%f',\
     `carSpawnY` = '%f',\
     `carSpawnZ` = '%f',\
     `carSpawnR` = '%f',\
     `id_character` = '%d',\
     `price` = '%d',\
     `vwdoor` = '%d',\
     `intdoor` = '%d',\
     `vw` = '%d',\
     `int` = '%d',\
     `level` = '%d',\
     `locked` = '%d',\
     `type` = '%d',\
     `safe` = '%d',\
     `gasolinePrice` = '%d',\
     `ethanolPrice` = '%d',\
     `dieselPrice` = '%d',\
     `kerosenePrice` = '%d'\
      where `id_business` = '%d'",
    gBusinessData[businessid][bDoorX],
    gBusinessData[businessid][bDoorY],
    gBusinessData[businessid][bDoorZ],
    gBusinessData[businessid][bInteriorX],
    gBusinessData[businessid][bInteriorY],
    gBusinessData[businessid][bInteriorZ],
    gBusinessData[businessid][bInteriorR],
    gBusinessData[businessid][bCarSpawnX],
    gBusinessData[businessid][bCarSpawnY],
    gBusinessData[businessid][bCarSpawnZ],
    gBusinessData[businessid][bCarSpawnR],
    gBusinessData[businessid][bOwner],
    gBusinessData[businessid][bPrice],
    gBusinessData[businessid][bVWDoor],
    gBusinessData[businessid][bIntDoor],
    gBusinessData[businessid][bVW],
    gBusinessData[businessid][bInt],
    gBusinessData[businessid][bLevel],
    gBusinessData[businessid][bLocked],
    gBusinessData[businessid][bType],
    gBusinessData[businessid][bSafe],
    gBusinessData[businessid][bFuelPrice][FUEL_GASOLINE],
    gBusinessData[businessid][bFuelPrice][FUEL_ETHANOL],
    gBusinessData[businessid][bFuelPrice][FUEL_DIESEL],
    gBusinessData[businessid][bFuelPrice][FUEL_KEROSENE],
    gBusinessData[businessid][bSQLID]);

    mysql_query(hSQL, szTemp);

    return 1;
}

Business_RefreshIcon(businessid){
    new szNewText[200];

    if(gBusinessData[businessid][bOwner] == 0){
        format(szNewText, sizeof(szNewText), "[Empresa]\nPropriedade à venda\nNúmero: {FFFFFF}%d\n{6FBC0C}Preço: {FFFFFF}$%d\n{6FBC0C}Level: {FFFFFF}%d\nDigite /comprarempresa para adquirir esta propriedade.",
         gBusinessData[businessid][bSQLID], gBusinessData[businessid][bPrice], gBusinessData[businessid][bLevel]);

        UpdateDynamic3DTextLabelText(gBusinessData[businessid][bText], C_COLOR_BUSINESSTEXT, szNewText);
    } else {
        format(szNewText, sizeof(szNewText), "[Empresa]\nNúmero: {FFFFFF}%d\n{6FBC0C}Esta empresa possui um dono.",
         gBusinessData[businessid][bSQLID], gBusinessData[businessid][bPrice], gBusinessData[businessid][bLevel]);

        UpdateDynamic3DTextLabelText(gBusinessData[businessid][bText], C_COLOR_BUSINESSTEXT, szNewText);
    }
    return 1;
}

Business_GetNextFreeID(){
    for(new i = 1; i < C_MAX_BUSINESSES; i++){
        if(gBusinessData[i][bSQLID] == 0)
            return i;
    }
    return -1;
}

Business_Create(businessid, price, level, Float:doorX, Float:doorY, Float:doorZ, Float:interiorX, Float:interiorY, Float:interiorZ, Float:interiorR, vwdoor, intdoor, vw, int, type){
    new 
      temp[512];

    mysql_format(hSQL, temp, sizeof(temp), "insert into `business` \
     (`id_business`, \      
      `doorX`, \
      `doorY`, \
      `doorZ`, \
      `interiorX`, \
      `interiorY`, \
      `interiorZ`, \
      `interiorR`, \
      `price`, \
      `vwdoor`, \
      `intdoor`, \
      `vw`, \
      `int`, \
      `level`, \
      `type`) VALUES ('%d', '%f', '%f', '%f', '%f', '%f', '%f', '%f', '%d', '%d', '%d', '%d', '%d', '%d', '%d')",
    businessid,
    doorX,
    doorY,
    doorZ,
    interiorX,
    interiorY,
    interiorZ,
    interiorR,
    price,
    vwdoor,
    intdoor,
    vw,
    int,
    level,
    type);

    mysql_query(hSQL, temp);

    Business_Load(businessid);    

    return 1;
}

Business_Delete(businessid){
    DestroyDynamicPickup(gBusinessData[businessid][bPickup]);
    DestroyDynamic3DTextLabel(gBusinessData[businessid][bText]);

    gBusinessData[businessid][bSQLID] = 0;
    gBusinessData[businessid][bDoorX] = 0.0;
    gBusinessData[businessid][bDoorY] = 0.0;
    gBusinessData[businessid][bDoorZ] = 0.0;
    gBusinessData[businessid][bInteriorX] = 0.0;
    gBusinessData[businessid][bInteriorY] = 0.0;
    gBusinessData[businessid][bInteriorZ] = 0.0;
    gBusinessData[businessid][bInteriorR] = 0.0;
    gBusinessData[businessid][bCarSpawnX] = 0.0;
    gBusinessData[businessid][bCarSpawnY] = 0.0;
    gBusinessData[businessid][bCarSpawnZ] = 0.0;
    gBusinessData[businessid][bCarSpawnR] = 0.0;
    gBusinessData[businessid][bOwner] = 0;
    gBusinessData[businessid][bPrice] = 0;
    gBusinessData[businessid][bPickup] = 0;
    gBusinessData[businessid][bText] = Text3D:INVALID_3DTEXT_ID;
    gBusinessData[businessid][bVWDoor] = 0;
    gBusinessData[businessid][bIntDoor] = 0;
    gBusinessData[businessid][bVW] = 0;
    gBusinessData[businessid][bInt] = 0;
    gBusinessData[businessid][bLevel] = 0;
    gBusinessData[businessid][bLocked] = 0;
    gBusinessData[businessid][bType] = 0;
    gBusinessData[businessid][bSafe] = 0;
    gBusinessData[businessid][bFuelPrice][FUEL_GASOLINE] = 0;
    gBusinessData[businessid][bFuelPrice][FUEL_ETHANOL] = 0;
    gBusinessData[businessid][bFuelPrice][FUEL_DIESEL] = 0;
    gBusinessData[businessid][bFuelPrice][FUEL_KEROSENE] = 0;

    new temp[256];

    mysql_format(hSQL, temp, sizeof(temp), "delete from `business` where `id_business` = %d", businessid);
    mysql_query(hSQL, temp);

    return 1;
}

Business_ShowProducts(playerid, businessid){
    switch(gBusinessData[businessid][bType]){
        case BTYPE_NULL: SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não possui nada para vender");  
        case BTYPE_STORE: return 1; //TODO LOGIC HERE
        case BTYPE_BAR: return 1; // TODO LOGIC HERE
        case BTYPE_CLUB: return 1; //TODO LOGIC HERE
        case BTYPE_CASINO: return 1; //TODO LOGIC HERE
        case BTYPE_DEALERSHIP_BOAT: ShowModelSelectionMenu(playerid, boat_dealer_list, "Barcos");
        case BTYPE_DEALERSHIP_PLANE: ShowModelSelectionMenu(playerid, plane_dealer_list, "Avioes");
        case BTYPE_DEALERSHIP_MOTORCYCLE: ShowModelSelectionMenu(playerid, motorcycle_dealer_list, "Motocicletas");
        case BTYPE_DEALERSHIP_INDUSTRY: ShowModelSelectionMenu(playerid, industry_dealer_list, "Veiculos Industriais");
        case BTYPE_DEALERSHIP_LOW: ShowModelSelectionMenu(playerid, low_dealer_list, "Veiculos Baratos");
        case BTYPE_DEALERSHIP_MEDIUM: ShowModelSelectionMenu(playerid, medium_dealer_list, "Veiculos Populares");
        case BTYPE_DEALERSHIP_HIGH: ShowModelSelectionMenu(playerid, high_dealer_list, "Veiculos de Luxo");
        case BTYPE_GAS_GENERAL: return 1; //TODO LOGIC HERE
        case BTYPE_GAS_KEROSENE: return 1; //TODO LOGIC HERE
        case BTYPE_FURNITURE: return 1; //TODO LOGIC HERE
        default: SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não possui nada para vender");
    }
    return 1;  
}

Business_GetType(businessid){
    return gBusinessData[businessid][bType];
}

Business_GetOwnerID(businessid){
    return gBusinessData[businessid][bOwner];
}

//------------------------------------------------------------------------------

//Hooks


//------------------------------------------------------------------------------

//Comandos