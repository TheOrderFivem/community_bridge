local resourceName = "F_RealCarKeysSystem"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('F_RealCarKeysSystem:generateVehicleKeys', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end

return VehicleKey