---@diagnostic disable: duplicate-set-field
Clothing = Clothing or {}
Callback = Callback or Require("lib/callback/shared/callback.lua")

local ClothingBackup = {}

---This will get the name of the in use resource.
---@return string
function Clothing.GetResourceName()
    return 'default'
end

---This will open the clothing menu for a player, in the event there is not a supported menu it will print that.
function Clothing.OpenMenu()
    print("^6 No supported clothing menu in use in community_bridge. ^0 ")
end

---This will check if the player model if male/female
---@return boolean
function Clothing.IsMale()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return false end
    if GetEntityModel(ped) == `mp_m_freemode_01` then return true end
    return false
end

---Get the skin data of a ped
---@param entity number
---@return table
function Clothing.GetAppearance(entity)
    if not entity and not DoesEntityExist(entity) then return {} end
    local model = GetEntityModel(entity)
    local skinData = { model = model, components = {}, props = {} }
    for i = 0, 11 do
        table.insert(skinData.components,
            { component_id = i, drawable = GetPedDrawableVariation(entity, i), texture = GetPedTextureVariation(entity, i) })
    end
    for i = 0, 13 do
        table.insert(skinData.props,
            { prop_id = i, drawable = GetPedPropIndex(entity, i), texture = GetPedPropTextureIndex(entity, i) })
    end
    ClothingBackup = skinData
    return skinData
end

lib.callback.register('community_bridge:cb:GetAppearance', function()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return end
    local skinData = Clothing.GetAppearance(ped)
    return skinData
end)

---Apply skin data to a ped
---@param ped number
---@param skinData table
---@return boolean
function Clothing.SetAppearance(ped, skinData)
    for k, v in pairs(skinData.components or {}) do
        if v.component_id then
            SetPedComponentVariation(ped, v.component_id, v.drawable, v.texture, 0)
        end
    end
    for k, v in pairs(skinData.props or {}) do
        if v.prop_id then
            SetPedPropIndex(ped, v.prop_id, v.drawable, v.texture, false)
        end
    end
    ClothingBackup = nil
    return true
end

---This will return the peds components to the previously stored components
---@param ped number
---@return boolean
Clothing.RestoreAppearance = function(ped)
    Clothing.SetAppearance(ped, ClothingBackup)
    return true
end

RegisterNetEvent('community_bridge:client:SetAppearance', function(data)
    if source ~= 65535 then return end
    Clothing.SetAppearance(PlayerPedId(), data)
end)

RegisterNetEvent('community_bridge:client:GetAppearance', function()
    if source ~= 65535 then return end
    Clothing.GetAppearance(PlayerPedId())
end)

RegisterNetEvent('community_bridge:client:RestoreAppearance', function()
    if source ~= 65535 then return end
    Clothing.RestoreAppearance(PlayerPedId())
end)

return Clothing