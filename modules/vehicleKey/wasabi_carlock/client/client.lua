local resourceName = "wasabi_carlock"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate and vehicle then plate = GetVehicleNumberPlateText(vehicle) end
    exports.wasabi_carlock:GiveKey(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate and vehicle then plate = GetVehicleNumberPlateText(vehicle) end
    exports.wasabi_carlock:RemoveKey(plate)
end

return VehicleKey