if GetResourceState('qb-appartments') ~= 'started' then return end

Housing = Housing or {}

RegisterNetEvent('qb-apartments:server:SetInsideMeta', function(house, insideId, bool, isVisiting)
    local src = source
    insideId = bool and house .. '-' .. insideId or nil
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, insideId)
end)

return Housing