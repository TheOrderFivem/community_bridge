if GetResourceState('lj-fuel') ~= 'started' then return end

Fuel = {}

Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return exports['lj-fuel']:GetFuel(vehicle)
end

Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    return exports['lj-fuel']:SetFuel(vehicle, fuel)
end
