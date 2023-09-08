

lib.callback.register('jaga-gangmenu:isPlayerCuffed', function(target)
    local isCuffed = wsb.getPlayerIdentity(target)
    return isCuffed
end)