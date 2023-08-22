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


--REPAIR SYSTEM

--Register the repair vehicle command
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




-- JOB MENU
-- Job menu
openJobMenu = function()
    if not wsb.hasGroup(Config.policeJobs) then return end
    if not wsb.isOnDuty() then return end
    local _job, grade = wsb.hasGroup(Config.policeJobs)
    local jobLabel = Strings.police
    local Options = {}
    if Config.searchPlayers then
        Options[#Options + 1] = {
            title = Strings.search_player,
            description = Strings.search_player_desc,
            icon = 'magnifying-glass',
            arrow = false,
            event = 'wasabi_police:searchPlayer',
        }
    end
    Options[#Options + 1] = {
        title = Strings.check_id,
        description = Strings.check_id_desc,
        icon = 'id-card',
        arrow = true,
        event = 'wasabi_police:checkId',
    }
    if Config?.GrantWeaponLicenses?.enabled and tonumber(grade or 0) >= Config.GrantWeaponLicenses.minGrade then
        Options[#Options + 1] = {
            title = Strings.grant_license,
            description = Strings.grant_license_desc,
            icon = 'id-card',
            arrow = true,
            event = 'wasabi_police:grantLicense',
        }
    end
    if Config.Jail.enabled then
        Options[#Options + 1] = {
            title = Strings.jail_player,
            description = Strings.jail_player_desc,
            icon = 'lock',
            arrow = false,
            event = 'wasabi_police:sendToJail',
        }
    end
    Options[#Options + 1] = {
        title = Strings.handcuff_soft_player,
        description = Strings.handcuff_soft_player_desc,
        icon = 'hands-bound',
        arrow = false,
        args = { type = 'soft' },
        event = 'wasabi_police:handcuffPlayer',
    }
    Options[#Options + 1] = {
        title = Strings.handcuff_hard_player,
        description = Strings.handcuff_hard_player_desc,
        icon = 'hands-bound',
        arrow = false,
        args = { type = 'hard' },
        event = 'wasabi_police:handcuffPlayer',
    }
    Options[#Options + 1] = {
        title = Strings.escort_player,
        description = Strings.escort_player_desc,
        icon = 'hand-holding-hand',
        arrow = false,
        event = 'wasabi_police:escortPlayer',
    }
    if Config.GSR.enabled then
        Options[#Options + 1] = {
            title = Strings.gsr_test,
            description = Strings.gsr_test_desc,
            icon = 'gun',
            arrow = false,
            event = 'wasabi_police:gsrTest',
        }
    end
    Options[#Options + 1] = {
        title = Strings.put_in_vehicle,
        description = Strings.put_in_vehicle_desc,
        icon = 'arrow-right-to-bracket',
        arrow = false,
        event = 'wasabi_police:inVehiclePlayer',
    }
    Options[#Options + 1] = {
        title = Strings.take_out_vehicle,
        description = Strings.take_out_vehicle_desc,
        icon = 'arrow-right-from-bracket',
        arrow = false,
        event = 'wasabi_police:outVehiclePlayer',
    }
    Options[#Options + 1] = {
        title = Strings.vehicle_interactions,
        description = Strings.vehicle_interactions_desc,
        icon = 'car',
        arrow = true,
        event = 'wasabi_police:vehicleInteractions',
    }
    Options[#Options + 1] = {
        title = Strings.place_object,
        description = Strings.place_object_desc,
        icon = 'box',
        arrow = true,
        event = 'wasabi_police:placeObjects',
    }
    if Config.billingSystem then
        Options[#Options + 1] = {
            title = Strings.fines,
            description = Strings.fines_desc,
            icon = 'file-invoice',
            arrow = false,
            event = 'wasabi_police:finePlayer',
        }
    end
    if Config.MobileMenu.enabled then
		OpenMobileMenu('vab_job_menu', jobLabel, Options)
	else
        lib.registerContext({
            id = 'vab_job_menu',
            title = jobLabel,
            options = Options
        })
        lib.showContext('vab_job_menu')
    end
end


RegisterCommand('+vabJobMenu', function()
    openJobMenu()
end)

AddEventHandler('astroRP:vabJobMenu', function()
    openJobMenu()
end)

RegisterKeyMapping('+vabJobMenu', 'Open Job Menu', 'keyboard', Config.jobMenu)


