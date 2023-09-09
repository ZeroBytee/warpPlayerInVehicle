-- maak een lijst die dat alle gecuffde spelers bijhoud

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