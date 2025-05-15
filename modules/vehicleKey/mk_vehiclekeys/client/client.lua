local resourceName = "mk_vehiclekeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not vehicle and not DoesEntityExist(vehicle) then return false end
    return exports["mk_vehiclekeys"]:AddKey(vehicle)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not vehicle and not DoesEntityExist(vehicle) then return false end
    return exports["mk_vehiclekeys"]:RemoveKey(vehicle)
end

return VehicleKey