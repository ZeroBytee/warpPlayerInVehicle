local QBCore = exports['qb-core']:GetCoreObject()

-- -=-=-=-=-=-=-
-- GLOBAL FUNCTIONS
-- -=-=-=-=-=-=-

-- LOCAL VARIABLES
local isDoingMechanicEmote = false
local isDoingCleaningEmote = false

local schoonmakenDur = Config.schoonmaken_dur
local reparerenDur = Config.repareren_dur

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

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function disableMovement()
    DisableControlAction(0, 30, true) -- A (Left)
    DisableControlAction(0, 31, true) -- S (Backward)
    DisableControlAction(0, 32, true) -- W (Forward)
    DisableControlAction(0, 33, true) -- D (Right)
    DisableControlAction(0, 34, true) -- Q (Move Left)
    DisableControlAction(0, 35, true) -- E (Move Right)
    DisableControlAction(0, 36, true) -- Shift (Sprint)
    DisableControlAction(0, 44, true) -- Q (Cover)
    DisableControlAction(0, 45, true) -- E (Reload)
end 

function enableMovement()
    DisableControlAction(0, 30, false) -- A (Left)
    DisableControlAction(0, 31, false) -- S (Backward)
    DisableControlAction(0, 32, false) -- W (Forward)
    DisableControlAction(0, 33, false) -- D (Right)
    DisableControlAction(0, 34, false) -- Q (Move Left)
    DisableControlAction(0, 35, false) -- E (Move Right)
    DisableControlAction(0, 36, false) -- Shift (Sprint)
    DisableControlAction(0, 44, false) -- Q (Cover)
    DisableControlAction(0, 45, false) -- E (Reload)
end


function StartMechanicEmote()
    if not isDoingMechanicEmote then
        if not isDoingCleaningEmote then 
            isDoingMechanicEmote = true
        
            local playerPed = PlayerPedId()
            local vehicle = getClosestVehicleFromPedPos(playerPed, 4, 3) -- Adjust the distance as needed
            
            if DoesEntityExist(vehicle) then
                local playerCoords = GetEntityCoords(playerPed)
                local vehicleCoords = GetEntityCoords(vehicle)
                
                local direction = vector3(vehicleCoords.x - playerCoords.x, vehicleCoords.y - playerCoords.y, 0.0)
                local heading = math.atan2(direction.y, direction.x)
                
                SetEntityHeading(playerPed, math.deg(heading) - 90) -- Adjust the heading by 90 degrees
                
                -- Trigger the emote command
                ExecuteCommand("e mechanic")
                
                Citizen.CreateThread(function()
                    local duration = reparerenDur
                    local startTime = GetGameTimer()
                    
                    while isDoingMechanicEmote do
                        Citizen.Wait(0)
    
                        disableMovement()
                        
                        if GetGameTimer() - startTime >= duration then
                            ClearPedTasks(playerPed)
                            isDoingMechanicEmote = false
                        end
                    end
    
                    enableMovement()
                    
                end)
            else
                print("No vehicle found nearby.")
            end
        end
        
    end
end


function StartCleaningEmote()
    if not isDoingCleaningEmote then
        if not isDoingMechanicEmote then
            isDoingCleaningEmote = true
        
            local playerPed = PlayerPedId()
            local vehicle = getClosestVehicleFromPedPos(playerPed, 4, 3) -- Adjust the distance as needed
            
            if DoesEntityExist(vehicle) then
                local playerCoords = GetEntityCoords(playerPed)
                local vehicleCoords = GetEntityCoords(vehicle)
                
                local direction = vector3(vehicleCoords.x - playerCoords.x, vehicleCoords.y - playerCoords.y, 0.0)
                local heading = math.atan2(direction.y, direction.x)
                
                SetEntityHeading(playerPed, math.deg(heading) - 90) -- Adjust the heading by 90 degrees
                
                -- Trigger the emote command
                ExecuteCommand("e clean")
                
                Citizen.CreateThread(function()
                    local duration = schoonmakenDur
                    local startTime = GetGameTimer()
                    
                    while isDoingCleaningEmote do
                        Citizen.Wait(0)
                        
                        disableMovement()

                        if GetGameTimer() - startTime >= duration then
                            ClearPedTasks(playerPed)
                            isDoingCleaningEmote = false
                        end
                    end

                    enableMovement()

                end)
            else
                print("No vehicle found nearby.")
            end
        end
    end
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

                        StartMechanicEmote()
                        Citizen.Wait(reparerenDur)
                        
                        --local dir = "missmechanic"
                        --print("playing animation!")
                        --loadAnimDict(dir)
                        --TaskPlayAnim(PlayerPedId(), dir, "work_in" ,3.0, 3.0, -1, 16, 0, false, false, false)
                        --print("playing animation ended!")

                        
                        SetVehicleEngineHealth(veh, 1000.0)
                        SetVehicleFixed(veh)
                        SetVehicleDeformationFixed(veh)
                        SetVehicleUndriveable(veh, false)
                        SetVehicleEngineOn(veh, true, true)
                    end
                end
            end
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
                    
                    StartCleaningEmote()
                    Citizen.Wait(schoonmakenDur)
                    SetVehicleDirtLevel(veh, 0.0)
                    
                end
            end
        end
    end
end)

RegisterNetEvent('astroVAB:inbeslagNemen')
AddEventHandler('astroVAB:inbeslagNemen', function()
    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            --get the vehicle entity
            local veh = GetVehiclePedIsIn(PlayerPedId(), false) -- Get the vehicle the player is in

            -- check's if vehicle exist
            if DoesEntityExist(veh) and IsEntityAVehicle(veh) then
                --get the network ID of the vehicle && triggers the event if network ID is found
                DeleteEntity(veh)
            end
        end
    end
end)


local originalPedVariation = nil
local originalPedTexture = nil
local vabClothesOn = false


RegisterNetEvent('astroVAB:kleedkamer')
AddEventHandler('astroVAB:kleedkamer', function(scrollIndex)
    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobDutyStatus = player.job.onduty
        local jobGrade = player.job.grade.name



        if jobName == "mechanic" and jobDutyStatus == true then
            local playerPed = GetPlayerPed(-1)

            if vabClothesOn == false then 
                originalPedVariation = GetPedDrawableVariation(playerPed, 11)
                originalPedTexture = GetPedTextureVariation(playerPed, 11)
            end
            if scrollIndex == 1 then
                SetPedComponentVariation(playerPed, 11, originalPedVariation, originalPedTexture, 0)
            else 
                if jobGrade == "Novice" then  
                    SetPedComponentVariation(playerPed, 11, 1, 0, 0)
                    vabClothesOn = true
                elseif jobGrade == "Experienced" then  
                    SetPedComponentVariation(playerPed, 11, 9, 0, 0)
                    vabClothesOn = true
                elseif jobGrade == "Advanced" then  
                    SetPedComponentVariation(playerPed, 11, 13, 0, 0)
                    vabClothesOn = true
                elseif jobGrade == "CEO" then
                    SetPedComponentVariation(playerPed, 11, 13, 1, 0) -- monteur clothes, change
                    vabClothesOn = true
                end
            end
        end
    end
end)



-- TODO: 
-- create mysql connection and save the player's outfit there
-- only save the outfit of the people that put on vab clothing





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
        {label = 'Repareren', description = Config.repareren_desc, icon = 'car'},
        {label = 'Schoonmaken', description = Config.schoonmaken_desc, icon = 'soap'},
        {label = 'In beslag nemen', description = Config.inbeslagNemen_desc, icon = 'circle-xmark'},
        {label = 'Kleedkamer', icon = 'shirt', values={'persoonlijke kleren', 'werk kleren | hoodie', 'werk kleren | t-shirt'}},
        --{label = 'Button with args', args = {someArg = 'nice_button'}},
        --{label = 'List button', values = {'You', 'can', 'side', 'scroll', 'this'}, description = 'It also has a description!'},
        --{label = 'List button with default index', values = {'You', 'can', 'side', 'scroll', 'this'}, defaultIndex = 5},
        --{label = 'List button with args', values = {'You', 'can', 'side', 'scroll', 'this'}, args = {someValue = 3, otherValue = 'value'}},
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        TriggerEvent('astroVAB:repareren')
    elseif selected == 2 then 
        TriggerEvent('astroVAB:schoonmaken')
    elseif selected == 3 then 
        TriggerEvent('astroVAB:inbeslagNemen')
    elseif selected == 4 then 
        TriggerEvent('astroVAB:kleedkamer', scrollIndex)
        --TriggerServerEvent('astroVAB:kleedkamer')
    end
end)
 

RegisterCommand('+vabJobMenu', function()
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
    	local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
        if jobName == "mechanic" and jobDutyStatus == true then
    		lib.showMenu('vab_job_menu')
        end
    end
end)

AddEventHandler('astroRP:vabJobMenu', function()
    lib.showMenu('vab_job_menu')
end)

RegisterKeyMapping('+vabJobMenu', 'Open Job Menu', 'keyboard', Config.jobMenu)


