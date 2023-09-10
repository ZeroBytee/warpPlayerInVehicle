-- maak een lijst die dat alle gecuffde spelers bijhoud
local QBCore = exports['qb-core']:GetCoreObject()

local playerCuffStatus = {}

lib.callback.register('jaga-gangmenu:isPlayerCuffed', function(target)
    return playerCuffStatus[target] or false
end)



local function IsPlayerCuffed(playerPedId)
    return playerCuffStatus[playerPedId] or false
end


RegisterNetEvent('jaga-gangmenu:server:PutPlayerInVehicle', function(playerId, veh, freeSeat)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 3 then return DropPlayer(src, "Attempted exploit abuse") end

    --local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) then return end
    TriggerClientEvent("jaga-gangmenu:client:inVoertuigGestoken", playerId, veh, freeSeat)
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)

RegisterNetEvent('jaga-gangmenu:server:TakePlayerOutOfVehicle', function(playerId, veh)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 3 then return DropPlayer(src, "Attempted exploit abuse") end

    --local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) then return end
    TriggerClientEvent("jaga-gangmenu:client:uitVoertuigGehaald", playerId, veh)
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)

RegisterNetEvent('jaga-gangmenu:server:cuffPlayer', function(targetId)

    local dictPlayer = "mp_arresting"
    local dictTarget = "mp_arrest_paired"
    local animPlayer = "idle" -- a_arrest_on_floor
    local animTarget = "idle" -- a_arrest_on_floor
    local flags = 49


    local isCuffed = IsPlayerCuffed(targetPed)

    if isCuffed then 
        -- uncuff logic
        print("cuffed, uncuffing")
        playerCuffStatus[targetPed] = false
    else 
        -- cuff logic
        print("not cuffed, cuffing")

        -- add player to cuffed variable
        playerCuffStatus[targetPed] = true
        print(IsPlayerCuffed(targetPed))
    end

    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 3 then return DropPlayer(src, "Attempted exploit abuse") end

    --local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) then return end
    TriggerClientEvent("jaga-gangmenu:client:uitVoertuigGehaald", targetId)
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)

RegisterNetEvent('police:server:CuffPlayer', function(position, id, item)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(id)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(playerCoords - targetCoords) > 2.5 then DropPlayer(src, "Attempted exploit abuse") end

    local Player = QBCore.Functions.GetPlayer(src)
    local CuffedPlayer = QBCore.Functions.GetPlayer(id)
    if not Player or not CuffedPlayer or not Player.Functions.GetItemByName(item) then return end
    TriggerClientEvent('police:client:GetCuffed', CuffedPlayer.PlayerData.source, Player.PlayerData.source, position, item)
end)

RegisterNetEvent('police:server:SetHandcuffStatus', function(isHandcuffed, cuffitem, position)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    if Player then
        Player.Functions.SetMetaData("ishandcuffed", isHandcuffed)
        if isHandcuffed then
            playerCuffStatus[citizenid] = {cuffed = true, item = cuffitem, pos = position}
        else
            playerCuffStatus[citizenid] = nil
        end
    end
end)