if GetResourceState('ps-housing') ~= 'started' then return end

Housing = Housing or {}

RegisterNetEvent('ps-housing:server:enterProperty', function(insideId)
    local src = source
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

RegisterNetEvent('ps-housing:server:leaveProperty', function(insideId)
    local src = source
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

return Housing