if GetResourceState('ti_vehicleKeys') ~= 'started' then return end
VehicleKey = {}

VehicleKey.GiveKeys = function(vehicle, plate)
    exports['ti_vehicleKeys']:addTemporaryVehicle(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return
end
