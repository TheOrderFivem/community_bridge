if GetResourceState('qb-clothing') ~= 'started' then return end

RegisterNetEvent('qb-clothing:saveSkin', function(model, skin)
    local src = source
    if model and skin then
        local illeniumModule = Require('modules/clothing/illenium-appearance/server.lua')
        local ConvertToIlleniumFormat = illeniumModule.ConvertToIlleniumFormat
        local illeniumSkin = ConvertToIlleniumFormat(skin)
        TriggerClientEvent('community_bridge:client:updateClothingBackup', src, illeniumSkin)
    end
end)

