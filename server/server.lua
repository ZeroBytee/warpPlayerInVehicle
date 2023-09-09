-- maak een lijst die dat alle gecuffde spelers bijhoud

--lib.callback.register('jaga-gangmenu:isPlayerCuffed', function(target)
--    local isCuffed = wsb.getPlayerIdentity(target)
--    return isCuffed
--end)

local playerCuffStatus = {}

local function IsPlayerCuffed(playerPedId)
    return playerCuffStatus[playerPedId] or false
end



RegisterNetEvent('jaga-gangmenu:cuffPlayer')
AddEventHandler('jaga-gangmenu:cuffPlayer', function(playerPed, targetPed)

    local dict = "mp_arresting"
    local anim = "idle" -- a_arrest_on_floor
    local flags = 49

    local isCuffed = isPlayerCuffed(targetPed)

    if isCuffed then 
        -- uncuff logic
        playerCuffStatus[targetPlayerPedId] = false
    else 
        -- cuff logic
        TaskPlayAnim(ped, dict, 'a_arrest_on_floor', 8.0, -8, -1, flags, 0, 0, 0, 0)

        Citizen.Wait(4000)
        ClearPedTasks(ped)
        -- voegt de boeien toe aan speler
        if GetEntityModel(targetPed) == femaleHash then -- mp female
            prevFemaleVariation = GetPedDrawableVariation(targetPed, 7)
            SetPedComponentVariation(targetPed, 7, 25, 0, 0)
        
        -- If it's the male MP model, do the same thing as above, but for the Male ped instead.
        elseif GetEntityModel(targetPed) == maleHash then -- mp male
            prevMaleVariation = GetPedDrawableVariation(targetPed, 7)
            SetPedComponentVariation(targetPed, 7, 41, 0, 0)
        
        -- zorgt dat je geen wapen meer kan pakken
        SetEnableHandcuffs(targetPed, true)
        -- Enable the handcuffed animation using the ped, dict, anim and flags variables (defined above).
        TaskPlayAnim(targetPed, dict, anim, 8.0, -8, -1, flags, 0, 0, 0, 0)
    
        -- add player to cuffed variable
        playerCuffStatus[targetPlayerPedId] = true
    end



    



end)