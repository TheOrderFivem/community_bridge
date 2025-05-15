local resourceName = "jaksams_VehiclesKeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return TriggerServerEvent("vehicles_keys:selfGiveVehicleKeys", plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return TriggerServerEvent("vehicles_keys:selfRemoveKeys", plate)
end

return VehicleKey