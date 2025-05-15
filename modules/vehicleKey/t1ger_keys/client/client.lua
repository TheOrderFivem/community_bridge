local resourceName = "t1ger_keys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not DoesEntityExist(vehicle) then return false end
    local vehicle_display_name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    return exports['t1ger_keys']:GiveTemporaryKeys(plate, vehicle_display_name, 'some_keys')
end

VehicleKey.RemoveKeys = function(vehicle, plate)

end

return VehicleKey