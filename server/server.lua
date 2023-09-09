-- maak een lijst die dat alle gecuffde spelers bijhoud
local QBCore = exports['qb-core']:GetCoreObject()

local playerCuffStatus = {}

lib.callback.register('jaga-gangmenu:isPlayerCuffed', function(target)
    return playerCuffStatus[target] or false
end)



local function IsPlayerCuffed(playerPedId)
    return playerCuffStatus[playerPedId] or false
end



RegisterNetEvent('jaga-gangmenu:cuffPlayer')
AddEventHandler('jaga-gangmenu:cuffPlayer', function(playerPed, targetPed)

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

end)

QBCore.Functions.CreateCallback('getClosestPlayer', function(source, cb, targetPlayerId)
    local sourcePlayer = QBCore.Functions.GetPlayer(source)
    local targetPlayer = QBCore.Functions.GetPlayer(targetPlayerId)

    if not sourcePlayer or not targetPlayer then
        cb(nil)
        return
    end

    local sourceCoords = sourcePlayer.PlayerData.coords
    local targetCoords = targetPlayer.PlayerData.coords

    local closestPlayerId = nil
    local closestDistance = nil

    for playerId, player in pairs(QBCore.Functions.GetPlayers()) do
        if playerId ~= source and playerId ~= targetPlayerId then
            local playerCoords = player.PlayerData.coords
            local distance = #(sourceCoords - playerCoords)
            print("Player ID: " .. playerId .. " - Distance: " .. distance)

            if closestDistance == nil or distance < closestDistance then
                closestPlayerId = playerId
                closestDistance = distance
            end
        end
    end

    cb(closestPlayerId)
end)


RegisterNetEvent('jaga-gangmenu:server:PutPlayerInVehicle', function(playerId, veh, freeSeat)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    --if #(playerCoords - targetCoords) > 2.5 then return DropPlayer(src, "Attempted exploit abuse") end

    local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) or not EscortPlayer then return end
    print("server sent1")
    TriggerClientEvent("jaga-gangmenu:client:inVoertuigGestoken", playerId, veh, freeSeat)
    print("server sent2")
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)