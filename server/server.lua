RegisterNetEvent('qb-vab:fixVehicle', function(vehicleId)
    local playerId = source

    --get vehicleId from target and repair
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleEngineOn(vehicle, true, true)

    -- Fix wheels
    for i = 0, 12 do
        SetVehicleTyreFixed(vehicle, i)
    end

    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            FixVehicleWindow(vehicle, i)
        end
    end

end)