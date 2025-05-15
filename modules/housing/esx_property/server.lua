if GetResourceState('esx_property') ~= 'started' then return end

Housing = Housing or {}

RegisterNetEvent('esx_property:enter', function(insideId)
    local src = source
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

RegisterNetEvent('esx_property:leave', function(insideId)
    local src = source
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

return Housing