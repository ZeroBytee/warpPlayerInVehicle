local QBCore = exports['qb-core']:GetCoreObject()

-- -=-=-=-=-=-=-
-- GLOBAL FUNCTIONS
-- -=-=-=-=-=-=-

-- LOCAL VARIABLES
local isDoingCuffEmote = false
local isDoingCleaningEmote = false
local isBusy = false
local isCuffed = false

local dict = "mp_arresting"
local anim = "idle"

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


function PlayCuffAnimation(playerPed, targetPlayerPed)
    RequestAnimDict("mp_arresting")
    while not HasAnimDictLoaded("mp_arresting") do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, "mp_arresting", "a_uncuff", 8.0, -8.0, -1, 16, 0, false, false, false)
    TaskPlayAnim(targetPlayerPed, "mp_arresting", "a_uncuff", 8.0, -8.0, -1, 16, 0, false, false, false)
    
    Citizen.Wait(5000) -- Adjust the time as needed
    
    ClearPedTasks(playerPed)
    ClearPedTasks(targetPlayerPed)

    RemoveAnimDict("mp_arresting")
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

function FindClosestPlayerID(targetPlayer)
    local closestPlayerID = -1  -- Initialize with an invalid player ID
    local closestDistance = -1  -- Initialize with an invalid distance value

    for _, player in pairs(QBCore.Functions.GetPlayers()) do
        if player ~= targetPlayer then
            local targetCoords = GetEntityCoords(targetPlayer)
            local playerCoords = GetEntityCoords(player)
            local distance = #(targetCoords - playerCoords)

            if closestDistance == -1 or distance < closestDistance then
                closestDistance = distance
                closestPlayerID = GetPlayerServerId(player)
            end
        end
    end

    return closestPlayerID
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

            local femaleHash = GetHashKey("mp_f_freemode_01")
            local maleHash = GetHashKey("mp_m_freemode_01")

            local dictPlayer = "mp_arresting"
            local dictTarget = "mp_arrest_paired"
            local animTarget = "idle" -- a_arrest_on_floor
            local animPlayer = "idle"
            local flags = 49

            local playerPed = PlayerPedId()
            local newIgnoreList = {playerPed}

            local coords = GetEntityCoords(PlayerPedId())
            local closestPed, distance = QBCore.Functions.GetClosestPed(coords, newIgnoreList)
            local targetPed
            if distance <= 5 then
                targetPed = closestPed
            end

            if targetPed then
                print("targetped " ..targetPed)


                lib.callback('jaga-gangmenu:isPlayerCuffed', false, function(isTargetCuffed)
                    print(isTargetCuffed)
                    isCuffed = isTargetCuffed
                end)

                if not isCuffed then 
                    print("cuffing")
                    -- cuff logic

                    TaskPlayAnim(targetPed, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)

                    --TaskPlayAnim(playerPed, dictPlayer, 'a_arrest_on_floor', 8.0, -8, -1, flags, 0, 0, 0, 0)
                    --TaskPlayAnim(targetPed, dictTarget, 'crook_p1_back', 8.0, -8, -1, flags, 0, 0, 0, 0)
                    

                    -- voegt de boeien toe aan speler
                    if GetEntityModel(targetPed) == femaleHash then -- mp female
                        prevFemaleVariation = GetPedDrawableVariation(targetPed, 7)
                        SetPedComponentVariation(targetPed, 7, 25, 0, 0)
                    
                    -- If it's the male MP model, do the same thing as above, but for the Male ped instead.
                    elseif GetEntityModel(targetPed) == maleHash then -- mp male
                        prevMaleVariation = GetPedDrawableVariation(targetPed, 7)
                        SetPedComponentVariation(targetPed, 7, 41, 0, 0)
                    end
                     --zorgt dat je geen wapen meer kan pakken
                     --Enable the handcuffed animation using the ped, dict, anim and flags variables (defined above).
                    
                else
                    -- uncuff logic
                    ClearPedTasks(playerPed)
                end

                TriggerServerEvent('jaga-gangmenu:cuffPlayer', ped, targetPed)
                    
            else 
                print("no player near you!")
            end
        end
    end
end)

RegisterNetEvent('jaga-gangmenu:fouilleren')
AddEventHandler('jaga-gangmenu:fouilleren', function()

    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!
    -- TODO: change job to gang when script is fully tested!!!


    --get the player
    print("1")
    local player = QBCore.Functions.GetPlayerData()
    if player.job ~= nil and player.job.name ~= nil then
        local jobName = player.job.name
        local jobGrade = player.job.grade.name
        local jobDutyStatus = player.job.onduty
    
        if jobName == "mechanic" and jobDutyStatus == true then
            print("2")
            --get the vehicle entity
            local coords = GetEntityCoords(PlayerPedId())
            local target = QBCore.Functions.GetClosestPed(coords)

            if target then
                print("3")
                TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', GetPlayerServerId(target))
            else 
                print("no player near you!")
            end
        end
    end
end)


RegisterNetEvent('jaga-gangmenu:inVoertuigSteken')
AddEventHandler('jaga-gangmenu:inVoertuigSteken', function()

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

                    local seats = GetVehicleMaxNumberOfPassengers(veh)
                    local seatToPutIn = -1  -- Start with an invalid seat index
                
                    for i = -1, seats - 1 do
                        if IsVehicleSeatFree(veh, i) then
                            seatToPutIn = i  -- Set the seat index to the first available seat
                            break
                        end
                    end


                    local myPed = PlayerPedId()
                    local newIgnoreList = {myPed}

                    local coords = GetEntityCoords(myPed)
                    --local closestPlayer, distance = QBCore.Functions.GetClosestPed(coords, newIgnoreList)
                    --local closestPlayerId, closestPlayer, closestPlayerCoords = lib.getClosestPlayer(coords, 4, false)
                    
                    local targetPlayerId, distance = QBCore.Functions.GetClosestPlayer()
                    local targetId
                    targetId = GetPlayerServerId(-1) --REMOVE AFTER TESTING
                    --if player ~= -1 and distance < 3 then
                    --    targetId = GetPlayerServerId(targetPlayerId)
                    --end

                    print("Player ID: " .. targetId .. ", ped: " .. GetPlayerPed(targetId) .. " My ped: "..PlayerPedId()) -- Add this line for debugging


                    if targetId then
                        TriggerServerEvent('jaga-gangmenu:server:PutPlayerInVehicle', targetId, veh, seatToPutIn)
                        --TaskWarpPedIntoVehicle(PlayerPedId(), veh, seatToPutIn+1)
                    else 
                        print("no player near you!")
                    end

                end
            end
        end
    end
end)

RegisterNetEvent('jaga-gangmenu:client:inVoertuigGestoken')
AddEventHandler('jaga-gangmenu:client:inVoertuigGestoken', function(veh, seat)

    print("groetjes van John Atlas")

    TaskWarpPedIntoVehicle(PlayerPedId(), veh, seat)

end)

RegisterNetEvent('jaga-gangmenu:uitVoertuigHalen')
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



Citizen.CreateThread(function()
    while true do
        -- This doesn't have to be run every frame, so a 500ms delay is good enough.
        Citizen.Wait(500)
        
        -- If changed is false (the status hasn't been changed recently) check if the
        -- ped is currently cuffed. If so, check if the player is NOT playing the animation
        -- if it is NOT playing it, and it should be (according to the cuffed state variable)
        -- Wait 500ms and play the animation again.
        if not changed then
            -- Resetting the ped to the current player ped again (buggy shit be buggy)
            ped = PlayerPedId()
            
            -- Check if the player is cuffed according to the native IsPlayerCuffed()
            -- Which returns true if you ran SetEnableHandcuffs(ped, true).
            -- Returns false if that function hasn't been called or if the UncuffPed()
            -- function was called (or SetEnableHandcuffs(ped, false)).
            
            
            if isCuffed and not IsEntityPlayingAnim(ped, dict, anim, 3) then
                
                -- Wait 500ms before playing/setting the cuffed animation again.
                Citizen.Wait(500)
                TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)
            end
        
        -- If the player's cuff state has been changed in the past 500ms then don't run the code above,
        -- instead set the changed value to false, and continue the loop. This will add another 500ms
        -- before this check is ran again to make sure that the cuff animation has time to start.
        -- If we didn't do this, the player would glitch out a lot because the animation never had time
        -- to start 100% before being re-tasked to re-start the animation.
        else
            changed = false
        end
    end
end)

-- Create another loop, this one has to be ran every tick.
Citizen.CreateThread(function()
    while true do
        
        -- Wait 0ms, makes the loop run every tick.
        Citizen.Wait(0)
        
        -- (Re)set the ped _AGAIN_!
        ped = PlayerPedId()
        
        -- If the player is currently cuffed....
        if isCuffed then
            
            -- ...don't allow them to do one of the following actions by
            -- disabling all of those buttons on controller/keyboard+mouse.
            -- We don't want them to be able to use any type of attack,
            -- obviously you can't pull out your rocket launcher if you're cuffed.....
            DisableControlAction(0, 69, true) -- INPUT_VEH_ATTACK
            DisableControlAction(0, 92, true) -- INPUT_VEH_PASSENGER_ATTACK
            DisableControlAction(0, 114, true) -- INPUT_VEH_FLY_ATTACK
            DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
            DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
            DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE
            DisableControlAction(0, 257, true) -- INPUT_ATTACK2
            DisableControlAction(0, 263, true) -- INPUT_MELEE_ATTACK1
            DisableControlAction(0, 264, true) -- INPUT_MELEE_ATTACK2
            DisableControlAction(0, 24, true) -- INPUT_ATTACK
            DisableControlAction(0, 25, true) -- INPUT_AIM
            
            -- If the ped had any weapon in their hands before being cuffed, they will drop
            -- the weapon (ammo will fall on the ground, not the actual gun. However the gun
            -- will be removed from their inventory.)
            SetPedDropsWeapon(ped)
            
            -- Get the vehicle the player is currently in (if in any)
            local veh = GetVehiclePedIsIn(ped, false) 
            
            -- If the vehicle exists and it's still drivable, and the player is in the drivers seat, we want
            -- to disable steering. As you obviously can't steer a car when your hands are tied behind your back.
            -- We'll also notify te user by showing a notification without the 'bleep' sound.
            -- In case the animation is broken for whatever reason, the notification will make sure they know
            -- why they can't steer the vehicle.
            if DoesEntityExist(veh) and not IsEntityDead(veh) and GetPedInVehicleSeat(veh, -1) == ped then
                
                -- Disable A/D on keyboard & Joystick Left/Right on controller.
                DisableControlAction(0, 59, true)
                DisableControlAction(0, 60, true)
                DisableControlAction(0, 61, true)
                DisableControlAction(0, 62, true)
                DisableControlAction(0, 63, true)
                DisableControlAction(0, 64, true)

                -- Show the notification, turning off the notification sound.
                ShowHelp("Your hands are ~r~cuffed~s~, you can't stear!", false)
            end
        end
    end
end)


-- Show a help message (top left corner).
-- This is a simplefied version. Input text length is limited.
function ShowHelp(text, bleep)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, bleep, -1)
end


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
        print("cuff event")
        TriggerEvent('jaga-gangmenu:cuff')
    --fouilleren
    elseif selected == 2 then 
        print("frisk event")
        TriggerEvent('jaga-gangmenu:fouilleren')
    --in auto steken
    elseif selected == 3 then 
        print("car in event")
        TriggerEvent('jaga-gangmenu:inVoertuigSteken')
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


