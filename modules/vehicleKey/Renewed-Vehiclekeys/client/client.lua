local resourceName = "Renewed-Vehiclekeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports['Renewed-Vehiclekeys']:addKey(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports['Renewed-Vehiclekeys']:removeKey(plate)
end

return VehicleKey