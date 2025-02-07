if GetResourceState('qs-fuelstations') ~= 'started' then return end

Fuel = {}

Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return exports['qs-fuelstations']:GetFuel(vehicle)
end

Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    return exports['qs-fuelstations']:SetFuel(vehicle, fuel)
end
