searchPlayer = function(player)
    if Config.inventory == 'ox' then
        exports.ox_inventory:openNearbyInventory()
    elseif Config.inventory == 'qs' or Config.inventory == 'qb' then
        TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', GetPlayerServerId(player))
    end
end

exports('searchPlayer', searchPlayer)



lib.callback.register('jaga-gangmenu:isPlayerCuffed', function(target)
    -- haal de variable van de database, en return true or false
    return true
end)