if GetResourceState('mono_carkeys') ~= 'started' then return end

VehicleKey = {}
VehicleKey.GiveKeys = function(vehicle, plate)
    if type(plate) ~= 'string' then return end
    TriggerServerEvent('mono_carkeys:CreateKey', plate)
end

VehicleKey.RemoveKeys = function(vehicle, plate)
    if type(plate) ~= 'string' then return end
    TriggerServerEvent('mono_carkeys:DeleteKey', 1, plate)
end
