local resourceName = "MrNewbVehicleKeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    return exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
end

return VehicleKey