local resourceName = "mono_carkeys"
local configValue = BridgeClientConfig.VehicleKey
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

VehicleKey = VehicleKey or {}
VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('mono_carkeys:CreateKey', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate then return false end
    TriggerServerEvent('mono_carkeys:DeleteKey', 1, plate)
end

return VehicleKey