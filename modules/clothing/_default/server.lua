--[[This module is incomplete]]--

Clothing = Clothing or {}

Clothing.SetAppearance = function(src, data)
    TriggerClientEvent('community_bridge:client:SetAppearance', src, data)
end

Clothing.RestoreAppearance = function(src)
    TriggerClientEvent('community_bridge:client:RestoreAppearance', src)
end

Clothing.ReloadSkin = function(src)
    TriggerClientEvent('community_bridge:client:ReloadSkin', src)
end


RegisterNetEvent('community_bridge:client:SetAppearance', function(data)
    Clothing.SetAppearance(data)
end)

RegisterNetEvent('community_bridge:client:GetAppearance', function()
    Clothing.GetAppearance()
end)

RegisterNetEvent('community_bridge:client:RestoreAppearance', function()
    Clothing.RestoreAppearance()
end)

RegisterNetEvent('community_bridge:client:ReloadSkin', function()
    Clothing.ReloadSkin()
end)

return Clothing