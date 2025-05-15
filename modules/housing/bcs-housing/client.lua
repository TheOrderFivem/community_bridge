if GetResourceState('bcs-housing') ~= 'started' then return end

Housing = Housing or {}

RegisterNetEvent('Housing:client:EnterHome', function(insideId)
    TriggerServerEvent('community_bridge:Server:_OnPlayerInside', insideId)
end)

RegisterNetEvent("Housing:client:DeleteFurnitures", function()
    TriggerServerEvent('community_bridge:Server:_OnPlayerInside', false)
end)

return Housing