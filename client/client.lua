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

RegisterCommand('onduty', function()
    local player = QBCore.Functions.GetPlayerData()

    print("debug1")
    QBCore.Functions.SetPlayerData('job', 'onduty', true) -- Assuming 'onduty' is the duty status for the job
    print("debug2")

end)


--Register the command
RegisterCommand('repairveh', function()

    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        -- Now you can use jobName and jobGrade as needed
        print("Player's job: " .. jobName .. " - Grade: " .. jobGrade)
        if jobName == "mechanic" and jobDutyStatus == true then
            print("job correct, repairing")
            --get the vehicle entity
            local veh = getClosestVehicleFromPedPos(PlayerPedId(), 5, 5)

            -- check's if vehicle exist
            if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                --get the network ID of the vehicle && triggers the event if network ID is found
                local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)

                -- send's the repairVehicle event, if the networkNetId is found. 
                if vehicleNetId then
                    print("net correct, repairing")
                    local health = GetEntityHealth(vehicle)
                    if health >= -4000 then
                        print("health correct, repairing")
                        TriggerServerEvent('QB-VAB:fixVehicle', vehicleNetId)
                        SetVehicleEngineHealth(veh, 1000.0)
                        SetVehicleFixed(veh)
                        SetVehicleDeformationFixed(veh)
                        SetVehicleUndriveable(veh, false)
                        SetVehicleEngineOn(veh, true, true)
                    else 
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0},
                            multiline = true,
                            args = {"System", "Vehicle is too damaged!"}
                        })
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
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0},
                multiline = true,
                args = {"System", "Not in duty!"}
            })
        end
    end
end)

