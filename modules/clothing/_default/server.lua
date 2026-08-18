---@diagnostic disable: duplicate-set-field
Clothing = Clothing or {}
Clothing.LastAppearance = Clothing.LastAppearance or {}

---This will get the name of the in use resource.
---@return string
Clothing.GetResourceName = function()
    return 'default'
end

---This will check if the player model if male/female
---@param src number
---@return boolean
function Clothing.IsMale(src)
    local ped = GetPlayerPed(src)
    if not ped or not DoesEntityExist(ped) then return false end
    return GetEntityModel(ped) == `mp_m_freemode_01`
end

---Get the skin data of a player
---@param src number
---@return table
function Clothing.GetAppearance(src)
    return lib.callback.await('community_bridge:cb:GetAppearance', src)
end

---Apply skin data to a player
---@param src number
---@param data table
function Clothing.SetAppearance(src, data)
    local strSrc = tostring(src)
    Clothing.LastAppearance[strSrc] = Clothing.GetAppearance(src)
    TriggerClientEvent('community_bridge:client:SetAppearance', src, data)
end

--- Sets a player's appearance based on gender-specific data
---@param src number The server ID of the player
---@param data table Table containing separate appearance data for male and female characters
---@return table|nil Appearance updated player appearance data or nil if failed
function Clothing.SetAppearanceExt(src, data)
    local tbl = Clothing.IsMale(src) and data.male or data.female
    Clothing.SetAppearance(src, tbl)
end

---Restore the last saved appearance of a player
---@param src number
function Clothing.RestoreAppearance(src)
    TriggerClientEvent('community_bridge:client:RestoreAppearance', src)
end

return Clothing