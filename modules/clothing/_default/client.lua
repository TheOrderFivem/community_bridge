--[[This module is incomplete]]--

Clothing = Clothing or {}

ClothingBackup = {}


---This will set the peds skin data to the specified table. It will also store previous skin in the event it needs returned to original.
---@param data table
---@return boolean
Clothing.SetAppearance = function(data)
    ClothingBackup = Clothing.GetAppearance()
    Utility.SetEntitySkinData(cache.ped, data)
    return true
end

---This will return a table of the players ped appearance
---@return table
Clothing.GetAppearance = function()
    return Utility.GetEntitySkinData(cache.ped)
end

---This will return the peds clothing to the previously stored clothing
---@return boolean
Clothing.RestoreAppearance = function()
    Utility.SetEntitySkinData(cache.ped, ClothingBackup)
    return true
end

---This will reload the peds skin data from the backup table. This is used when the skin data is changed and needs to be reloaded.
---@return boolean
Clothing.ReloadSkin = function()
    Utility.SetEntitySkinData(cache.ped, ClothingBackup)
    return true
end

Clothing.UpdateAppearanceBackup = function(data)
    ClothingBackup = data
end

RegisterNetEvent('community_bridge:client:updateClothingBackup', function(skindata)
    ClothingBackup = skindata
end)

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