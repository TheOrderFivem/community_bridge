---@diagnostic disable: duplicate-set-field
if GetResourceState('illenium-appearance') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end
if GetResourceState('17mov_CharacterSystem') ~= 'missing' then return end
Clothing = Clothing or {}
Clothing.Players = {}

Callback = Callback or Require("lib/utility/shared/callbacks.lua")
Table = Table or Require('lib/utility/shared/tables.lua')

--- Internal function to get the full appearance data including skin, model, and converted format
---@param src number The server ID of the player
---@return table|nil The player's full appearance data or nil if not found
function Clothing.GetFullAppearanceData(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local citId = Bridge.Framework.GetPlayerIdentifier(src)
    if not citId then return end

    if Clothing.Players[citId] then return Clothing.Players[citId] end

    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', { citId, 1 })
    if result[1] == nil then return end

    local model = result[1].model
    local skinData = json.decode(result[1].skin)
    local converted = skinData

    -- Store complete data in the cache
    Clothing.Players[citId] = {
        model = model,
        skin = skinData,
        converted = converted
    }

    return Clothing.Players[citId]
end

---This will get the name of the in use resource.
---@return string
Clothing.GetResourceName = function()
    return 'illenium-appearance'
end

--- Retrieves a player's converted appearance data for easy use across modules
---@param src number The server ID of the player
---@param fullData boolean Optional - If true, returns the full data object including skin and model
---@return table|nil The player's converted appearance data or full appearance data if fullData=true
function Clothing.GetAppearance(src, fullData)
    if fullData then
        return Clothing.GetFullAppearanceData(src)
    end
    local completeData = Clothing.GetFullAppearanceData(src)
    if not completeData then return nil end
    return completeData.converted
end

--- Sets a player's appearance based on the provided data
---@param src number The server ID of the player
---@param data table The appearance data to apply
---@param updateBackup boolean Whether to update the backup appearance data
---@return table|nil The updated player appearance data or nil if failed
function Clothing.SetAppearance(src, data, updateBackup, save)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local citId = Bridge.Framework.GetPlayerIdentifier(src)
    if not citId then return end
    local model = GetEntityModel(GetPlayerPed(src))
    if not model then return end
    local converted = data

    -- Get full appearance data
    local currentClothing = Clothing.GetFullAppearanceData(src)
    if not currentClothing then return end

    local currentSkin = currentClothing.skin
    for k, v in pairs(converted) do
        currentSkin[k] = v
    end

    if not Clothing.Players[citId].backup or updateBackup then
        Clothing.Players[citId].backup = currentClothing.converted
    end

    Clothing.Players[citId] = Clothing.Players[citId] or {}
    Clothing.Players[citId].skin = currentSkin
    Clothing.Players[citId].model = model
    Clothing.Players[citId].converted = converted
    if save then
        MySQL.update.await('UPDATE playerskins SET skin = ? WHERE citizenid = ? AND active = ?', {
            json.encode(currentSkin),
            citId,
            1
        })
    end
    TriggerClientEvent('community_bridge:client:SetAppearance', src, Clothing.Players[citId].converted)
    return Clothing.Players[citId]
end

--- Sets a player's appearance based on gender-specific data
---@param src number The server ID of the player
---@param data table Table containing separate appearance data for male and female characters
---@return table|nil Appearance updated player appearance data or nil if failed
function Clothing.SetAppearanceExt(src, data)
    local tbl = Clothing.IsMale(src) and data.male or data.female
    Clothing.SetAppearance(src, tbl)
end

--- Reverts a player's appearance to their backup appearance
---@param src number The server ID of the player
---@return boolean|nil Returns true if successful or nil if failed
function Clothing.Revert(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local currentClothing = Clothing.GetFullAppearanceData(src)
    if not currentClothing then return end
    local backup = currentClothing.backup
    print(src, backup)
    if not backup then return end
    return Clothing.SetAppearance(src, backup)
end

function Clothing.OpenMenu(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    TriggerClientEvent('qb-clothing:client:openMenu', src)
end

--- Event handler for when a player loads into the server
--- Caches the player's appearance data
AddEventHandler('community_bridge:Server:OnPlayerLoaded', function(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    -- Use GetFullAppearanceData to cache the complete appearance
    Clothing.GetFullAppearanceData(src)
end)

--- Event handler for when a player disconnects from the server
--- Removes the player's appearance data from the cache
AddEventHandler('community_bridge:Server:OnPlayerUnload', function(src)
    src = src and tonumber(src)
    assert(src, "src is nil")
    local strSrc = tostring(src)
    Clothing.Players[strSrc] = nil
end)



--- Event handler for when the resource starts
--- Caches appearance data for all currently connected players
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local strSrc = tostring(src)
        if not Clothing.Players[strSrc] then
            Clothing.Players[strSrc] = Clothing.GetAppearance(src)
        end
    end
end)

--- Callback handler for retrieving a player's appearance data
Callback.Register('community_bridge:cb:GetAppearance', function(source)
    local src = source
    return Clothing.GetAppearance(src)
end)

-- All the this below should go in unit tests if we are to continue using them.
-- RegisterCommand('clothing:debug', function(source, args, rawCommand)
--     local src = source
--     Clothing.SetAppearance(src, {
--         components = {
--             { component_id = 0,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 1,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 2,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 3,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 4,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 5,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 6,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 7,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 8,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 9,  drawable = math.random(0, 50), texture = 0 },
--             { component_id = 10, drawable = math.random(0, 50), texture = 0 },
--             { component_id = 11, drawable = math.random(0, 50), texture = 0 },
--         },
--         props = {
--             { prop_id = 0,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 1,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 2,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 3,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 4,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 5,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 6,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 7,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 8,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 9,  drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 10, drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 11, drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 12, drawable = math.random(0, 50), texture = 0 },
--             { prop_id = 13, drawable = math.random(0, 50), texture = 0 },
--         }
--     }, false, true)
-- end, false)


-- RegisterCommand('clothing:revert', function(source, args, rawCommand)
--     local src = source
--     Clothing.Revert(src)
-- end, false)


-- RegisterCommand('clothing:current', function(source, args, rawCommand)
--     local src = source
--     local currentClothing = Clothing.GetAppearance(src)
--     if not currentClothing then return end
--     print(json.encode(currentClothing, { indent = true }))
-- end, false)

-- RegisterCommand('clothing:openmenu', function(source, args, rawCommand)
--     local src = source
--     Clothing.OpenMenu(src)
-- end, false)


-- RegisterCommand('clothing:crowley', function(source, args, rawCommand)
--     local src = source
--     Clothing.SetAppearance(src, {
--         components = {
--             { drawable = 0,  texture = 0, component_id = 0 },
--             { drawable = 0,  texture = 0, component_id = 1 },
--             { drawable = 19, texture = 0, component_id = 2 },
--             { drawable = 6,  texture = 0, component_id = 3 },
--             { drawable = 0,  texture = 0, component_id = 4 },
--             { drawable = 0,  texture = 0, component_id = 5 },
--             { drawable = 0,  texture = 0, component_id = 6 },
--             { drawable = 0,  texture = 0, component_id = 7 },
--             { drawable = 23, texture = 0, component_id = 8 },
--             { drawable = 0,  texture = 0, component_id = 9 },
--             { drawable = 0,  texture = 0, component_id = 10 },
--             { drawable = 4,  texture = 2, component_id = 11 }
--         },
--         props = {
--             { drawable = 27, prop_id = 0,  texture = 0 },
--             { drawable = 0,  prop_id = 1,  texture = 0 },
--             { drawable = 0,  prop_id = 2,  texture = 0 },
--             { drawable = 0,  prop_id = 3,  texture = 0 },
--             { drawable = 0,  prop_id = 4,  texture = 0 },
--             { drawable = 0,  prop_id = 5,  texture = 0 },
--             { drawable = 0,  prop_id = 6,  texture = 0 },
--             { drawable = 0,  prop_id = 7,  texture = 0 },
--             { drawable = 0,  prop_id = 8,  texture = 0 },
--             { drawable = 0,  prop_id = 9,  texture = 0 },
--             { drawable = 0,  prop_id = 10, texture = 0 },
--             { drawable = 0,  prop_id = 11, texture = 0 },
--             { drawable = 0,  prop_id = 12, texture = 0 },
--             { drawable = 0,  prop_id = 13, texture = 0 }

--         }
--     }, false, true)
-- end, false)
