-- maak een lijst die dat alle gecuffde spelers bijhoud
local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent('jaga-gangmenu:server:PutPlayerInVehicle', function(playerId, veh, freeSeat)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    --if #(playerCoords - targetCoords) > 3 then return DropPlayer(src, "Attempted exploit abuse") end

    --local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) then return end
    print("event received")
    TriggerClientEvent("jaga-gangmenu:client:inVoertuigGestoken", playerId, veh, freeSeat)
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)

RegisterNetEvent('jaga-gangmenu:server:TakePlayerOutOfVehicle', function(playerId, veh)
    local src = source
    local playerPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(playerId)
    local playerCoords = GetEntityCoords(playerPed)
    local targetCoords = GetEntityCoords(targetPed)
    --if #(playerCoords - targetCoords) > 3 then return DropPlayer(src, "Attempted exploit abuse") end

    --local EscortPlayer = QBCore.Functions.GetPlayer(playerId)
    if not QBCore.Functions.GetPlayer(src) then return end
    print("event received2")
    TriggerClientEvent("jaga-gangmenu:client:uitVoertuigGehaald", playerId, veh)
    print("sent")
    
    --TaskWarpPedIntoVehicle(playerPed, veh, -1)
end)
