local resourceName = "fast-vehiclekeys"
if GetResourceState(resourceName) == 'missing' then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerEvent('fast-vehiclekeys:GiveTempKey', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    TriggerServerEvent("fast-vehiclekeys:RemoveTempKey", plate)
end

return VehicleKey