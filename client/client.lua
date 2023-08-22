local QBCore = exports['qb-core']:GetCoreObject()

--returns the closest vehicle from the ped
function getClosestVehicleFromPedPos(ped, maxDistance, maxHeight)
    local veh = nil
    local smallestDistance = maxDistance
    local vehs = {}
    local count = #vehs
    count = GetGamePool("CVehicle") - 1
    local playerCoords = GetEntityCoords(ped)

    for i = 0, count do
        local vehicle = GetIndexedPoolItem(i)
        if DoesEntityExist(vehicle) then
            local distance = #(playerCoords - GetEntityCoords(vehicle))
            local height = GetEntityHeightAboveGround(vehicle)
            
            if distance <= smallestDistance and height <= maxHeight and height >= 0 and not IsPedInVehicle(ped, vehicle, false) then
                smallestDistance = distance
                veh = vehicle
            end
        end
    end

    return veh
end

RegisterNetEvent('qb-vab:fixVehicle')
AddEventHandler('qb-vab:fixVehicle', function(vehNetId)
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
    local veh = getClosestVehicleFromPedPos(GetPlayerPed(PlayerPedId()), 5, 5)

    --get the network ID of the vehicle && triggers the event if network ID is found
    local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)
    if vehicleNetId then
         TriggerServerEvent('qb-vab:fixVehicle', vehicleNetId)
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"Me", "Could'n find a vehicle!"}
        })
        
end)
