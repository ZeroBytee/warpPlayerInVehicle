local QBCore = exports['qb-core']:GetCoreObject()

-- -=-=-=-=-=-=-
-- GLOBAL FUNCTIONS
-- -=-=-=-=-=-=-
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

-- -=-=-=-=-=-=-
--CORE SYSTEM
-- -=-=-=-=-=-=-

RegisterNetEvent('astroVAB:repareren')
AddEventHandler('astroVAB:repareren', function()

    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            --get the vehicle entity
            local veh = getClosestVehicleFromPedPos(PlayerPedId(), 4, 3)

            -- check's if vehicle exist
            if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                --get the network ID of the vehicle && triggers the event if network ID is found
                local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)

                -- send's the repairVehicle event, if the networkNetId is found. 
                if vehicleNetId then
                    local health = GetEntityHealth(vehicle)
                    if health >= -4000 then
                        --TriggerServerEvent('QB-VAB:fixVehicle', vehicleNetId)
                        SetVehicleEngineHealth(veh, 1000.0)
                        SetVehicleFixed(veh)
                        SetVehicleDeformationFixed(veh)
                        SetVehicleUndriveable(veh, false)
                        SetVehicleEngineOn(veh, true, true)
                    else 
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0},
                            multiline = true,
                            args = {"System", "Dit voertuig is te hard beschadigd!"}
                        })
                    end
                else
                    TriggerEvent('chat:addMessage', {
                        color = { 255, 0, 0},
                        multiline = true,
                        args = {"System", "Dit voertuig is niet gesynchroniseerd met de server, maak aub een assistje aan om dit op te lossen!"}
                    })
                end
            else
                TriggerEvent('chat:addMessage', {
                    color = { 255, 0, 0},
                    multiline = true,
                    args = {"System", "Kon geen voertuig vinden!"}
                })
            end
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0},
                multiline = true,
                args = {"System", "U bent niet in dienst, of u bent geen medewerker van de VAB!"}
            })
        end
    end
end)


RegisterNetEvent('astroVAB:schoonmaken')
AddEventHandler('astroVAB:schoonmaken', function()

    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            --get the vehicle entity
            local veh = getClosestVehicleFromPedPos(PlayerPedId(), 4, 3)

            -- check's if vehicle exist
            if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                --get the network ID of the vehicle && triggers the event if network ID is found
                local vehicleNetId = NetworkGetNetworkIdFromEntity(veh)

                -- send's the repairVehicle event, if the networkNetId is found. 
                if vehicleNetId then
                    
                    SetVehicleDirtLevel(veh, 15.0)
                    
                else 
                    TriggerEvent('chat:addMessage', {
                        color = { 255, 0, 0},
                        multiline = true,
                        args = {"System", "Dit voertuig is niet gesynchroniseerd met de server, maak aub een assistje aan om dit op te lossen!"}
                    })
                end
            else
                TriggerEvent('chat:addMessage', {
                    color = { 255, 0, 0},
                    multiline = true,
                    args = {"System", "Kon geen voertuig vinden!"}
                })
            end
        else
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0},
                multiline = true,
                args = {"System", ""}
            })
        end
    end
end)






-- -=-=-=-=-=-=-
-- JOB MENU
-- -=-=-=-=-=-=-

lib.registerMenu({
    id = 'vab_job_menu',
    title = 'VAB',
    position = 'top-right',

    onSideScroll = function(selected, scrollIndex, args)
        --print("Scroll: ", selected, scrollIndex, args)
    end,
    
    options = {
        {label = 'Repareren', description = 'Repareer het dichtstbijzijnde voertuig', icon = 'car'},
        {label = 'Schoonmaken', description = 'It has a description!', icon = 'soap'},
        {label = 'In beslag nemen', description = 'It has a description!', icon = 'circle-xmark'},
        {label = 'Kleedkamer', icon = 'shirt', values={'persoonlijke kleren', 'werk kleren | hoodie', 'werk kleren | t-shirt'}},
        --{label = 'Button with args', args = {someArg = 'nice_button'}},
        --{label = 'List button', values = {'You', 'can', 'side', 'scroll', 'this'}, description = 'It also has a description!'},
        --{label = 'List button with default index', values = {'You', 'can', 'side', 'scroll', 'this'}, defaultIndex = 5},
        --{label = 'List button with args', values = {'You', 'can', 'side', 'scroll', 'this'}, args = {someValue = 3, otherValue = 'value'}},
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        TriggerEvent('astroVAB:repareren')
    else if selected == 2 then 
        TriggerEvent('astroVAB:schoonmaken')
    end
end
 

RegisterCommand('+vabJobMenu', function()
    lib.showMenu('vab_job_menu')
end)

AddEventHandler('astroRP:vabJobMenu', function()
    lib.showMenu('vab_job_menu')
end)

RegisterKeyMapping('+vabJobMenu', 'Open Job Menu', 'keyboard', Config.jobMenu)


