local QBCore = exports['qb-core']:GetCoreObject()

-- function to get closest vehicle
Vehicle getClosestVehicleFromPedPos(Ped ped, int maxDistance, int maxHeight, bool canReturnVehicleInside){
    Vehicle veh = NULL;
    float smallestDistance = (float)maxDistance;
    const int ARR_SIZE = 1024;
    Vehicle vehs[ARR_SIZE];
    int count = worldGetAllVehicles(vehs, ARR_SIZE);
 
    if (vehs != NULL)
    {
        for (int i = 0; i < count; i++)
        {
            if (doesEntityExistsAndIsNotNull(vehs[i]) && (canReturnVehicleInside || PED::IS_PED_IN_VEHICLE(ped, vehs[i], false) == false))
            {
                float distance = getDistanceBetweenEntities(ped, vehs[i]);
                float height = getDistanceToGround(vehs[i]);
                if (distance <= smallestDistance && height <= maxHeight && height >= 0 && isVehicleDrivable(vehs[i]))
                {
                    smallestDistance = distance;
                    veh = vehs[i];
                }
            }
        }
    }
 
    return veh;
}

RegisterServerEvent('fixVehicle')
AddEventHandler('fixVehicle', function(vehNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehNetId)

    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
        TriggerClientEvent('vehicleFixed', -1, vehNetId) -- Notify clients that the vehicle is fixed
    end
end)

--Register the command
RegisterCommand('repairveh', function()
    --get the vehicle entity
    Vehicle veh = getClosestVehicleFromPedPos(GET_PLAYER_PED(PlayerPedId(), 5, 5, false))

    --get the network ID of the vehicle && triggers the event if network ID is found
    local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)
    if(vehicleNetId) {
         TriggerServerEvent('fixVehicle', vehicleNetId)
    } else {
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"Me", "Could'n find a vehicle!"}
        })
    }
    
end)