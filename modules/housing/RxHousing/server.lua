if GetResourceState('RxHousing') == 'missing' then return end

Housing = Housing or {}

RegisterNetEvent('rxhousing:onPropertyEntered', function(src, property, isBreakIn, isRaid)
    if not property or not property.id then return end
    -- Triggers the community_bridge universal event so other scripts know the player is in a house
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, tostring(property.id))
end)

RegisterNetEvent('rxhousing:onPropertyExited', function(src, propertyId)
    -- Triggers the community_bridge universal event so other scripts know the player left
    TriggerEvent('community_bridge:Server:_OnPlayerInside', src, nil)
end)

---This will get the name of the in use resource.
---@return string
Housing.GetResourceName = function()
    return "RxHousing"
end

return Housing
