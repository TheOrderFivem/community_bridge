local resourceName = "qbx_vehiclekeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}

VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    return true
end

return VehicleKey