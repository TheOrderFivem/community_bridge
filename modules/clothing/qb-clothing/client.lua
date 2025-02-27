if GetResourceState('qb-clothing') ~= 'started' then return end
Clothing = Clothing or {}

local illeniumModule = Require('modules/clothing/illenium-appearance/client.lua')
local ConvertToIlleniumFormat = illeniumModule.ConvertToIlleniumFormat

Clothing.SetAppearance = function(data)
    local illeniumData = ConvertToIlleniumFormat(data)
    ClothingBackup = Clothing.GetAppearance()
    TriggerEvent('qb-clothing:client:loadOutfit', illeniumData)
    return true
end

Clothing.GetAppearance = function()
    local clothingData = exports['qb-clothing']:GetCurrentOutfit()
    return ConvertToIlleniumFormat(clothingData)
end

Clothing.RestoreAppearance = function()
    return Utility.SetEntitySkinData(cache.ped, ClothingBackup)
end

Clothing.ReloadSkin = function()
    return exports['qb-clothing']:reloadSkin(GetEntityHealth(cache.ped))
end

