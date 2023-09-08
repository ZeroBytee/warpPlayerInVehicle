local QBCore = exports['qb-core']:GetCoreObject()

-- -=-=-=-=-=-=-
-- GLOBAL FUNCTIONS
-- -=-=-=-=-=-=-

-- LOCAL VARIABLES
local isDoingCuffEmote = false
local isDoingCleaningEmote = false
local isBusy = false
local isCuffed = false

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


function StartCuffEmote()
    if not isDoingCuffEmote then
        if not isDoingCleaningEmote then 
            isDoingCuffEmote = true
        
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

-- TODO: uncuff on death, uncuff als al geboeit is


RegisterNetEvent('jaga-gangmenu:cuff')
AddEventHandler('jaga-gangmenu:cuff', function()

    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!


    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            --get the vehicle entity
            local coords = GetEntityCoords(PlayerPedId())
            local closestPed, distance = QBCore.Functions.GetClosestPed(coords)
            local target
            if distance <= 5 then
                target = closestPed
            end

            if target then
                -- cuff logic

                -- check of de speler al geboeit is, en voer dan de juiste actie uit
                --isCuffed = lib.callback.await('jaga-gangmenu:isPlayerCuffed')
                
                if not isCuffed then
                    print("cuffing started")
                    isBusy = true
                    local escaped
                    local pdPed = GetPlayerPed(GetPlayerFromServerId(pdId))
                    lib.requestAnimDict('mp_arrest_paired', 3000)
                    AttachEntityToEntity(cache.ped, pdPed, 11816, -0.1, 0.45, 0.0, 0.0, 0.0, 20.0, false, false, false, false, 20, false)
	                TaskPlayAnim(cache.ped, 'mp_arrest_paired', 'crook_p2_back_left', 8.0, -8.0, 5500, 33, 0, false, false, false)

	                FreezeEntityPosition(pdPed, true)
                    Wait(2000)
	                DetachEntity(cache.ped, true, false)
	                FreezeEntityPosition(pdPed, false)
                    RemoveAnimDict('mp_arrest_paired')
                    
                    --exports['wasabi-police']:handcuffed("easy")
                    isCuffed = true
                    isBusy = false
                else 
                    -- uncuff logic here
                    TaskTurnPedToFaceCoord(cache.ped, targetCoords.x, targetCoords.y, targetCoords.z, 2000)
                    Wait(2000)
                    TaskStartScenarioInPlace(cache.ped, 'PROP_HUMAN_PARKING_METER', 0, true)
                    Wait(2000)
                    ClearPedTasks(cache.ped)
                    --exports['wasabi-police']:uncuffed()
                    isCuffed = false
                end
            else 
                print("no player near you!")
            end
        end
    end
end)

RegisterNetEvent('jaga-gangmenu:fouilleren')
AddEventHandler('jaga-gangmenu:search', function()

    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!


    --get the player
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            --get the vehicle entity
            local coords = GetEntityCoords(PlayerPedId())
            local target = QBCore.Functions.GetClosestPed(coords)

            if target then
                searchPlayer(target)
            else 
                print("no player near you!")
            end
        end
    end
end)


RegisterNetEvent('jaga-gangmenu:schoonmaken')
AddEventHandler('jaga-gangmenu:schoonmaken', function()

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
                    
                    --get the vehicle entity
                    local coords = GetEntityCoords(PlayerPedId())
                    local target = QBCore.Functions.GetClosestPed(coords)

                    if target then
                        searchPlayer(target)
                    else 
                        print("no player near you!")
                    end

                end
            end
        end
    end
end)

RegisterNetEvent('jaga-gangmenu:inbeslagNemen')
AddEventHandler('jaga-gangmenu:inbeslagNemen', function()
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


RegisterNetEvent('jaga-gangmenu:kleedkamer')
AddEventHandler('jaga-gangmenu:kleedkamer', function(scrollIndex)
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
    id = 'jaga_gang_menu',
    title = 'Gang Menu',
    position = 'top-right',

    onSideScroll = function(selected, scrollIndex, args)
        --print("Scroll: ", selected, scrollIndex, args)
    end,
    
    options = {
        {label = 'Boei', description = Config.handboeien_desc, icon = 'handcuffs'},
        {label = 'Fouilleren', description = Config.schoonmaken_desc, icon = 'hand-wave'},
        {label = 'In auto steken', description = Config.inbeslagNemen_desc, icon = 'right-to-bracket'},
        {label = 'Uit auto halen', description = Config.inbeslagNemen_desc, icon = 'circle-xmark'},
        {label = 'Mee slepen', description = Config.inbeslagNemen_desc, icon = 'person-military-pointing'},
        --{label = 'Button with args', args = {someArg = 'nice_button'}},
        --{label = 'List button', values = {'You', 'can', 'side', 'scroll', 'this'}, description = 'It also has a description!'},
        --{label = 'List button with default index', values = {'You', 'can', 'side', 'scroll', 'this'}, defaultIndex = 5},
        --{label = 'List button with args', values = {'You', 'can', 'side', 'scroll', 'this'}, args = {someValue = 3, otherValue = 'value'}},
    }
}, function(selected, scrollIndex, args)
    --boeien
    if selected == 1 then
        TriggerEvent('jaga-gangmenu:cuff')
    --fouilleren
    elseif selected == 2 then 
        TriggerEvent('jaga-gangmenu:fouilleren')
    --in auto steken
    elseif selected == 3 then 
        TriggerEvent('jaga-gangmenu:inbeslagNemen')
    -- uit auto halen
    elseif selected == 4 then 
        TriggerEvent('jaga-gangmenu:kleedkamer', scrollIndex)
    -- mee slepen
    elseif selected == 5 then 
        TriggerEvent('jaga-gangmenu:kleedkamer', scrollIndex)
    end
end)
 

RegisterCommand('+gangmenu', function()
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
    	local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
        if jobName == "mechanic" and jobDutyStatus == true then
    		lib.showMenu('jaga_gang_menu')
        end
    end
end)

AddEventHandler('jaga-gangmenu:gangmenu', function()
    lib.showMenu('jaga_gang_menu')
end)

RegisterKeyMapping('+gangmenu', 'Open gang menu', 'keyboard', Config.jobMenu)


