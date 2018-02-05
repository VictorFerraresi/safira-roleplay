#include <a_samp>

#define SQL_HOST "localhost"
#define SQL_USER "root"
#define SQL_DB "safiradb"
#define SQL_PASS "doomsday1"

#define FSQL_HOST "localhost"
#define FSQL_USER "samp"
#define FSQL_DB "forum"
#define FSQL_PASS "samp123"


#define NOT_CONNECTED    "[ERRO] Este jogador não está conectado!"
#define NO_PERMISSION    "[ERRO] Você não pode utilizar este comando!"
#define NOT_LOGGED       "[ERRO] Você não pode utilizar comandos antes de realizar login!"
#define HIGHER_ADMIN     "[ERRO] Você não pode utilizar este comando em um administrador de level maior do que o seu!"
#define NOT_SELF         "[ERRO] Você não pode utilizar este comando em você mesmo!"
#define JOB_PERMISSION   "[ERRO] Este comando não está associado ao seu emprego!"
#define NOT_ALIVE        "[ERRO] Você não pode realizar esta ação se estiver morto!"

#define function%0(%1) forward %0(%1); public %0(%1)
#define Pressed(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define MAX_FACTIONS 21
#define MAX_HOUSES 200
#define MAX_BUSINESSES 100

#define PHONE_INSURANCE 5556321
#define PHONE_EMERGENCY 911

#define DEFAULTSPAWNX 2263.8931
#define DEFAULTSPAWNY -1725.9282
#define DEFAULTSPAWNZ 13.5469
#define DEFAULTSPAWNR 180.9864

#define CHARCAMERAX 1931.8042
#define CHARCAMERAY -1783.6526
#define CHARCAMERAZ 30.4191

#define CHARCAMERALOOKX 1863.8713
#define CHARCAMERALOOKY -1843.6823
#define CHARCAMERALOOKZ 13.5774

#define BODY_PART_TORSO 3
#define BODY_PART_CHEST 4
#define BODY_PART_LEFT_ARM 5
#define BODY_PART_RIGHT_ARM 6
#define BODY_PART_LEFT_LEG 7
#define BODY_PART_RIGHT_LEG 8
#define BODY_PART_HEAD 9

new const
    C_MAX_FACTIONS = 20,
    C_MAX_HOUSES = 200,
    C_MAX_BUSINESSES = 100,
    C_MAX_TRUNK_SIZE = 50;

new VehicleNames[][] = 
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};

new VehiclesWithoutFuel[] = 
{
    432, 434, 435, 441, 444, 447, 449, 450, 464, 465, 469, 481, 485, 501, 509, 510,
    537, 538, 539, 545, 556, 557, 564, 569, 570, 583, 584, 590, 591, 594, 604, 605,
    606, 607, 608, 610, 611
};

new VehiclesWithoutEngine[] = 
{
    481, 509, 510
};

new VehiclesWithoutWindows[] =
{
    430, 446, 448, 452, 453, 454, 460, 461, 462, 463, 468, 471, 472, 473, 476, 481,
    484, 493, 509, 510, 511, 512, 513, 519, 520, 521, 522, 553, 577, 581, 586, 592,
    593, 595
};


new LetterList[26][] =
{
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
};

enum HOSPITAL_MAIN {
    Float:hospPosX,
    Float:hospPosY,
    Float:hospPosZ,
    Float:hospPosR
};

new HospitalPositions[][HOSPITAL_MAIN] =
{
    {1178.6522,-1323.3264,14.1306,270.9825}, //All Saints General Hospital
    {2029.6058,-1418.7064,16.9922,134.2177}, //County General Hospital
    {-320.6912,1056.1537,19.7422,2.0592}, //Fort Carson Medical Center
    {1579.2982,1769.2982,10.8203,89.8901}, //Las Venturas Hospital
    {-2655.4548,633.0534,14.4531,180.2260}, //San Fierro Hospital
    {-2197.4553,-2306.0159,30.6250,320.4863}, //Angel Pine Medical Center
    {1244.9829,331.9607,19.5547,336.8554} //Crippen Memorial Montgomery Hospital
};

enum {
    DIALOG_NULL,
    DIALOG_LOGIN,
    DIALOG_UCPREDIR,
    DIALOG_ADMFAC,
    DIALOG_ADMFAC2,
    DIALOG_NOMEFAC,
    DIALOG_ACROFAC,
    DIALOG_TIPOFAC,
    DIALOG_CORFAC,
    DIALOG_COFREFAC,
    DIALOG_SPAWNFAC,
    DIALOG_EQUIPFAC,
    DIALOG_CHARACTERS,
    DIALOG_APPSTATUS,
    DIALOG_CARBUY,
    DIALOG_CONTACTMANAGEMENT,
    DIALOG_CONTACTS,
    DIALOG_ADDCONTACTNUMBER,
    DIALOG_ADDCONTACTNAME,
    DIALOG_CONTACTSELECT,
    DIALOG_CONTACTSMS,
    DIALOG_CONTACTDELETE,
    DIALOG_INSURANCERECOVER,
    DIALOG_INSURANCECONFIRM,
    DIALOG_CONFIRMCARDELETE,
    DIALOG_CHOOSESPAWN,
    DIALOG_HOUSES,
    DIALOG_BUSINESSES,
    DIALOG_WOUNDS,
    DIALOG_TRUNK,
    DIALOG_TRUNKSTOREOPT
};

enum {
    LOG_NULL,
    LOG_ADMIN,
    LOG_CHAT,
    LOG_CMD,
    LOG_DEATH,
    LOG_LOGIN
};

enum {
    SPAWN_CIVILIAN,
    SPAWN_FACTION,
    SPAWN_HOUSE,
    SPAWN_BUSINESS
};

enum {
    FACTION_CIVILIAN,
    FACTION_POLICE,
    FACTION_MEDIC,
    FACTION_GOV,
    FACTION_GANG,
    FACTION_MAFIA
};

enum{
    BTYPE_NULL,
    BTYPE_STORE,
    BTYPE_BAR,
    BTYPE_CLUB,
    BTYPE_CASINO,
    BTYPE_DEALERSHIP_BOAT,
    BTYPE_DEALERSHIP_PLANE,
    BTYPE_DEALERSHIP_MOTORCYCLE,
    BTYPE_DEALERSHIP_INDUSTRY,
    BTYPE_DEALERSHIP_LOW,
    BTYPE_DEALERSHIP_MEDIUM,
    BTYPE_DEALERSHIP_HIGH,
    BTYPE_GAS_GENERAL,
    BTYPE_GAS_KEROSENE,
    BTYPE_FURNITURE
};

enum{
    FUEL_NULL,
    FUEL_GASOLINE,
    FUEL_ETHANOL,
    FUEL_FLEX,
    FUEL_DIESEL,
    FUEL_KEROSENE
};

enum{
    HIT_TYPE_MISC,
    HIT_TYPE_MELEE,
    HIT_TYPE_NINEMM,
    HIT_TYPE_DEAGLE,
    HIT_TYPE_SHOTGUN,
    HIT_TYPE_MSMG,
    HIT_TYPE_SMG,
    HIT_TYPE_AK47,
    HIT_TYPE_M4,
    HIT_TYPE_RIFLE,
    HIT_TYPE_SNIPER
};

enum{
    TRUNK_ITEM_TYPE_NONE,
    TRUNK_ITEM_TYPE_WEAPON,
    TRUNK_ITEM_TYPE_DRUG
};

enum pData{
    pSQLID,
    pACCID,
    pName[32],
    pOwner,
    pAdmin,
    pLevel,
    pLogged,
    pTutorial,
    pInTutorial,
    pAdmDuty,
    pSkin,
    Float:pSpawnX,
    Float:pSpawnY,
    Float:pSpawnZ,
    Float:pSpawnR,
    pLoginFailed,
    pJob,
    pFaction,
    pFactionTog,
    pFactionRank,
    pRankName[40],
    pMask,
    pMaskOn,
    pMoney,
    pBlockPM,
    pSpawnLoc,
    pPropertySpawn,
    pLeaveReason,
    pFactionInvite,
    pFacDuty,
    Text3D:pScene,
    Text3D:pDeadText,
    pSceneCreated,
    pInsideHouse,
    pInsideBusiness,
    pLogoutDelay,
    pLogoutTimer,
    pVehRefueling,
    pBusinessRefueling,
    pRefuelingType,
    pVehBreakingIn,    
    pVehBreakingInTime,
    pVehHotwiring,    
    pVehHotwiringTime,
    pToolkit,
    pCellphone,
    pCellphoneCall,
    pCellphoneStatus,
    pInterior,
    pVW,
    pDeath,
    pWeapon[13],
    pAmmo[13],
    pACDelay
};

new gPlayerData[MAX_PLAYERS][pData];

enum aData{
    aSQLID,
    aName[32]
};

new gAccountData[MAX_PLAYERS][aData];

enum fData{
    fSQLID,
    fType,
    Float:fSpawnX,
    Float:fSpawnY,
    Float:fSpawnZ,
    Float:fSpawnR,
    Float:fEquipX,
    Float:fEquipY,
    Float:fEquipZ,
	fName[50],
	fBank,
	fColor,
	fMaxRanks,
	fStartRank,
	fTogChat,
    fAcro[10]
};

new gFactionData[MAX_FACTIONS][fData];

enum hData{
    hSQLID,
    Float:hDoorX,
    Float:hDoorY,
    Float:hDoorZ,
    Float:hInteriorX,
    Float:hInteriorY,
    Float:hInteriorZ,
    Float:hInteriorR,
    hOwner,
    hPrice,
    hPickup,
    Text3D:hText,
    hVWDoor,
    hIntDoor,
    hVW,
    hInt,
    hLevel,
    hLocked
};

new gHouseData[MAX_HOUSES][hData];

enum bData{
    bSQLID,
    Float:bDoorX,
    Float:bDoorY,
    Float:bDoorZ,
    Float:bInteriorX,
    Float:bInteriorY,
    Float:bInteriorZ,
    Float:bInteriorR,
    Float:bCarSpawnX,
    Float:bCarSpawnY,
    Float:bCarSpawnZ,
    Float:bCarSpawnR,
    bOwner,
    bPrice,
    bPickup,
    Text3D:bText,
    bVWDoor,
    bIntDoor,
    bVW,
    bInt,
    bLevel,
    bLocked,    
    bType,
    bSafe,
    bFuelPrice[6]
};

new gBusinessData[MAX_BUSINESSES][bData];

enum vData{
    vSQLID,
    vID,
    vModel,
    vOwner,
    Float:vSpawnX,
    Float:vSpawnY,
    Float:vSpawnZ,
    Float:vSpawnR,
    vColor1,
    vColor2,
    vStatic,
    vFaction,
    vJob,
    vFuel,
    vActualRefuel,
    vPlate[32],
    vEngine,
    vSpawned,
    vLocked,
    vGPS,
    Float: vMileage,
    vConsumption,
    vLastFuelMileage,
    vLockLevel,
    vAlarmLevel,
    vImmobLevel,
    vDestroyed,
    vTrunk,
    vTrunkSize
};

new gVehicleData[MAX_VEHICLES][vData];

enum sData{
    sTorso,
    sChest,
    sLeftArm,
    sRightArm,
    sLeftLeg,
    sRightLeg,
    sHead
};

new gShotData[MAX_PLAYERS][sData][11];

new 
    hSQL,
    fSQL,

    boat_dealer_list,
    plane_dealer_list,
    motorcycle_dealer_list,
    industry_dealer_list,
    low_dealer_list,
    medium_dealer_list,
    high_dealer_list,

    MileageTimer[MAX_PLAYERS],
    RefuelingTimer[MAX_PLAYERS],
    HotwireTimer[MAX_PLAYERS],
    CellRingTimer[MAX_PLAYERS],

    Text:blackScreen;

native WP_Hash(buffer[], len, const str[]);
native IsValidVehicle(vehicleid);

stock PreloadAnimLib(playerid, animlib[])
    ApplyAnimation(playerid,animlib,"null",0.0,0,0,0,0,0);

stock Player_CheckAccount(playerid);
stock Player_GetName(playerid);
stock Player_GetRPName(playerid, bool:ignoreMask);
stock Player_DisplayLogin(playerid, displaytext[]);
stock Player_Authenticate(playerid, password[]);
stock Player_GetCharacterCount(playerid);
stock Player_ShowCharacterList(playerid);
stock Player_GetAppStatus(member_id);
stock Player_ResetCharacterVariables(playerid);
stock Player_ResetAccountVariables(playerid);
stock Player_CharacterSave(playerid);
stock Player_CharacterLoad(playerid, characterid);
stock Player_PutOnWorld(playerid);
stock Player_Tutorial(playerid, stage);
stock Player_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
stock Player_CleanChat(playerid);
stock Player_Kick(playerid);
stock Player_Ban(playerid);
stock Player_DBID(playerid);
stock Player_GetFactionID(playerid);
stock Player_FactionRank(playerid);
stock Player_GetJobID(playerid);
stock Player_SendLongMsg(playerid, color, const msg[]);
stock Player_SendLongAction(playerid, color, const act[]);
stock Player_IsNearPlayer(Float:range, playerid, target);
stock Player_GetLevel(playerid);
stock Player_GetMoney(playerid);
stock Player_GiveMoney(playerid, amount);
stock Player_GetNearestHouse(playerid);
stock Player_GetNearestBusiness(playerid);
stock Player_SetPosition(playerid, Float: x, Float: y, Float: z, Float: r = 0.0, Interior = 0, VW = 0, freezetime = 0);
stock Player_PrepareLogout(playerid);
stock Player_Logout(playerid);
stock Player_DealershipGiveVehicle(playerid, modelid, dealershipid);
stock Player_ShowVehicles(playerid, ownerid);
stock Player_SayToVehicle(playerid, szTalk[]);
stock Player_ResetTimers(playerid);
stock Player_ShowInsuranceList(playerid);
stock Player_ShowHouseList(playerid);
stock Player_ShowBusinessList(playerid);
stock Player_GetHousesOwned(playerid);
stock Player_GetBusinessesOwned(playerid);
stock Player_IsDead(playerid);
stock Player_GetNearestHospital(playerid, &Float: x, &Float: y, &Float: z, &Float: r);
stock Player_ResetSpawnInfo(playerid);
stock Player_ResetShotInfo(playerid);
stock Player_GetWeaponModelFromType(hittype);
stock Player_GiveWeapon(playerid, weaponid, ammo);
stock Player_RemoveWeapon(playerid, weaponid);
stock Player_ShowPlayerHelp(playerid);

stock Admin_GetLevel(playerid);
stock Admin_GetRankName(playerid);
stock Admin_SendMessage(color, text[]);
stock Admin_ShowPlayerHelp(playerid);

stock Server_Kick(playerid);
stock Server_Ban(playerid);

stock Faction_GetType(factionid);
stock Faction_GetName(factionid);
stock Faction_Load(factionid);
stock Faction_Save(factionid);
stock Faction_SendMessage(factionid, color, msg[], bool:ignoreTog);
stock Faction_ShowPlayerHelp(playerid, type);

stock House_Load(houseid);
stock House_Save(houseid);
stock House_RefreshIcon(houseid);
stock House_GetNextFreeID();
stock House_Create(houseid, price, level, Float:doorX, Float:doorY, Float:doorZ, Float:interiorX, Float:interiorY, Float:interiorZ, Float:interiorR, vwdoor, intdoor, vw, int);
stock House_Delete(houseid);
stock House_GetOwnerID(houseid);
stock House_ShowPlayerHelp(playerid);

stock Business_Load(businessid);
stock Business_Save(businessid);
stock Business_RefreshIcon(businessid);
stock Business_GetNextFreeID();
stock Business_Create(businessid, price, level, Float:doorX, Float:doorY, Float:doorZ, Float:interiorX, Float:interiorY, Float:interiorZ, Float:interiorR, vwdoor, intdoor, vw, int, type);
stock Business_Delete(businessid);
stock Business_ShowProducts(playerid, businessid);
stock Business_GetOwnerID(businessid);

stock Vehicle_LoadAllStatic();
stock Vehicle_GetScriptID(sampVehicleid);
stock Vehicle_GetFactionID(vehicleid);
stock Vehicle_GetJobID(vehicleid);
stock Vehicle_GetOwnerID(vehicleid);
stock Vehicle_GetDealershipPrice(modelid);
stock Vehicle_GetTankSize(modelid);
stock Vehicle_GetTrunkSize(modelid);
stock Vehicle_GetFuelTypeString(modelid);
stock Vehicle_GetFuelType(modelid);
stock Vehicle_GetFuelEconomy(modelid);
stock Vehicle_GetNextFreeSlot();
stock Vehicle_GeneratePlate();
stock Vehicle_Create(model, owner, Float: spawnX, Float: spawnY, Float: spawnZ, Float: spawnR, color1, color2, plate[], fuel);
stock Vehicle_CreateSpawn(vehicleid, model, owner, Float: SpawnX, Float: SpawnY, Float: SpawnZ, Float: SpawnR, color1, color2, plate[32], fuel, job, faction, gps, Float: mileage, lockLevel, alarmLevel, immobLevel);
stock Vehicle_Despawn(vehicleid);
stock Vehicle_Save(vehScriptID);
stock Vehicle_ResetTrunk(vehScriptID);
stock Vehicle_ShowTrunk(playerid, vehScriptID);
stock Vehicle_RemoveItemFromTrunk(vehScriptID, itemid);
stock Vehicle_FuelDecreaser(playerid);
stock Vehicle_UsesFuel(modelid);
stock Vehicle_DontHaveEngine(modelid);
stock Vehicle_DontHaveWindows(modelid);
stock Vehicle_HasWindowDown(vehicleid);
stock Vehicle_StartRefueling(playerid, vehicleid, fuelType, businessid, tankSize);
stock Vehicle_FinishRefuel(playerid, vehicleid, businessid, fuelType);
stock Vehicle_IsStatic(vehScriptID);
stock Vehicle_StartBreakin(playerid, vehicleid);
stock Vehicle_GetLockLevel(vehScriptID);
stock Vehicle_GetLockLevelTime(vehScriptID);
stock Vehicle_GetAlarmLevel(vehScriptID);
stock Vehicle_GetImmobLevel(vehScriptID);
stock Vehicle_GetImmobLevelTime(vehScriptID);
stock Vehicle_TriggerAlarm(vehicleid);
stock Vehicle_StopAlarm(vehicleid);
stock Vehicle_StartHotwire(playerid, vehicleid);
stock Vehicle_Delete(playerid, vehSQLID);
stock Vehicle_ShowVehicleHelp(playerid);

stock Cellphone_DialNumber(playerid, phNumber);
stock Cellphone_DialStaticNumber(playerid, phNumber);
stock Cellphone_GetOwner(phNumber);
stock Cellphone_IsInCall(playerid);
stock Cellphone_IsOnline(playerid);
stock Cellphone_FinishCall(playerid);
stock Cellphone_StartCall(playerid, targetid);
stock Cellphone_SendSms(senderNumber, receiverNumber, message[]);
stock Cellphone_GetContactName(playerid, phNumber);
stock Cellphone_IsStatic(phNumber);
stock Cellphone_ShowContactList(playerid);
stock Cellphone_CreateContact(playerid, phNumber, name[]);
stock Cellphone_ShowCellphoneHelp(playerid);

stock Anticheat_CheckWeapons(playerid);
stock Anticheat_SetDelay(playerid, seconds);


IsNumeric(const string[])
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0') return 0;
    }
    return 1;
}

stock RemoverAlpha(color) {
    return (color & ~0xFF);
}

stock GetVehicleName(modelid)
{
    new String[20];
    format(String,sizeof(String),"%s",VehicleNames[modelid - 400]);
    return String;
}

stock randomString(strDest[], strLen = 10){
    while(strLen--)
        strDest[strLen] = random(2) ? (random(26) + (random(2) ? 'a' : 'A')) : (random(10) + '0');
}

stock GetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2){
    return floatround(floatsqroot(((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)) + ((z1 - z2) * (z1 - z2))));
}

stock GetWeaponSlot(weaponid){
    new slot;
    switch(weaponid){
        case 0,1: slot = 0;
        case 2 .. 9: slot = 1;
        case 10 .. 15: slot = 10;
        case 16 .. 18, 39: slot = 8;
        case 22 .. 24: slot =2;
        case 25 .. 27: slot = 3;
        case 28, 29, 32: slot = 4;
        case 30, 31: slot = 5;
        case 33, 34: slot = 6;
        case 35 .. 38: slot = 7;
        case 40: slot = 12;
        case 41 .. 43: slot = 9;
        case 44 .. 46: slot = 11;
    }
    return slot;
}
