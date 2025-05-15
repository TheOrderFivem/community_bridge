Housing = Housing or {}

---This is an internal event, listen for 'community_bridge:Client:OnPlayerInside' instead.
---This event is triggered when a player enters or leaves a property.
---@param src number
---@param insideId string
RegisterNetEvent('community_bridge:Server:_OnPlayerInside', function(src, insideId)
    local currentBucket = GetPlayerRoutingBucket(src)
    local playerEntity = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerEntity)
    TriggerEvent('community_bridge:Client:OnPlayerInside', src, insideId, currentBucket, playerCoords)
end)

return Housing