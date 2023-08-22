RegisterNetEvent('QB-VAB:fixVehicle')
AddEventHandler('QB-VAB:fixVehicle', function(vehicleNetId)
    local playerId = source
    print("debug2")
    -- Get the vehicle entity from the network ID
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    print("debug3")
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        print("debug4")
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, true)
        print("debug5")

        -- Fix wheels
        for i = 0, 12 do
            print("debug6")
            SetVehicleTyreFixed(vehicle, i)
        end

        for i = 0, 7 do
            if not IsVehicleWindowIntact(vehicle, i) then
                print("debug7")
                FixVehicleWindow(vehicle, i)
            end
        end
    end
end)
