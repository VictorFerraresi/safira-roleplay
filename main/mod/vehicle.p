// system_vehicle | Victor Hugo Palmieri Ferraresi

#include "lib\YSI\y_hooks"

//Funções
Vehicle_LoadAllStatic(){
    new szTemp[50];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `vehicle` where `static` = 1");
    new 
        Cache:result = mysql_query(hSQL, szTemp),
        index = 0,
        rows = cache_num_rows();

    while(index < rows){
        gVehicleData[index][vSQLID] = cache_get_field_content_int(index, "id_vehicle", hSQL);
        gVehicleData[index][vModel] = cache_get_field_content_int(index, "model", hSQL);
        gVehicleData[index][vSpawnX] = cache_get_field_content_float(index, "spawnX", hSQL);
        gVehicleData[index][vSpawnY] = cache_get_field_content_float(index, "spawnY", hSQL);
        gVehicleData[index][vSpawnZ] = cache_get_field_content_float(index, "spawnZ", hSQL);
        gVehicleData[index][vSpawnR] = cache_get_field_content_float(index, "spawnR", hSQL);
        gVehicleData[index][vColor1] = cache_get_field_content_int(index, "color1", hSQL);
        gVehicleData[index][vColor2] = cache_get_field_content_int(index, "color2", hSQL);
        gVehicleData[index][vStatic] = 1;
        gVehicleData[index][vFaction] = cache_get_field_content_int(index, "faction", hSQL);
        gVehicleData[index][vJob] = cache_get_field_content_int(index, "job", hSQL);
        gVehicleData[index][vGPS] = cache_get_field_content_int(index, "gps", hSQL);
        gVehicleData[index][vMileage] = cache_get_field_content_float(index, "mileage", hSQL);
        gVehicleData[index][vLockLevel] = cache_get_field_content_int(index, "lockLevel", hSQL);
        gVehicleData[index][vAlarmLevel] = cache_get_field_content_int(index, "alarmLevel", hSQL);
        gVehicleData[index][vImmobLevel] = cache_get_field_content_int(index, "immobLevel", hSQL);
        gVehicleData[index][vDestroyed] = cache_get_field_content_int(index, "destroyed", hSQL);
        cache_get_field_content(index, "plate", gVehicleData[index][vPlate], hSQL, 32);

        gVehicleData[index][vID] = CreateVehicle(gVehicleData[index][vModel], gVehicleData[index][vSpawnX], gVehicleData[index][vSpawnY],
         gVehicleData[index][vSpawnZ], gVehicleData[index][vSpawnR], gVehicleData[index][vColor1], gVehicleData[index][vColor2], -1);

        SetVehicleNumberPlate(gVehicleData[index][vID], gVehicleData[index][vPlate]);

        gVehicleData[index][vSpawned] = 1;
        gVehicleData[index][vConsumption] = Vehicle_GetFuelEconomy(gVehicleData[index][vModel]);

        index++;
    }

    cache_delete(result);

    printf("[DEBUG] %d Veículos estáticos carregados.", index);

    return 1;
}

Vehicle_GetScriptID(sampVehicleid){
    for(new i = 0; i < MAX_VEHICLES; i++){
        if(gVehicleData[i][vID] == sampVehicleid)
            return i;        
    }
    return -1;
}

Vehicle_GetScriptIDFromSql(sqlVehicleid){
    for(new i = 0; i < MAX_VEHICLES; i++){
        if(gVehicleData[i][vSQLID] == sqlVehicleid){
            return i;
        }
    }
    return -1;
}

Vehicle_GetFactionID(vehicleid){
    return gVehicleData[vehicleid][vFaction];
}

Vehicle_GetJobID(vehicleid){
    return gVehicleData[vehicleid][vJob];
}

Vehicle_GetOwnerID(vehicleid){
    return gVehicleData[vehicleid][vOwner];
}

Vehicle_GetDealershipPrice(modelid){
    new szTemp[64];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `price` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new price = cache_get_field_content_int(0, "price", hSQL);
    cache_delete(result);

    return price;
}

Vehicle_GetTankSize(modelid){
    new szTemp[64];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `tank` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new tank = cache_get_field_content_int(0, "tank", hSQL);
    cache_delete(result);

    return tank;
}

Vehicle_GetTrunkSize(modelid){
    new szTemp[64];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `trunk` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new trunk = cache_get_field_content_int(0, "trunk", hSQL);
    cache_delete(result);

    return trunk;
}

Vehicle_GetFuelTypeString(modelid){
    new szTemp[64];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `fuelType` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new fuelType = cache_get_field_content_int(0, "fuelType", hSQL);
    cache_delete(result);

    new szFuel[26];

    switch(fuelType){
        case FUEL_GASOLINE: { format(szFuel, sizeof(szFuel), "Gasolina"); }
        case FUEL_ETHANOL: { format(szFuel, sizeof(szFuel), "Álcool"); }
        case FUEL_FLEX: { format(szFuel, sizeof(szFuel), "Flex"); }
        case FUEL_DIESEL: { format(szFuel, sizeof(szFuel), "Diesel"); }
        case FUEL_KEROSENE: { format(szFuel, sizeof(szFuel), "Querosene"); }
        default: { format(szFuel, sizeof(szFuel), "Desconhecido"); }
    }

    return szFuel;
}

Vehicle_GetFuelType(modelid){
    new szTemp[64];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `fuelType` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new fuelType = cache_get_field_content_int(0, "fuelType", hSQL);
    cache_delete(result);

    return fuelType;
}

Vehicle_GetFuelEconomy(modelid){
    new szTemp[70];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `consumption` from `vehicle_model_info` where `model` = %d", modelid);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    new consumption = cache_get_field_content_int(0, "consumption", hSQL);
    cache_delete(result);

    return consumption;
}

Vehicle_GetNextFreeSlot(){
    for(new i = 0; i < MAX_VEHICLES; i++){
        if(gVehicleData[i][vID] == 0)
            return i;
    }
    return -1;
}

Vehicle_GeneratePlate(){
    new 
        plate[9],
        szTemp[64];

    format(plate, sizeof(plate), "%s%s%s-%d%d%d%d", LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], LetterList[random(sizeof(LetterList))], 
        random(10), random(10), random(10), random(10));

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select `id_vehicle` from `vehicle` where `plate` = '%s'", plate);
    new
        Cache:result = mysql_query(hSQL, szTemp);

    if(cache_num_rows() > 0){
        Vehicle_GeneratePlate();
    }

    cache_delete(result);

    return plate;
}

Vehicle_Create(model, owner, Float: spawnX, Float: spawnY, Float: spawnZ, Float: spawnR, color1, color2, plate[], fuel){
    new 
      temp[512];

    mysql_format(hSQL, temp, sizeof(temp), "insert into `vehicle` \
     (`model`, \
      `id_character`, \
      `spawnX`, \
      `spawnY`, \
      `spawnZ`, \
      `spawnR`, \
      `color1`, \
      `color2`, \
      `plate`, \
      `fuel`) VALUES ('%d', '%d', '%f', '%f', '%f', '%f', '%d', '%d', '%s', '%d')",
    model,
    owner,
    spawnX,
    spawnY,
    spawnZ,
    spawnR,
    color1,
    color2,
    plate,
    fuel);

    mysql_query(hSQL, temp);

    return 1;
}

Vehicle_CreateSpawn(vehicleid, model, owner, Float: SpawnX, Float: SpawnY, Float: SpawnZ, Float: SpawnR, color1, color2, plate[32], fuel, job, faction, gps, Float: mileage, lockLevel, alarmLevel, immobLevel){
    new 
        index = Vehicle_GetNextFreeSlot(),
        szTemp[70];     

    gVehicleData[index][vSQLID] = vehicleid;
    gVehicleData[index][vModel] = model;
    gVehicleData[index][vOwner] = owner;
    gVehicleData[index][vSpawnX] = SpawnX;
    gVehicleData[index][vSpawnY] = SpawnY;
    gVehicleData[index][vSpawnZ] = SpawnZ;
    gVehicleData[index][vSpawnR] = SpawnR;
    gVehicleData[index][vColor1] = color1;
    gVehicleData[index][vColor2] = color2; 
    gVehicleData[index][vPlate] = plate;
    gVehicleData[index][vFuel] = fuel;
    gVehicleData[index][vJob] = job;
    gVehicleData[index][vFaction] = faction;
    gVehicleData[index][vGPS] = gps;
    gVehicleData[index][vLockLevel] = lockLevel;
    gVehicleData[index][vAlarmLevel] = alarmLevel;
    gVehicleData[index][vImmobLevel] = immobLevel;
    gVehicleData[index][vMileage] = mileage;
    gVehicleData[index][vConsumption] = Vehicle_GetFuelEconomy(model);
    gVehicleData[index][vSpawned] = 1;
    gVehicleData[index][vEngine] = 0;
    gVehicleData[index][vTrunk] = 0;
    gVehicleData[index][vTrunkSize] = Vehicle_GetTrunkSize(model);

    mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `vehicle_trunk_item` where `id_vehicle` = '%d'", vehicleid);
    new 
        Cache:result = mysql_query(hSQL, szTemp),
        idx = 0,
        rows = cache_num_rows();

    while(idx < rows){
        new 
            varName[40];

        format(varName, sizeof(varName), "trunk_%d_item_%d_id", index, idx);
        SetGVarInt(varName, cache_get_field_content_int(idx, "id_item", hSQL));

        format(varName, sizeof(varName), "trunk_%d_item_%d_vehicle", index, idx);
        SetGVarInt(varName, cache_get_field_content_int(idx, "id_vehicle", hSQL));

        format(varName, sizeof(varName), "trunk_%d_item_%d_type", index, idx);
        SetGVarInt(varName, cache_get_field_content_int(idx, "type", hSQL));

        format(varName, sizeof(varName), "trunk_%d_item_%d_model", index, idx);
        SetGVarInt(varName, cache_get_field_content_int(idx, "model", hSQL));

        format(varName, sizeof(varName), "trunk_%d_item_%d_amount", index, idx);
        SetGVarInt(varName, cache_get_field_content_int(idx, "amount", hSQL));

        idx ++;
    }

    cache_delete(result);

    if(job != 0 || faction != 0)
        gVehicleData[index][vLocked] = 0;
    else
        gVehicleData[index][vLocked] = 1;

    new enginestatus = 0;

    if(Vehicle_DontHaveEngine(gVehicleData[index][vModel]))
        enginestatus = 1;    

    gVehicleData[index][vID] = CreateVehicle(gVehicleData[index][vModel], gVehicleData[index][vSpawnX], gVehicleData[index][vSpawnY],
         gVehicleData[index][vSpawnZ], gVehicleData[index][vSpawnR], gVehicleData[index][vColor1], gVehicleData[index][vColor2], -1);

    SetVehicleNumberPlate(gVehicleData[index][vID], gVehicleData[index][vPlate]);

    new
        engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(gVehicleData[index][vID], engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(gVehicleData[index][vID], enginestatus, lights, alarm, gVehicleData[index][vLocked], bonnet, boot, objective);

    return 1;

}

Vehicle_Despawn(vehicleid){
    new vehScriptID = Vehicle_GetScriptID(vehicleid);

    Vehicle_Save(vehScriptID);    
    DestroyVehicle(vehicleid);

    gVehicleData[vehScriptID][vSQLID] = 0;
    gVehicleData[vehScriptID][vID] = 0;
    gVehicleData[vehScriptID][vModel] = 0;
    gVehicleData[vehScriptID][vOwner] = 0;
    gVehicleData[vehScriptID][vSpawnX] = 0.0;
    gVehicleData[vehScriptID][vSpawnY] = 0.0;
    gVehicleData[vehScriptID][vSpawnZ] = 0.0;
    gVehicleData[vehScriptID][vSpawnR] = 0.0;
    gVehicleData[vehScriptID][vColor1] = 0;
    gVehicleData[vehScriptID][vColor2] = 0;
    gVehicleData[vehScriptID][vFuel] = 0;
    gVehicleData[vehScriptID][vActualRefuel] = 0;
    gVehicleData[vehScriptID][vJob] = 0;
    gVehicleData[vehScriptID][vFaction] = 0;
    gVehicleData[vehScriptID][vSpawned] = 0;
    gVehicleData[vehScriptID][vEngine] = 0;
    gVehicleData[vehScriptID][vLocked] = 0;
    gVehicleData[vehScriptID][vGPS] = 0;
    gVehicleData[vehScriptID][vLockLevel] = 0;
    gVehicleData[vehScriptID][vAlarmLevel] = 0;
    gVehicleData[vehScriptID][vImmobLevel] = 0;
    gVehicleData[vehScriptID][vMileage] = 0.0;
    gVehicleData[vehScriptID][vConsumption] = 0;
    gVehicleData[vehScriptID][vLastFuelMileage] = 0;
    gVehicleData[vehScriptID][vDestroyed] = 0;
    gVehicleData[vehScriptID][vTrunk] = 0;
    gVehicleData[vehScriptID][vTrunkSize] = 0;

    for(new i = 0; i < C_MAX_TRUNK_SIZE; i++){
        new
            varName[40];

        format(varName, sizeof(varName), "trunk_%d_item_%d_id", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_vehicle", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, i);
        DeleteGVar(varName);
    }
    return 1;
}

Vehicle_Save(vehScriptID){
    new szTemp[600];

    mysql_format(hSQL, szTemp, sizeof(szTemp), "update `vehicle` set\
     `model` = '%d',\
     `id_character` = '%d',\
     `spawnX` = '%f',\
     `spawnY` = '%f',\
     `spawnZ` = '%f',\
     `spawnR` = '%f',\
     `color1` = '%d',\
     `color2` = '%d',\
     `plate` = '%s',\
     `fuel` = '%d',\
     `job` = '%d',\
     `faction` = '%d',\
     `static` = '%d',\
     `gps` = '%d',\
     `mileage` = '%f',\
     `lockLevel` = '%d',\
     `alarmLevel` = '%d',\
     `immobLevel` = '%d',\
     `destroyed` = '%d'\
      where `id_vehicle` = '%d'",
    gVehicleData[vehScriptID][vModel],
    gVehicleData[vehScriptID][vOwner],
    gVehicleData[vehScriptID][vSpawnX],
    gVehicleData[vehScriptID][vSpawnY],
    gVehicleData[vehScriptID][vSpawnZ],
    gVehicleData[vehScriptID][vSpawnR],
    gVehicleData[vehScriptID][vColor1],
    gVehicleData[vehScriptID][vColor2],
    gVehicleData[vehScriptID][vPlate],
    gVehicleData[vehScriptID][vFuel],
    gVehicleData[vehScriptID][vJob],
    gVehicleData[vehScriptID][vFaction],
    gVehicleData[vehScriptID][vStatic],
    gVehicleData[vehScriptID][vGPS],
    gVehicleData[vehScriptID][vMileage],
    gVehicleData[vehScriptID][vLockLevel],
    gVehicleData[vehScriptID][vAlarmLevel],
    gVehicleData[vehScriptID][vImmobLevel],
    gVehicleData[vehScriptID][vDestroyed],
    gVehicleData[vehScriptID][vSQLID]);

    mysql_query(hSQL, szTemp);
    return 1;
}

Vehicle_ResetTrunk(vehScriptID){
    for(new i = 0; i < C_MAX_TRUNK_SIZE; i++){
        new
            varName[40];

        format(varName, sizeof(varName), "trunk_%d_item_%d_id", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_vehicle", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, i);
        DeleteGVar(varName);

        format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, i);
        DeleteGVar(varName);
    }
    new szTemp[64];
    mysql_format(hSQL, szTemp, sizeof(szTemp), "delete from `vehicle_trunk_item` where `id_vehicle` = '%d'", gVehicleData[vehScriptID][vSQLID]);

    mysql_query(hSQL, szTemp);
    return 1;
}

Vehicle_ShowTrunk(playerid, vehScriptID){
    new
        varName[30],
        szTitle[40],
        szAux[60],
        szTrunk[1000];

    format(szTitle, sizeof(szTitle), "Porta-Malas de %s", GetVehicleName(gVehicleData[vehScriptID][vModel]));

    for(new i = 0; i < gVehicleData[vehScriptID][vTrunkSize]; i++){
        format(varName, sizeof(varName), "trunk_%d_item_%d_id", vehScriptID, i);

        if(GetGVarType(varName) == GLOBAL_VARTYPE_NONE){
            format(szAux, sizeof(szAux), "Slot Vazio%s", gVehicleData[vehScriptID][vTrunkSize]-i==1 ? ("") : ("\n"));
            strcat(szTrunk, szAux);
        } else {
            new
                type,
                model,                
                amount;

            format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, i);
            type = GetGVarInt(varName);

            format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, i);
            model = GetGVarInt(varName);

            format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, i);
            amount = GetGVarInt(varName);

            if(type == TRUNK_ITEM_TYPE_WEAPON){
                new weapon[25];
                GetWeaponName(model, weapon, sizeof(weapon));
                format(szAux, sizeof(szAux), "%s (Munição: %d)", weapon, amount);
            } else if(type == TRUNK_ITEM_TYPE_DRUG){
                /*new drug[15];
                format(szAux, sizeof(szAux), "%s (Quantia: %d)", drug, amount)*/
            }

            format(szAux, sizeof(szAux), "%s%s", szAux, gVehicleData[vehScriptID][vTrunkSize]-i==1 ? ("\n \n") : ("\n"));
            strcat(szTrunk, szAux);    
        }
    }
    SetPVarInt(playerid, "vehicleTrunk", vehScriptID);
    ShowPlayerDialog(playerid, DIALOG_TRUNK, DIALOG_STYLE_LIST, szTitle, szTrunk, "Selecionar", "Fechar");
    return 1;
}

Vehicle_RemoveItemFromTrunk(vehScriptID, itemid){
    new 
        szTemp[64],
        varName[40];

    format(varName, sizeof(varName), "trunk_%d_item_%d_id", vehScriptID, itemid);
    mysql_format(hSQL, szTemp, sizeof(szTemp), "delete from `vehicle_trunk_item` where `id_item` = '%d'", GetGVarInt(varName));

    mysql_query(hSQL, szTemp);
    DeleteGVar(varName);

    format(varName, sizeof(varName), "trunk_%d_item_%d_vehicle", vehScriptID, itemid);
    DeleteGVar(varName);

    format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, itemid);
    DeleteGVar(varName);

    format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, itemid);
    DeleteGVar(varName);

    format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, itemid);
    DeleteGVar(varName);
    return 1;
}

function Vehicle_MileageIncreaser(playerid){ //Timer
    new 
        vehicleid = GetPlayerVehicleID(playerid),
        vehScriptID = Vehicle_GetScriptID(vehicleid),
        Float:ST[4];

    if(!IsPlayerInAnyVehicle(playerid)){
        if(MileageTimer[playerid] != 0){                    
            KillTimer(MileageTimer[playerid]);    
            MileageTimer[playerid] = 0;                
        }
        return 1;
    }
        
    GetVehicleVelocity(GetPlayerVehicleID(playerid),ST[0],ST[1],ST[2]);

    ST[3] = floatsqroot(floatpower(floatabs(ST[0]), 2.0) + floatpower(floatabs(ST[1]), 2.0) + floatpower(floatabs(ST[2]), 2.0)) * 604.26;
    gVehicleData[vehScriptID][vMileage] += ST[3];

    Vehicle_FuelDecreaser(playerid);

    return floatround(ST[3]);
}

Vehicle_FuelDecreaser(playerid){
    new 
        vehicleid = GetPlayerVehicleID(playerid),
        vehScriptID = Vehicle_GetScriptID(vehicleid);

    if(gVehicleData[vehScriptID][vLastFuelMileage] != floatround((gVehicleData[vehScriptID][vMileage]/2000), floatround_floor)){
        gVehicleData[vehScriptID][vLastFuelMileage] = floatround((gVehicleData[vehScriptID][vMileage]/2000), floatround_floor);
        new rest = gVehicleData[vehScriptID][vLastFuelMileage] % gVehicleData[vehScriptID][vConsumption];

        if(rest == 0){
            gVehicleData[vehScriptID][vFuel] --;
            if(gVehicleData[vehScriptID][vFuel] == 5){
                SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] O combustível do seu veículo está na reserva.");
            } else if(gVehicleData[vehScriptID][vFuel] <= 0){
                if(MileageTimer[playerid] != 0){                                        
                    KillTimer(MileageTimer[playerid]);              
                    MileageTimer[playerid] = 0;      
                }
                SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] O combustível do seu veículo acabou e ele desligou.");
                new
                    engine,
                    lights,
                    alarm,
                    doors,
                    bonnet,
                    boot,
                    objective;
                GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
                SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
                gVehicleData[vehScriptID][vEngine] = 0;
            }
        }
    }
    return 1;
}

Vehicle_UsesFuel(modelid){
    for(new i = 0; i < sizeof(VehiclesWithoutFuel); i++){
        if(VehiclesWithoutFuel[i] == modelid){
            return 0;
        }
    }
    return 1;
}

Vehicle_DontHaveEngine(modelid){
    for(new i = 0; i < sizeof(VehiclesWithoutEngine); i++){
        if(VehiclesWithoutEngine[i] == modelid){
            return 1;
        }
    }
    return 0;
}

Vehicle_DontHaveWindows(modelid){
    for(new i = 0; i < sizeof(VehiclesWithoutWindows); i++){
        if(VehiclesWithoutWindows[i] == modelid){
            return 1;
        }
    }
    return 0;
}

Vehicle_HasWindowDown(vehicleid){
    new 
        driver,
        passenger,
        backleft,
        backright;

    GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, backright);

    if(driver != 0 && passenger != 0 && backleft != 0 && backright != 0){
        return 0;
    }
    
    return 1;
}

Vehicle_StartRefueling(playerid, vehicleid, fuelType, businessid, tankSize){
    new
        vehFuelType = Vehicle_GetFuelType(GetVehicleModel(vehicleid)),
        price;

    switch(fuelType){
        case FUEL_GASOLINE: price = gBusinessData[businessid][bFuelPrice][FUEL_GASOLINE];
        case FUEL_ETHANOL: price = gBusinessData[businessid][bFuelPrice][FUEL_ETHANOL];
        case FUEL_DIESEL: price = gBusinessData[businessid][bFuelPrice][FUEL_DIESEL];
        case FUEL_KEROSENE: price = gBusinessData[businessid][bFuelPrice][FUEL_KEROSENE];
        default: price = 999;
    }

    if(Player_GetMoney(playerid) < price)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro suficiente para um litro.");

    if(vehFuelType != FUEL_FLEX && fuelType != vehFuelType){ //Combustivel incompativel (Carro à Gasolina, Etanol, Diesel ou Querosene)
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você abasteceu o seu veículo com combustível incompatível e ele parou de funcionar.");
        SendClientMessage(playerid, C_COLOR_WARNING, "AVISA O VIIH PRA QUANDO TIVER SISTEMA DE QUEBRAR CARRO, SETAR A VIDA DELE PRA 250 AQUI");
    } else if(vehFuelType == FUEL_FLEX && fuelType != FUEL_GASOLINE && fuelType != FUEL_ETHANOL){ //Combustivel incompativel (Carro flex)
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você abasteceu o seu veículo com combustível incompatível e ele parou de funcionar.");
        SendClientMessage(playerid, C_COLOR_WARNING, "AVISA O VIIH PRA QUANDO TIVER SISTEMA DE QUEBRAR CARRO, SETAR A VIDA DELE PRA 250 AQUI");
    } else { //Combustível compatível, proceder com abastecimento
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você está abastecendo seu veículo. Pressione BARRA DE ESPAÇO para parar de abastecer.");
        gPlayerData[playerid][pVehRefueling] = vehicleid;
        gPlayerData[playerid][pBusinessRefueling] = businessid;
        gPlayerData[playerid][pRefuelingType] = fuelType;

        RefuelingTimer[playerid] = SetTimerEx("Vehicle_FuelIncreaser", 500, true, "iii", playerid, price, tankSize);    
    }

    return 1;
}

function Vehicle_FuelIncreaser(playerid, price, tankSize){
    new
        vehScriptID = Vehicle_GetScriptID(gPlayerData[playerid][pVehRefueling]);

    if(Player_GetMoney(playerid) < price*gVehicleData[vehScriptID][vActualRefuel]){
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você não possui mais dinheiro para continuar abastecendo.");
        Vehicle_FinishRefuel(playerid, gPlayerData[playerid][pVehRefueling], gPlayerData[playerid][pBusinessRefueling], gPlayerData[playerid][pRefuelingType]);
        return 1;
    }

    if(gVehicleData[vehScriptID][vFuel] >= tankSize){
        Vehicle_FinishRefuel(playerid, gPlayerData[playerid][pVehRefueling], gPlayerData[playerid][pBusinessRefueling], gPlayerData[playerid][pRefuelingType]);
        gVehicleData[vehScriptID][vFuel] = tankSize;
        return 1;
    }        

    gVehicleData[vehScriptID][vFuel]++;
    gVehicleData[vehScriptID][vActualRefuel]++;
    return 1;
}

Vehicle_FinishRefuel(playerid, vehicleid, businessid, fuelType){
    if(RefuelingTimer[playerid] != 0){
        KillTimer(RefuelingTimer[playerid]);
        RefuelingTimer[playerid] = 0;
    }

    new
        szFuelFinish[128],
        vehScriptID = Vehicle_GetScriptID(vehicleid),
        price = gVehicleData[vehScriptID][vActualRefuel]*gBusinessData[businessid][bFuelPrice][fuelType];


    format(szFuelFinish, sizeof(szFuelFinish), "[INFO] Você abasteceu seu veículo com %d Litros de combustível por {74BF75}$%d.", gVehicleData[vehScriptID][vActualRefuel], price);
    SendClientMessage(playerid, C_COLOR_SUCCESS, szFuelFinish);

    gVehicleData[vehScriptID][vActualRefuel] = 0;
    gBusinessData[businessid][bSafe] += price;    
    Player_GiveMoney(playerid, -price);

    if(Player_GetMoney(playerid) < 0)
        Player_GiveMoney(playerid, Player_GetMoney(playerid)*-1);

    gPlayerData[playerid][pVehRefueling] = 0;
    gPlayerData[playerid][pBusinessRefueling] = 0;
    gPlayerData[playerid][pRefuelingType] = 0;
    return 1;
}

Vehicle_IsStatic(vehScriptID){
    return gVehicleData[vehScriptID][vStatic];
}

Vehicle_StartBreakin(playerid, vehicleid){
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid);
    
    gPlayerData[playerid][pVehBreakingIn] = vehicleid;
    gPlayerData[playerid][pVehBreakingInTime] = Vehicle_GetLockLevelTime(vehScriptID);

    HotwireTimer[playerid] = SetTimerEx("Vehicle_BreakinProgress", 1000, true, "ii", playerid, vehicleid);

    if(Vehicle_GetAlarmLevel(vehScriptID) > 0)
        Vehicle_TriggerAlarm(vehicleid);

    return 1;
}

function Vehicle_BreakinProgress(playerid, vehicleid){
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid);

    if(gPlayerData[playerid][pVehBreakingInTime] <= 0){        
        gVehicleData[vehScriptID][vLocked] = 0;

        new
            engine,
            lights,
            alarm,
            doors,
            bonnet,
            boot,
            objective;

        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, engine, lights, alarm, 0, bonnet, boot, objective);

        gPlayerData[playerid][pVehBreakingIn] = 0;                    
        gPlayerData[playerid][pVehBreakingInTime] = 0;
        if(HotwireTimer[playerid] != 0){
            KillTimer(HotwireTimer[playerid]);
            HotwireTimer[playerid] = 0;
        }

        GameTextForPlayer(playerid, "~g~Veiculo destrancado", 3000, 3);
        PlayerPlaySound(playerid, 1145, 0.0, 0.0, 0.0);
    } else {
        new
            Float:carX,
            Float:carY,
            Float:carZ;

        GetVehiclePos(vehicleid, carX, carY, carZ);

        if(!IsPlayerInRangeOfPoint(playerid, 5.0, carX, carY, carZ)){
            gPlayerData[playerid][pVehBreakingIn] = 0;                    
            gPlayerData[playerid][pVehBreakingInTime] = 0;
            if(HotwireTimer[playerid] != 0){
                KillTimer(HotwireTimer[playerid]);
                HotwireTimer[playerid] = 0;
            }
            GameTextForPlayer(playerid, "~r~Voce se afastou demais do veiculo", 3000, 3);
        } else {
            new
                szUnlock[30];

            gPlayerData[playerid][pVehBreakingInTime] --;
            format(szUnlock, sizeof(szUnlock), "~g~%d ~w~Segundos", gPlayerData[playerid][pVehBreakingInTime]);
            GameTextForPlayer(playerid, szUnlock, 1300, 3);
        }
    }    
    return 1;
}

Vehicle_GetLockLevel(vehScriptID){
    return gVehicleData[vehScriptID][vLockLevel];
}

Vehicle_GetLockLevelTime(vehScriptID){
    new
        time;
    switch(Vehicle_GetLockLevel(vehScriptID)){
        case 0: time = 60;
        case 1: time = 120;
        case 2: time = 240;
        case 3: time = 480;
        case 4: time = 600;
        default: time = 60;
    }  
    return time;  
}

Vehicle_GetAlarmLevel(vehScriptID){
    return gVehicleData[vehScriptID][vAlarmLevel];
}

Vehicle_GetImmobLevel(vehScriptID){
    return gVehicleData[vehScriptID][vImmobLevel];
}

Vehicle_GetImmobLevelTime(vehScriptID){
    new
        time;
    switch(Vehicle_GetImmobLevel(vehScriptID)){
        case 0: time = 60;
        case 1: time = 120;
        case 2: time = 240;
        case 3: time = 480;
        case 4: time = 600;
        default: time = 60;
    }  
    return time;      
}

Vehicle_TriggerAlarm(vehicleid){
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid),
        level = Vehicle_GetAlarmLevel(vehScriptID),
        engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(level >= 1){ //Alarme
        SetVehicleParamsEx(vehicleid, engine, lights, 1, doors, bonnet, boot, objective);
        SetTimerEx("Vehicle_StopAlarm", 20000, false, "i", vehicleid); //SAMP Fix

        new szAction[70];
        format(szAction, sizeof(szAction), "* O alarme do veículo está disparado ((%s))", GetVehicleName(GetVehicleModel(vehicleid)));
        ProxDetectorVehicle(15.0, vehicleid, szAction, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION, C_COLOR_ACTION);    
    } 
    if(level >= 2){ //Alarme + SMS
        for(new i = 0; i < GetMaxPlayers(); i++){
            if(gVehicleData[vehScriptID][vOwner] == Player_DBID(i)){ //Dono está online e é o playerid i
                if(gPlayerData[i][pCellphone] == 0) break;                
                new
                    szAlarm[80],
                    zone[MAX_ZONE_NAME];

                GetVehicle2DZone(gVehicleData[vehScriptID][vID], zone, MAX_ZONE_NAME);
                format(szAlarm, sizeof(szAlarm), "O alarme de seu %s disparou em %s.", GetVehicleName(GetVehicleModel(vehicleid)), zone);
                Cellphone_SendSms(PHONE_INSURANCE, gPlayerData[i][pCellphone], szAlarm);
                break;
            }
        }        
    } 
    if(level >= 3){ //Alarme + SMS + Polícia
        //Avisar facções policiais
    }

    return 1;
}

function Vehicle_StopAlarm(vehicleid){
    new
        engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    SetVehicleParamsEx(vehicleid, engine, lights, 0, doors, bonnet, boot, objective);  
    return 1;    
}

Vehicle_StartHotwire(playerid, vehicleid){
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid);
    
    gPlayerData[playerid][pVehHotwiring] = vehicleid;
    gPlayerData[playerid][pVehHotwiringTime] = Vehicle_GetImmobLevelTime(vehScriptID);

    HotwireTimer[playerid] = SetTimerEx("Vehicle_HotwireProgress", 1000, true, "ii", playerid, vehicleid);

    if(Vehicle_GetAlarmLevel(vehScriptID) > 0)
        Vehicle_TriggerAlarm(vehicleid);

    return 1;
}

function Vehicle_HotwireProgress(playerid, vehicleid){
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid);

    if(gPlayerData[playerid][pVehHotwiringTime] <= 0){        
        gVehicleData[vehScriptID][vEngine] = 1;

        new
            engine,
            lights,
            alarm,
            doors,
            bonnet,
            boot,
            objective;

        GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);

        gPlayerData[playerid][pVehHotwiring] = 0;                    
        gPlayerData[playerid][pVehHotwiringTime] = 0;
        if(HotwireTimer[playerid] != 0){
            KillTimer(HotwireTimer[playerid]);
            HotwireTimer[playerid] = 0;
        }

        GameTextForPlayer(playerid, "~g~Veiculo ligado", 3000, 3);
    } else {
        if(GetPlayerVehicleID(playerid) != vehicleid){ 
            gPlayerData[playerid][pVehHotwiring] = 0;                    
            gPlayerData[playerid][pVehHotwiringTime] = 0;
            if(HotwireTimer[playerid] != 0){
                KillTimer(HotwireTimer[playerid]);
                HotwireTimer[playerid] = 0;
            }
            GameTextForPlayer(playerid, "~r~Voce saiu do veiculo", 3000, 3);
        } else {
            new
                szUnlock[30];

            gPlayerData[playerid][pVehHotwiringTime] --;
            format(szUnlock, sizeof(szUnlock), "~g~%d ~w~Segundos", gPlayerData[playerid][pVehHotwiringTime]);
            GameTextForPlayer(playerid, szUnlock, 1300, 3);
        }
    }    
    return 1;
}

Vehicle_Delete(playerid, vehSQLID){
    new szTemp[64];
    mysql_format(hSQL, szTemp, sizeof(szTemp), "delete from `vehicle` where `id_vehicle` = '%d'", vehSQLID);
    mysql_query(hSQL, szTemp);
    SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você deletou este veículo com sucesso.");
    return 1;
}

Vehicle_ShowPlayerHelp(playerid){
    SendClientMessage(playerid, C_COLOR_SYNTAX, "______________________________[Comandos Veiculares]______________________________");
    SendClientMessage(playerid, C_COLOR_WHITE, "/v, /motor, /luzes, /janela, /abastecer, /quebrartrava, /ligacaodireta, /portamalas");
    SendClientMessage(playerid, C_COLOR_WHITE, "/capo");
    return 1;
}

//------------------------------------------------------------------------------

//Hooks

hook OnVehicleDeath(vehicleid, killerid){
    #pragma unused killerid
    new
        vehScriptID = Vehicle_GetScriptID(vehicleid);
    if(!Vehicle_IsStatic(vehScriptID)){        
        for(new i = 0; i < GetMaxPlayers(); i++){
            if(Vehicle_GetOwnerID(vehScriptID) == Player_DBID(i)){
                if(gPlayerData[i][pCellphone] != 0){
                    Cellphone_SendSms(PHONE_INSURANCE, gPlayerData[i][pCellphone], "O seu veículo foi destruído. Entre em contato conosco para recuperá-lo.");
                }           
            }
            if(gPlayerData[i][pVehRefueling] == vehicleid){
                Vehicle_FinishRefuel(i, gPlayerData[i][pVehRefueling], gPlayerData[i][pBusinessRefueling], gPlayerData[i][pRefuelingType]);
            }
        }
        gVehicleData[vehScriptID][vDestroyed] = 1;
        Vehicle_ResetTrunk(vehScriptID);
        Vehicle_Despawn(vehicleid);
    }
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]){
    switch(dialogid){
        case DIALOG_CARBUY:{
            if(!response){
                DeletePVar(playerid, "carModelBuying");
                DeletePVar(playerid, "carPriceBuying");
                switch(gBusinessData[gPlayerData[playerid][pInsideBusiness]][bType]){
                    case BTYPE_DEALERSHIP_BOAT: { ShowModelSelectionMenu(playerid, boat_dealer_list, "Barcos"); }
                    case BTYPE_DEALERSHIP_PLANE: { ShowModelSelectionMenu(playerid, plane_dealer_list, "Avioes"); }
                    case BTYPE_DEALERSHIP_MOTORCYCLE: { ShowModelSelectionMenu(playerid, motorcycle_dealer_list, "Motocicletas"); }
                    case BTYPE_DEALERSHIP_INDUSTRY: { ShowModelSelectionMenu(playerid, industry_dealer_list, "Veiculos Industriais"); }
                    case BTYPE_DEALERSHIP_LOW: { ShowModelSelectionMenu(playerid, low_dealer_list, "Veiculos Baratos"); }
                    case BTYPE_DEALERSHIP_MEDIUM: { ShowModelSelectionMenu(playerid, medium_dealer_list, "Veiculos Populares"); }
                    case BTYPE_DEALERSHIP_HIGH: { ShowModelSelectionMenu(playerid, high_dealer_list, "Veiculos de Luxo"); }
                }
                return 1;
            }
            if(Player_GetMoney(playerid) < GetPVarInt(playerid, "carPriceBuying")){
                SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro suficiente para comprar este veículo.");
            } else {
                Player_GiveMoney(playerid, -GetPVarInt(playerid, "carPriceBuying"));
                Player_DealershipGiveVehicle(playerid, GetPVarInt(playerid, "carModelBuying"), gPlayerData[playerid][pInsideBusiness]);
                SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você comprou este veículo com sucesso! (/v lista)");
            }
            DeletePVar(playerid, "carModelBuying");
            DeletePVar(playerid, "carPriceBuying");
            return 1;
        }
        case DIALOG_INSURANCERECOVER:{
            if(!response)
               return SendClientMessage(playerid, C_COLOR_CHATFADE1, "Gravação diz: Estamos sempre à disposição, até logo!");

            new
                vehicleid,
                model,
                Float:price,
                intPrice,
                temp[100];

            mysql_format(hSQL, temp, sizeof(temp), "select id_vehicle, model from `vehicle` where `id_character` = '%d' and `destroyed` = 1 limit %d,1", Player_DBID(playerid), listitem);
            new Cache:result = mysql_query(hSQL, temp);        

            vehicleid = cache_get_field_content_int(0, "id_vehicle", hSQL);
            model = cache_get_field_content_int(0, "model", hSQL);

            price = Vehicle_GetDealershipPrice(model)*0.10;
            intPrice = floatround(price, floatround_floor);    

            cache_delete(result);

            SetPVarInt(playerid, "VehicleRecoverID", vehicleid);
            SetPVarInt(playerid, "VehicleRecoverModel", model);
            SetPVarInt(playerid, "VehicleRecoverPrice", intPrice);

            new
                szTitle[32],
                szRecover[128];

            format(szTitle, sizeof(szTitle), "%s", GetVehicleName(model));
            format(szRecover, sizeof(szRecover), "Você tem certeza que deseja recuperar o seu %s por {009B19}$%d{FFFFFF}?", szTitle, intPrice);

            ShowPlayerDialog(playerid, DIALOG_INSURANCECONFIRM, DIALOG_STYLE_MSGBOX, szTitle, szRecover, "Sim", "Não");
        }
        case DIALOG_INSURANCECONFIRM:{
            if(!response){
                DeletePVar(playerid, "VehicleRecoverID");
                DeletePVar(playerid, "VehicleRecoverModel");
                DeletePVar(playerid, "VehicleRecoverPrice");
                return Player_ShowInsuranceList(playerid);                
            }

            if(Player_GetMoney(playerid) < GetPVarInt(playerid, "VehicleRecoverPrice")){
                DeletePVar(playerid, "VehicleRecoverID");
                DeletePVar(playerid, "VehicleRecoverModel");
                DeletePVar(playerid, "VehicleRecoverPrice");
                return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui dinheiro o suficiente para recuperar este veículo.");
            }

            Player_GiveMoney(playerid, -GetPVarInt(playerid, "VehicleRecoverPrice"));

            new
                szRecovered[100];

            format(szRecovered, sizeof(szRecovered), "[INFO] {FFFFFF}Você recuperou o seu %s por {009B19}$%d{FFFFFF}!", GetVehicleName(GetPVarInt(playerid, "VehicleRecoverModel")), GetPVarInt(playerid, "VehicleRecoverPrice"));
            SendClientMessage(playerid, C_COLOR_SUCCESS, szRecovered);

            new szTemp[80];

            mysql_format(hSQL, szTemp, sizeof(szTemp), "update `vehicle` set `destroyed` = 0 where `id_vehicle` = '%d'", GetPVarInt(playerid, "VehicleRecoverID"));

            mysql_query(hSQL, szTemp);

            DeletePVar(playerid, "VehicleRecoverID");
            DeletePVar(playerid, "VehicleRecoverModel");
            DeletePVar(playerid, "VehicleRecoverPrice");
        }
        case DIALOG_CONFIRMCARDELETE:{
            if(!response){
                DeletePVar(playerid, "DeleteCarID");
                return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você cancelou a deleção do seu veículo.");
            }

            Vehicle_Delete(playerid, GetPVarInt(playerid, "DeleteCarID"));
            DeletePVar(playerid, "DeleteCarID");
        }
        case DIALOG_TRUNK:{
            if(!response){
                DeletePVar(playerid, "vehicleTrunk");
                return 1;
            }

            new 
                varName[40];
            format(varName, sizeof(varName), "trunk_%d_item_%d_id", GetPVarInt(playerid, "vehicleTrunk"), listitem);
            if(GetGVarType(varName) == GLOBAL_VARTYPE_NONE){
                SetPVarInt(playerid, "trunkSlotUsing", listitem);
                ShowPlayerDialog(playerid, DIALOG_TRUNKSTOREOPT, DIALOG_STYLE_LIST, "Selecione uma Opção", "Guardar Arma Atual\nGuardar Drogas", "Confirmar", "Voltar");
            } else {  
                new
                    type,
                    model,
                    amount,
                    vehScriptID = GetPVarInt(playerid, "vehicleTrunk");

                format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, listitem);
                type = GetGVarInt(varName);

                format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, listitem);
                model = GetGVarInt(varName);

                format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, listitem);
                amount = GetGVarInt(varName);            

                if(type == TRUNK_ITEM_TYPE_WEAPON){
                    new
                        slot = GetWeaponSlot(model),
                        actualWeapon,
                        actualAmmo;
                    GetPlayerWeaponData(playerid, slot, actualWeapon, actualAmmo);
                    DeletePVar(playerid, "vehicleTrunk");                    

                    if(actualWeapon != 0){
                        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já possui uma arma neste slot, guarde-a primeiro.");
                    }
                    Player_GiveWeapon(playerid, model, amount);
                    Vehicle_RemoveItemFromTrunk(vehScriptID, listitem);
                } else if(type == TRUNK_ITEM_TYPE_DRUG){
                    //Pergunta a quantidade que ele quer pegar daquela drug
                }
            }
        }
        case DIALOG_TRUNKSTOREOPT:{
            if(!response){
                DeletePVar(playerid, "trunkSlotUsing");
                return Vehicle_ShowTrunk(playerid, GetPVarInt(playerid, "vehicleTrunk"));
            }
            new 
                weapon = GetPlayerWeapon(playerid),
                ammo = GetPlayerAmmo(playerid),
                vehScriptID = GetPVarInt(playerid, "vehicleTrunk"),
                slotUsing = GetPVarInt(playerid, "trunkSlotUsing");

            switch(listitem){                
                case 0:{ //Guardar arma atual                    
                    if(weapon == 0){
                        DeletePVar(playerid, "vehicleTrunk");
                        DeletePVar(playerid, "trunkSlotUsing");
                        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui nenhuma arma em mãos.");
                    } else {
                        Player_RemoveWeapon(playerid, weapon);
                        new
                            varName[40],
                            szTemp[150];

                        format(varName, sizeof(varName), "trunk_%d_item_%d_vehicle", vehScriptID, slotUsing);
                        SetGVarInt(varName, vehScriptID);

                        format(varName, sizeof(varName), "trunk_%d_item_%d_type", vehScriptID, slotUsing);
                        SetGVarInt(varName, TRUNK_ITEM_TYPE_WEAPON);

                        format(varName, sizeof(varName), "trunk_%d_item_%d_model", vehScriptID, slotUsing);
                        SetGVarInt(varName, weapon);

                        format(varName, sizeof(varName), "trunk_%d_item_%d_amount", vehScriptID, slotUsing);
                        SetGVarInt(varName, ammo);

                        mysql_format(hSQL, szTemp, sizeof(szTemp), "insert into `vehicle_trunk_item` (`id_vehicle`, `type`, `model`, `amount`) values ('%d', '%d', '%d', '%d')",
                        gVehicleData[vehScriptID][vSQLID],
                        TRUNK_ITEM_TYPE_WEAPON,
                        weapon,
                        ammo);

                        new Cache:result = mysql_query(hSQL, szTemp);
                        format(varName, sizeof(varName), "trunk_%d_item_%d_id", vehScriptID, slotUsing);

                        SetGVarInt(varName, cache_insert_id());

                        cache_delete(result);

                        DeletePVar(playerid, "trunkSlotUsing");
                        Vehicle_ShowTrunk(playerid, vehScriptID);
                    }
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

//Comandos

CMD:v(playerid, params[]){
    new 
        szParam[30], 
        integerParam,
        integerParam2;

    if(sscanf(params, "s[30]D(-1)D(-1)", szParam, integerParam, integerParam2)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /v [parâmetro] -{C0C0C0} Realiza diversas ações relacionadas aos seus veículos");
        SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETROS] lista, spawn, estacionar, comprarvaga, vender, deletar");
        return 1;
    }

    if(!strcmp(szParam, "lista", true)){
        SendClientMessage(playerid, C_COLOR_YELLOW, "Meus Veículos");        
        Player_ShowVehicles(playerid, playerid);
    }
    else if(!strcmp(szParam, "spawn", true)){
        if(integerParam == -1)
            return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /v spawn [ID] -{C0C0C0} Spawna um de seus veículos");

        new szTemp[128];
        mysql_format(hSQL, szTemp, sizeof(szTemp), "select * from `vehicle` where `id_vehicle` = '%d' AND `id_character` = '%d' limit 1", integerParam, Player_DBID(playerid));
        new Cache:result = mysql_query(hSQL, szTemp);

        if(!cache_get_row_count()){            
            cache_delete(result);
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um ID de veículo inválido! (/v lista)");
        }

        new scriptID = Vehicle_GetScriptIDFromSql(integerParam);

        if(scriptID != -1 && gVehicleData[scriptID][vSpawned] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo já está spawnado.");

        if(cache_get_field_content_int(0, "destroyed", hSQL) == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo está destruido, entre em contato com a sua seguradora (/ligar 5556321).");

        new
            model,
            Float: SpawnX,
            Float: SpawnY,
            Float: SpawnZ,
            Float: SpawnR,
            color1,
            color2,
            plate[32],
            fuel,
            job,
            faction,
            gps,
            mileage,
            lockLevel,
            alarmLevel,
            immobLevel;

        model = cache_get_field_content_int(0, "model", hSQL);
        SpawnX = cache_get_field_content_float(0, "spawnX", hSQL);
        SpawnY = cache_get_field_content_float(0, "spawnY", hSQL);
        SpawnZ = cache_get_field_content_float(0, "spawnZ", hSQL);
        SpawnR = cache_get_field_content_float(0, "spawnR", hSQL);
        color1 = cache_get_field_content_int(0, "color1", hSQL);    
        color2 = cache_get_field_content_int(0, "color2", hSQL);
        cache_get_field_content(0, "plate", plate, hSQL, 32);
        fuel = cache_get_field_content_int(0, "fuel", hSQL);
        job = cache_get_field_content_int(0, "job", hSQL);
        faction = cache_get_field_content_int(0, "faction", hSQL);
        gps = cache_get_field_content_int(0, "gps", hSQL);
        mileage = cache_get_field_content_int(0, "mileage", hSQL);
        lockLevel = cache_get_field_content_int(0, "lockLevel", hSQL);
        alarmLevel = cache_get_field_content_int(0, "alarmLevel", hSQL);
        immobLevel = cache_get_field_content_int(0, "immobLevel", hSQL);

        Vehicle_CreateSpawn(integerParam, model, Player_DBID(playerid), SpawnX, SpawnY, SpawnZ, SpawnR, color1, color2, plate, fuel, job, faction, gps, mileage, lockLevel, alarmLevel, immobLevel);        

        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você spawnou o seu veículo com sucesso!");

        cache_delete(result);
    }
    else if(!strcmp(szParam, "estacionar", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

        new
            vehid = GetPlayerVehicleID(playerid),
            vehScriptID = Vehicle_GetScriptID(vehid);

        if(Vehicle_GetOwnerID(vehScriptID) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário deste veículo.");

        if(gPlayerData[playerid][pVehRefueling] == vehid)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode estacionar um veículo que está sendo abastecido.");

        if(!IsPlayerInRangeOfPoint(playerid, 5.0, gVehicleData[vehScriptID][vSpawnX], gVehicleData[vehScriptID][vSpawnY], gVehicleData[vehScriptID][vSpawnZ])){
            SetPlayerCheckpoint(playerid, gVehicleData[vehScriptID][vSpawnX], gVehicleData[vehScriptID][vSpawnY], gVehicleData[vehScriptID][vSpawnZ], 5.0);
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está proximo à vaga deste veículo.");
        }

        Vehicle_Despawn(vehid);
    
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você estacionou o seu veículo com sucesso!");        
    }
    else if(!strcmp(szParam, "comprarvaga", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

        new
            vehid = GetPlayerVehicleID(playerid),
            vehScriptID = Vehicle_GetScriptID(vehid);

        if(Vehicle_GetOwnerID(vehScriptID) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário deste veículo.");

        if(Player_GetMoney(playerid) < 1000)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui {009B19}$1000 {D61B1B}para comprar uma vaga.");

        if(gPlayerData[playerid][pVehRefueling] == vehid)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode estacionar um veículo que está sendo abastecido.");

        Player_GiveMoney(playerid, -1000);
        GetVehiclePos(vehid, gVehicleData[vehScriptID][vSpawnX], gVehicleData[vehScriptID][vSpawnY], gVehicleData[vehScriptID][vSpawnZ]);
        GetVehicleZAngle(vehid, gVehicleData[vehScriptID][vSpawnR]);

        Vehicle_Despawn(vehid);
    
        SendClientMessage(playerid, C_COLOR_SUCCESS, "[INFO] Você comprou esta vaga com sucesso!");        
    } 
    else if(!strcmp(szParam, "vender", true)){
        if(integerParam == -1 || integerParam2 == -1)
            return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /v vender [playerid] [preço] -{C0C0C0} Vende o seu veículo para outro jogador");   

        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

        new
            vehid = GetPlayerVehicleID(playerid),
            vehScriptID = Vehicle_GetScriptID(vehid);

        if(Vehicle_GetOwnerID(vehScriptID) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não é o proprietário deste veículo."); 

        if(!IsPlayerConnected(integerParam) || !Player_Logged(integerParam))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este jogador não está conectado!"); //NOT_CONNECTED não pude usar por algum motivo (não compila)
        if(playerid == integerParam)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode utilizar este comando em você mesmo!"); //NOT_SELF não pude usar por algum motivo (não compila)
        if(!Player_IsNearPlayer(5.0, playerid, integerParam))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está próximo à este jogador.");
        if(integerParam2 < 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve escolher um preço acima de zero.");

        SetPVarInt(integerParam, "playerSellingCar", playerid);
        SetPVarInt(integerParam, "SellingCarID", vehid);
        SetPVarInt(integerParam, "SellingCarPrice", integerParam2);

        new szConfirm[128];

        format(szConfirm, sizeof(szConfirm), "[AVISO] Você ofereceu este veículo para %s por {009B19}$%d.", Player_GetName(integerParam), integerParam2);
        SendClientMessage(playerid, C_COLOR_WARNING, szConfirm); 

        format(szConfirm, sizeof(szConfirm), "[AVISO] %s está te oferecendo um(a) %s por {009B19}$%d.", Player_GetName(playerid), GetVehicleName(GetVehicleModel(vehid)),integerParam2);
        SendClientMessage(integerParam, C_COLOR_WARNING, szConfirm);  
        SendClientMessage(integerParam, C_COLOR_WARNING, "[AVISO] Digite '/aceitar veiculo' para confirmar a compra."); 
        
    } 
    else if(!strcmp(szParam, "deletar", true)){
        if(integerParam == -1)
            return SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /v deletar [ID] -{C0C0C0} Deleta PERMANENTEMENTE um de seus veículos");

        new szTemp[128];
        mysql_format(hSQL, szTemp, sizeof(szTemp), "select model from `vehicle` where `id_vehicle` = '%d' AND `id_character` = '%d' limit 1", integerParam, Player_DBID(playerid));
        new Cache:result = mysql_query(hSQL, szTemp);

        if(!cache_get_row_count()){            
            cache_delete(result);
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um ID de veículo inválido! (/v lista)");
        }

        new scriptID = Vehicle_GetScriptIDFromSql(integerParam);

        if(scriptID != -1 && gVehicleData[scriptID][vSpawned] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Estacione o veículo antes de deletá-lo (/v estacionar).");        

        new 
            szConfirm[250],
            model;

        model = cache_get_field_content_int(0, "model", hSQL);

        format(szConfirm, sizeof(szConfirm), "Você realmente deseja deletar o seu {FFFFFF}%s {A9C4E4}permanentemente?\n\
            {ED0202}Obs: Itens guardados no veículo serão consequentemente deletados.\nObs2: Você não receberá NADA em troca!", GetVehicleName(model));
       
        ShowPlayerDialog(playerid, DIALOG_CONFIRMCARDELETE, DIALOG_STYLE_MSGBOX, "Deleção de Veículo", szConfirm, "Sim", "Não");        
        SetPVarInt(playerid, "DeleteCarID", integerParam);

        cache_delete(result);
    }  
    else{
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }

    return 1;
}

CMD:motor(playerid, params[]){
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

    new 
        vehicleid = GetPlayerVehicleID(playerid),
        vehScriptID = Vehicle_GetScriptID(vehicleid),
        vehfaction = Vehicle_GetFactionID(vehScriptID);

    if(Vehicle_DontHaveEngine(GetVehicleModel(vehicleid)))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo não possui motor");
    if(vehfaction == 0){
        if(Vehicle_GetOwnerID(vehScriptID) != Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui as chaves deste veículo.");
        if(Vehicle_GetJobID(vehScriptID) != Player_GetJobID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui as chaves deste veículo. (Emprego)");
    } else if(vehfaction != 0){
        if(vehfaction != Player_GetFactionID(playerid)){
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui as chaves deste veículo. (Facção)");
        }
    }
    if(gVehicleData[vehScriptID][vFuel] <= 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo está sem combustível.");
        
    if(gPlayerData[playerid][pVehRefueling] == vehicleid)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode ligar um veículo que está sendo abastecido.");

    new
        engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);
    if(gVehicleData[vehScriptID][vEngine] == 0){
        SetVehicleParamsEx(vehicleid, 1, lights, alarm, doors, bonnet, boot, objective);
        gVehicleData[vehScriptID][vEngine] = 1;
        cmd_me(playerid,"liga o motor do veículo.");
    } else {
        SetVehicleParamsEx(vehicleid, 0, lights, alarm, doors, bonnet, boot, objective);
        gVehicleData[vehScriptID][vEngine] = 0;
        cmd_me(playerid,"desliga o motor do veículo.");
    }
    return 1;
}

CMD:luzes(playerid, params[]){
    #pragma unused params

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

    new 
        vehicleid = GetPlayerVehicleID(playerid);

    new
        engine,
        lights,
        alarm,
        doors,
        bonnet,
        boot,
        objective;

    GetVehicleParamsEx(vehicleid, engine, lights, alarm, doors, bonnet, boot, objective);

    if(lights != 1){
        SetVehicleParamsEx(vehicleid, engine, 1, alarm, doors, bonnet, boot, objective);
        GameTextForPlayer(playerid, "~g~Luzes Ligadas", 1500, 3);
    } else {
        SetVehicleParamsEx(vehicleid, engine, 0, alarm, doors, bonnet, boot, objective);
        GameTextForPlayer(playerid, "~r~Luzes Desligadas", 1500, 3);
    }
    return 1;    
}

CMD:janela(playerid, params[]){
    if(!IsPlayerInAnyVehicle(playerid))
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");
    if(Vehicle_DontHaveWindows(GetVehicleModel(GetPlayerVehicleID(playerid))))
        return  SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo não possui janelas.");

    new 
        windowOption[20],
        vehicleid = GetPlayerVehicleID(playerid),
        seat = GetPlayerVehicleSeat(playerid),
        driver,
        passenger,
        backleft,
        backright;

    if(sscanf(params, "S(mine)[20]", windowOption)){
        return 1;
    }

    GetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, backright);

    if(!strcmp(windowOption, "mine", true)){
        switch(seat){
            case 0:{ //Motorista
                if(driver != 0){
                    SetVehicleParamsCarWindows(vehicleid, 0, passenger, backleft, backright);
                    cmd_ame(playerid, "abaixa a sua janela.");
                    SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}O motorista do veículo pode utilizar parâmetros extras para controlar todas as janelas do veículo.");
                    SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /janela [todas/frenteesquerda(fe)/frentedireita(fd)/trasesquerda(te)/trasdireita(td)]");
                } else {
                    SetVehicleParamsCarWindows(vehicleid, 1, passenger, backleft, backright);  
                    cmd_ame(playerid, "levanta a sua janela.");  
                }
            }
            case 1:{ //Passageiro
                if(passenger != 0){
                    SetVehicleParamsCarWindows(vehicleid, driver, 0, backleft, backright);
                    cmd_ame(playerid, "abaixa a sua janela.");
                } else {
                    SetVehicleParamsCarWindows(vehicleid, driver, 1, backleft, backright);
                    cmd_ame(playerid, "levanta a sua janela.");  
                }
            }
            case 2:{ //Traseiro Esquerdo
                if(backleft != 0){
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, 0, backright);
                    cmd_ame(playerid, "abaixa a sua janela.");
                } else {
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, 1, backright);   
                    cmd_ame(playerid, "levanta a sua janela."); 
                }
            }
            case 3:{ //Traseiro Direito
                if(backright != 0){
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 0);
                    cmd_ame(playerid, "abaixa a sua janela.");
                } else {
                    SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 1);  
                    cmd_ame(playerid, "levanta a sua janela.");  
                }
            }
            default:{
                SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode abrir esta janela.");
            }
        }    
    } else if(!strcmp(windowOption, "frenteesquerda", true) || !strcmp(windowOption, "fe", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)     
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Apenas o motorista pode utilizar parâmetros adicionais.");

        if(driver != 0){
            SetVehicleParamsCarWindows(vehicleid, 0, passenger, backleft, backright);
            cmd_ame(playerid, "abaixa a janela dianteira esquerda.");
        } else {
            SetVehicleParamsCarWindows(vehicleid, 1, passenger, backleft, backright);  
            cmd_ame(playerid, "levanta a janela dianteira esquerda");  
        }    
    } else if(!strcmp(windowOption, "frentedireita", true) || !strcmp(windowOption, "fd", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)     
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Apenas o motorista pode utilizar parâmetros adicionais.");

        if(passenger != 0){
            SetVehicleParamsCarWindows(vehicleid, driver, 0, backleft, backright);
            cmd_ame(playerid, "abaixa a janela dianteira esquerda.");
        } else {
            SetVehicleParamsCarWindows(vehicleid, driver, 1, backleft, backright);  
            cmd_ame(playerid, "levanta a janela dianteira esquerda");  
        }    
    } else if(!strcmp(windowOption, "trasesquerda", true) || !strcmp(windowOption, "te", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)     
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Apenas o motorista pode utilizar parâmetros adicionais.");

        if(backleft != 0){
            SetVehicleParamsCarWindows(vehicleid, driver, passenger, 0, backright);
            cmd_ame(playerid, "abaixa a janela traseira esquerda.");
        } else {
            SetVehicleParamsCarWindows(vehicleid, driver, passenger, 1, backright);  
            cmd_ame(playerid, "levanta a janela traseira esquerda");  
        }    
    } else if(!strcmp(windowOption, "trasdireita", true) || !strcmp(windowOption, "td", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)     
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Apenas o motorista pode utilizar parâmetros adicionais.");

        if(backright != 0){
            SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 0);
            cmd_ame(playerid, "abaixa a janela traseira direita.");
        } else {
            SetVehicleParamsCarWindows(vehicleid, driver, passenger, backleft, 1);  
            cmd_ame(playerid, "levanta a janela traseira direita");  
        }    
    } else if(!strcmp(windowOption, "todas", true)){
        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)     
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Apenas o motorista pode utilizar parâmetros adicionais.");

        if(driver != 0 || passenger != 0 || backleft != 0 || backright != 0){
            SetVehicleParamsCarWindows(vehicleid, 0, 0, 0, 0);
            cmd_ame(playerid, "abaixa todas as janelas.");
        } else {
            SetVehicleParamsCarWindows(vehicleid, 1, 1, 1, 1);  
            cmd_ame(playerid, "levanta todas as janelas");  
        }    
    } else {
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");    
    }

    return 1;
}

CMD:abastecer(playerid, params[]){
    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dirigindo um veículo.");    

    new     
        szFuelType[20],
        businessid = Player_GetNearestBusiness(playerid);

    if(businessid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está proximo à um posto de gasolina.");
    if(Business_GetType(businessid) != BTYPE_GAS_GENERAL && Business_GetType(businessid) != BTYPE_GAS_KEROSENE)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Esta empresa não é um posto de gasolina.");

    new 
        businessType = Business_GetType(businessid),
        vehicleid = GetPlayerVehicleID(playerid),
        vehScriptID = Vehicle_GetScriptID(vehicleid),
        vehModel = GetVehicleModel(vehicleid),
        tankSize = Vehicle_GetTankSize(vehModel);

    if(gVehicleData[vehScriptID][vEngine] == 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você precisa desligar o motor do veículo primeiro.");        

    if(gVehicleData[vehScriptID][vFuel] >= tankSize)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo está com o tanque cheio.");

    if(sscanf(params, "s[20]", szFuelType)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /abastecer [tipo] -{C0C0C0} Abastece o seu veículo com um certo combustível");
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Abastecer um veículo com combustível incompatível poderá danificá-lo. (/infomotor)");

        if(businessType == BTYPE_GAS_GENERAL)   
            SendClientMessage(playerid, C_COLOR_PARAMS, "[TIPOS] gasolina, alcool, diesel");

        if(businessType == BTYPE_GAS_KEROSENE)   
            SendClientMessage(playerid, C_COLOR_PARAMS, "[TIPOS] querosene");
        return 1;
    }

    if(!strcmp(szFuelType, "gasolina", true)){
        if(businessType != BTYPE_GAS_GENERAL)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este posto de não possui este tipo de combustível.");      

        Vehicle_StartRefueling(playerid, vehicleid, FUEL_GASOLINE, businessid, tankSize);
    } else if(!strcmp(szFuelType, "alcool", true)){
        if(businessType != BTYPE_GAS_GENERAL)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este posto de não possui este tipo de combustível.");

        Vehicle_StartRefueling(playerid, vehicleid, FUEL_ETHANOL, businessid, tankSize);        
    } else if(!strcmp(szFuelType, "diesel", true)){
        if(businessType != BTYPE_GAS_GENERAL)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este posto de não possui este tipo de combustível.");

        Vehicle_StartRefueling(playerid, vehicleid, FUEL_DIESEL, businessid, tankSize);
    } else if(!strcmp(szFuelType, "querosene", true)){
        if(businessType != BTYPE_GAS_KEROSENE)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este posto de não possui este tipo de combustível.");

        Vehicle_StartRefueling(playerid, vehicleid, FUEL_KEROSENE, businessid, tankSize);
    }
    else{
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }

    return 1;
}

CMD:quebrartrava(playerid, params[]){
    new
        szParam[10];

    if(sscanf(params, "S(start)[10]", szParam))
        return 1;    

    if(!strcmp(szParam, "start", true)){
        if(gPlayerData[playerid][pToolkit] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui uma caixa de ferramentas.");

        if(IsPlayerInAnyVehicle(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você deve estar a pé para utilizar este comando.");

        if(gPlayerData[playerid][pVehBreakingIn] != 0){
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já está quebrando a trava de um veículo.");
            return SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}Digite {1BBAD6}/quebrartrava parar {FFFFFF}ou vá para longe do veículo para cancelar o processo.");
        }

        if(Player_GetNearestVehicle(playerid) == -1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está proximo à um veículo.");

        new
            vehicleid = Player_GetNearestVehicle(playerid),
            vehScriptID = Vehicle_GetScriptID(vehicleid);

        if(Vehicle_GetOwnerID(vehScriptID) == Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode quebrar a trava do seu próprio veículo.");

        if(Vehicle_GetJobID(vehScriptID) != 0 || Vehicle_GetFactionID(vehScriptID) != 0 || Vehicle_IsStatic(vehScriptID))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode quebrar a trava deste veículo.");

        if(gVehicleData[vehScriptID][vLocked] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo já está aberto.");

        Vehicle_StartBreakin(playerid, vehicleid);
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você iniciou o processo para quebrar a trava deste veículo.");
        SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}Digite {1BBAD6}/quebrartrava parar {FFFFFF}ou vá para longe do veículo para cancelar o processo.");
    } else if(!strcmp(szParam, "parar", true)){
        if(gPlayerData[playerid][pVehBreakingIn] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está quebrando a trava de um veículo.");

        gPlayerData[playerid][pVehBreakingIn] = 0;                    
        gPlayerData[playerid][pVehBreakingInTime] = 0;
        if(HotwireTimer[playerid] != 0){
            KillTimer(HotwireTimer[playerid]);
            HotwireTimer[playerid] = 0;
        }

        GameTextForPlayer(playerid, "~r~Processo cancelado", 3000, 3);
    }
    return 1;
}

CMD:ligacaodireta(playerid, params[]){
    new
        szParam[10];

    if(sscanf(params, "S(start)[10]", szParam))
        return 1;    

    if(!strcmp(szParam, "start", true)){
        if(gPlayerData[playerid][pToolkit] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não possui uma caixa de ferramentas.");

        if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está dentro de um veículo.");

        if(gPlayerData[playerid][pVehBreakingIn]){            
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você está quebrando a trava de um veículo.");
            return SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}Digite {1BBAD6}/quebrartrava parar {FFFFFF}ou vá para longe do veículo para cancelar o processo.");
        }

        if(gPlayerData[playerid][pVehHotwiring] != 0){
            SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você já está realizando ligação direta em um veículo.");
            return SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}Digite {1BBAD6}/ligacaodireta parar {FFFFFF}ou saia do veículo para cancelar o processo.");
        }

        new
            vehicleid = GetPlayerVehicleID(playerid),
            vehScriptID = Vehicle_GetScriptID(vehicleid);

        if(Vehicle_GetOwnerID(vehScriptID) == Player_DBID(playerid))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode realizar ligação direta em seu próprio veículo.");

        if(Vehicle_GetJobID(vehScriptID) != 0 || Vehicle_GetFactionID(vehScriptID) != 0 || Vehicle_IsStatic(vehScriptID))
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não pode realizar ligação direta neste veículo.");

        if(gVehicleData[vehScriptID][vEngine] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Este veículo já está ligado.");

        Vehicle_StartHotwire(playerid, vehicleid);
        SendClientMessage(playerid, C_COLOR_WARNING, "[AVISO] Você iniciou o processo de ligação direta neste veículo.");
        SendClientMessage(playerid, C_COLOR_TIP, "[DICA] {FFFFFF}Digite {1BBAD6}/ligacaodireta parar {FFFFFF}ou saia do veículo para cancelar o processo.");
    } else if(!strcmp(szParam, "parar", true)){
        if(gPlayerData[playerid][pVehHotwiring] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está realizando ligação direta em um veículo.");

        gPlayerData[playerid][pVehHotwiring] = 0;                    
        gPlayerData[playerid][pVehHotwiringTime] = 0;
        if(HotwireTimer[playerid] != 0){
            KillTimer(HotwireTimer[playerid]);
            HotwireTimer[playerid] = 0;
        }

        GameTextForPlayer(playerid, "~r~Processo cancelado", 3000, 3);
    }
    return 1;
}

CMD:portamalas(playerid, params[]){
    new
        vehicleid = Player_GetNearestVehicle(playerid),
        vehScriptID = Vehicle_GetScriptID(vehicleid);

    if(vehicleid == -1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você não está proximo à um veículo.");
    if(gVehicleData[vehScriptID][vEngine] == 0)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O motor do veículo precisa estar ligado.");
    if(gVehicleData[vehScriptID][vStatic] == 1)
        return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Veículos estáticos não possuem porta-malas.");

    new
        szParam[10];

    if(sscanf(params, "s[10]", szParam)){
        SendClientMessage(playerid, C_COLOR_SYNTAX, "[USO] /portamalas [parâmetro] -{C0C0C0} Realiza diversas ações relacionadas ao porta-malas de um veículo");
        return SendClientMessage(playerid, C_COLOR_PARAMS, "[PARÂMETROS] abrir, fechar, checar");  
    }

    if(!strcmp(szParam, "abrir", true)){
        if(gVehicleData[vehScriptID][vTrunk] == 1)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O porta-malas deste veículo já está aberto.");
        new
            engine,
            lights,
            alarm,
            doors,
            bonnet,
            boot,
            objective;

        GetVehicleParamsEx(gVehicleData[vehScriptID][vID], engine, lights, alarm, doors, bonnet, boot, objective);    

        SetVehicleParamsEx(gVehicleData[vehScriptID][vID], engine, lights, alarm, doors, bonnet, 1, objective);
        gVehicleData[vehScriptID][vTrunk] = 1;
        cmd_me(playerid,"abre o porta-malas do veículo.");
    } else if(!strcmp(szParam, "fechar", true)){
        if(gVehicleData[vehScriptID][vTrunk] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O porta-malas deste veículo já está fechado.");
        new
            engine,
            lights,
            alarm,
            doors,
            bonnet,
            boot,
            objective;

        GetVehicleParamsEx(gVehicleData[vehScriptID][vID], engine, lights, alarm, doors, bonnet, boot, objective);    

        SetVehicleParamsEx(gVehicleData[vehScriptID][vID], engine, lights, alarm, doors, bonnet, 0, objective);
        gVehicleData[vehScriptID][vTrunk] = 0;
        cmd_me(playerid,"fecha o porta-malas do veículo.");
    } else if(!strcmp(szParam, "checar", true)){
        if(gVehicleData[vehScriptID][vTrunk] == 0)
            return SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] O porta-malas deste veículo está fechado (/portamalas abrir).");
        Vehicle_ShowTrunk(playerid, vehScriptID);
    }
    else{
        SendClientMessage(playerid, C_COLOR_ERROR, "[ERRO] Você digitou um parâmetro inválido.");
    }
    return 1;
}
