Clothing = Clothing or {}

local illeniumModule = Require('modules/clothing/illenium-appearance/client.lua')
local ConvertToIlleniumFormat = illeniumModule.ConvertToIlleniumFormat

ClothingBackup = {}

Clothing.SetAppearance = function(data)
    ClothingBackup = Clothing.GetAppearance()
    Utility.SetEntitySkinData(cache.ped, data)
    return true
end

Clothing.GetAppearance = function()
    local defaultData = Utility.GetEntitySkinData(cache.ped)
    return ConvertToIlleniumFormat(defaultData)
end

Clothing.RestoreAppearance = function()
    Utility.SetEntitySkinData(cache.ped, ClothingBackup)
    return true
end

Clothing.ReloadSkin = function()
    Utility.SetEntitySkinData(cache.ped, ClothingBackup)
    return true
end

Clothing.UpdateAppearanceBackup = function(data)
    ClothingBackup = ConvertToIlleniumFormat(data)
end

RegisterNetEvent('community_bridge:client:updateClothingBackup', function(skindata)
    ClothingBackup = ConvertToIlleniumFormat(skindata)
end)

RegisterNetEvent('community_bridge:client:SetAppearance', function(data)
    Clothing.SetAppearance(data)
end)

RegisterNetEvent('community_bridge:client:GetAppearance', function()
    return Clothing.GetAppearance()
end)

RegisterNetEvent('community_bridge:client:RestoreAppearance', function()
    Clothing.RestoreAppearance()
end)

RegisterNetEvent('community_bridge:client:ReloadSkin', function()
    Clothing.ReloadSkin()
end)

