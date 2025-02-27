if GetResourceState('esx_skin') ~= 'started' then return end
Clothing = Clothing or {}

local illeniumModule = Require('modules/clothing/illenium-appearance/client.lua')
local ConvertToIlleniumFormat = illeniumModule.ConvertToIlleniumFormat

Clothing.SetAppearance = function(clothingData)
    local illeniumData = ConvertToIlleniumFormat(clothingData)
    ClothingBackup = Clothing.GetAppearance()
    TriggerEvent('skinchanger:loadSkin', illeniumData)
    return true
end

Clothing.GetAppearance = function()
    local skin
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(appearance)
        skin = appearance
    end)
    Wait(0)
    return ConvertToIlleniumFormat(skin)
end

Clothing.RestoreAppearance = function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    return true
end

Clothing.ReloadSkin = function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    return true
end

