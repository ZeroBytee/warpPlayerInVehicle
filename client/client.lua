local QBCore = exports['qb-core']:GetCoreObject()

-- Function to get closest vehicle from the ped
 function getClosestVehicleFromPedPos(ped, maxDistance, maxHeight)
    local veh = nil
    local smallestDistance = maxDistance
    local playerCoords = GetEntityCoords(ped)

    local vehicles = QBCore.Functions.GetVehicles()

    for k, vehicle in pairs(vehicles) do
        local distance = #(playerCoords - GetEntityCoords(vehicle))
        local height = GetEntityHeightAboveGround(vehicle)

        if distance <= smallestDistance and height <= maxHeight and height >= 0 and not IsPedInVehicle(ped, vehicle, false) then
            smallestDistance = distance
            veh = vehicle
        end
    end

    return veh
end


--Register the command
RegisterCommand('repairveh', function()
    --get the vehicle entity
    local veh = getClosestVehicleFromPedPos(PlayerPedId(), 5, 5)

    -- check's if vehicle exist
    if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
        --get the network ID of the vehicle && triggers the event if network ID is found
        local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)

        -- send's the repairVehicle event, if the networkNetId is found. 
        if vehicleNetId then
            print("debug0")
            local health = GetEntityHealth(vehicle)
            if health >= 4000 then
                TriggerServerEvent('QB-VAB:fixVehicle', vehicleNetId)
                SetVehicleEngineHealth(veh, 1000.0)
                SetVehicleFixed(veh)
                SetVehicleDeformationFixed(veh)
                SetVehicleUndriveable(veh, false)
                SetVehicleEngineOn(veh, true, true)
            end
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0},
                multiline = true,
                args = {"System", "Can't perform this action because the vehicle isn't syncronized with the server"}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"System", "Could'n find a vehicle! 2"}
        })
    end
end)

