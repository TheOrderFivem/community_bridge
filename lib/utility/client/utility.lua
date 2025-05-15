---@class Utility
Utility = Utility or {}
local blipIDs = {}
local spawnedPeds = {}

-- === Local Helpers ===

---Get the hash of a model (string or number)
---@param model string|number
---@return number
local function getModelHash(model)
    if type(model) ~= 'number' then
        return joaat(model)
    end
    return model
end

---Ensure a model is loaded into memory
---@param model string|number
---@return boolean, number
local function ensureModelLoaded(model)
    local hash = getModelHash(model)
    if not IsModelValid(hash) and not IsModelInCdimage(hash) then return false, hash end
    RequestModel(hash)
    local count = 0
    while not HasModelLoaded(hash) and count < 30000 do
        Wait(0)
        count = count + 1
    end
    return HasModelLoaded(hash), hash
end

---Add a text entry if possible
---@param key string
---@param text string
local function addTextEntryOnce(key, text)
    if not AddTextEntry then return end
    AddTextEntry(key, text)
end

---Create a blip safely and store its reference
---@param coords vector3
---@param sprite number
---@param color number
---@param scale number
---@param label string
---@param shortRange boolean
---@param displayType number
---@return number
local function safeAddBlip(coords, sprite, color, scale, label, shortRange, displayType)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite or 8)
    SetBlipColour(blip, color or 3)
    SetBlipScale(blip, scale or 0.8)
    SetBlipDisplay(blip, displayType or 2)
    SetBlipAsShortRange(blip, shortRange)
    addTextEntryOnce(label, label)
    BeginTextCommandSetBlipName(label)
    EndTextCommandSetBlipName(blip)
    table.insert(blipIDs, blip)
    return blip
end

---Remove a blip safely from the stored list
---@param blip number
---@return boolean
local function safeRemoveBlip(blip)
    for i, storedBlip in ipairs(blipIDs) do
        if storedBlip == blip then
            RemoveBlip(storedBlip)
            table.remove(blipIDs, i)
            return true
        end
    end
    return false
end

---Add a text entry if possible (shortcut)
---@param text string
local function safeAddTextEntry(text)
    if not AddTextEntry then return end
    AddTextEntry(text, text)
end

-- === Public Utility Functions ===

---Create a prop with the given model and coordinates
---@param model string|number
---@param coords vector3
---@param heading number
---@param networked boolean
---@return number|nil
function Utility.CreateProp(model, coords, heading, networked)
    local loaded, hash = ensureModelLoaded(model)
    if not loaded then return nil, Prints and Prints.Error and Prints.Error("Model Has Not Loaded") end
    local propEntity = CreateObject(hash, coords.x, coords.y, coords.z, networked, false, false)
    SetEntityHeading(propEntity, heading)
    SetModelAsNoLongerNeeded(hash)
    return propEntity
end

---Get street and crossing names at given coordinates
---@param coords vector3
---@return string, string
function Utility.GetStreetNameAtCoords(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash), GetStreetNameFromHashKey(crossingHash)
end

---Create a vehicle with the given model and coordinates
---@param model string|number
---@param coords vector3
---@param heading number
---@param networked boolean
---@return number|nil, table
function Utility.CreateVehicle(model, coords, heading, networked)
    local loaded, hash = ensureModelLoaded(model)
    if not loaded then return nil, {}, Prints and Prints.Error and Prints.Error("Model Has Not Loaded") end
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, networked, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    SetModelAsNoLongerNeeded(hash)
    return vehicle, {
        networkid = NetworkGetNetworkIdFromEntity(vehicle) or 0,
        coords = GetEntityCoords(vehicle),
        heading = GetEntityHeading(vehicle),
    }
end

---Create a ped with the given model and coordinates
---@param model string|number
---@param coords vector3
---@param heading number
---@param networked boolean
---@param settings table|nil
---@return number|nil
function Utility.CreatePed(model, coords, heading, networked, settings)
    local loaded, hash = ensureModelLoaded(model)
    if not loaded then return nil, Prints and Prints.Error and Prints.Error("Model Has Not Loaded") end
    local spawnedEntity = CreatePed(0, hash, coords.x, coords.y, coords.z, heading, networked, false)
    SetModelAsNoLongerNeeded(hash)
    table.insert(spawnedPeds, spawnedEntity)
    return spawnedEntity
end

---Show a busy spinner with the given text
---@param text string
---@return boolean
function Utility.StartBusySpinner(text)
    safeAddTextEntry(text)
    BeginTextCommandBusyString(text)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandBusyString(0)
    return true
end

---Stop the busy spinner if active
---@return boolean
function Utility.StopBusySpinner()
    if BusyspinnerIsOn() then
        BusyspinnerOff()
        return true
    end
    return false
end

---Create a blip at the given coordinates
---@param coords vector3
---@param sprite number
---@param color number
---@param scale number
---@param label string
---@param shortRange boolean
---@param displayType number
---@return number
function Utility.CreateBlip(coords, sprite, color, scale, label, shortRange, displayType)
    return safeAddBlip(coords, sprite, color, scale, label, shortRange, displayType)
end

---Remove a blip if it exists
---@param blip number
---@return boolean
function Utility.RemoveBlip(blip)
    return safeRemoveBlip(blip)
end

---Load a model into memory
---@param model string|number
---@return boolean
function Utility.LoadModel(model)
    local loaded = ensureModelLoaded(model)
    return loaded
end

---Request an animation dictionary
---@param dict string
---@return boolean
function Utility.RequestAnimDict(dict)
    RequestAnimDict(dict)
    local count = 0
    while not HasAnimDictLoaded(dict) and count < 30000 do
        Wait(0)
        count = count + 1
    end
    return HasAnimDictLoaded(dict)
end

---Remove a ped if it exists
---@param entity number
---@return boolean
function Utility.RemovePed(entity)
    local success = false
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
    for i, storedEntity in ipairs(spawnedPeds) do
        if storedEntity == entity then
            table.remove(spawnedPeds, i)
            success = true
            break
        end
    end
    return success
end

---Show a native input menu and return the result
---@param text string
---@param length number
---@return string|boolean
function Utility.NativeInputMenu(text, length)
    local maxLength = Math and Math.Clamp and Math.Clamp(length, 1, 50) or math.min(math.max(length or 10, 1), 50)
    local menuText = text or 'enter text'
    safeAddTextEntry(menuText)
    DisplayOnscreenKeyboard(1, menuText, "", "", "", "", "", maxLength)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        return GetOnscreenKeyboardResult()
    end
    return false
end

---Get the skin data of a ped
---@param entity number
---@return table
function Utility.GetEntitySkinData(entity)
    local skinData = { clothing = {}, props = {} }
    for i = 0, 11 do
        skinData.clothing[i] = { GetPedDrawableVariation(entity, i), GetPedTextureVariation(entity, i) }
    end
    for i = 0, 13 do
        skinData.props[i] = { GetPedPropIndex(entity, i), GetPedPropTextureIndex(entity, i) }
    end
    return skinData
end

---Apply skin data to a ped
---@param entity number
---@param skinData table
---@return boolean
function Utility.SetEntitySkinData(entity, skinData)
    for i = 0, 11 do
        SetPedComponentVariation(entity, i, skinData.clothing[i][1], skinData.clothing[i][2], 0)
    end
    for i = 0, 13 do
        SetPedPropIndex(entity, i, skinData.props[i][1], skinData.props[i][2], 0)
    end
    return true
end

---Reload the player's skin and remove attached objects
---@return boolean
function Utility.ReloadSkin()
    local skinData = Utility.GetEntitySkinData(cache.ped)
    Utility.SetEntitySkinData(cache.ped, skinData)
    for _, props in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cache.ped, props) then
            SetEntityAsMissionEntity(props, true, true)
            DeleteObject(props)
            DeleteEntity(props)
        end
    end
    return true
end

---Show a native help text
---@param text string
---@param duration number
function Utility.HelpText(text, duration)
    safeAddTextEntry(text)
    BeginTextCommandDisplayHelp(text)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

---Draw 3D help text in the world
---@param coords vector3
---@param text string
---@param scale number
function Utility.Draw3DHelpText(coords, text, scale)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if onScreen then
        SetTextScale(scale or 0.35, scale or 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
        local factor = (string.len(text)) / 370
        DrawRect(x, y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 100)
    end
end

---Show a native notification
---@param text string
function Utility.NotifyText(text)
    safeAddTextEntry(text)
    SetNotificationTextEntry(text)
    DrawNotification(false, true)
end

---Teleport the player to given coordinates
---@param coords vector3
---@param conditionFunction function|nil
---@param afterTeleportFunction function|nil
function Utility.TeleportPlayer(coords, conditionFunction, afterTeleportFunction)
    if conditionFunction ~= nil then
        if not conditionFunction() then
            return
        end
    end
    DoScreenFadeOut(2500)
    Wait(2500)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then
        SetEntityHeading(cache.ped, coords.w)
    end
    FreezeEntityPosition(cache.ped, true)
    local count = 0
    while not HasCollisionLoadedAroundEntity(cache.ped) and count <= 30000 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
        count = count + 1
    end
    FreezeEntityPosition(cache.ped, false)
    DoScreenFadeIn(1000)
    if afterTeleportFunction ~= nil then
        afterTeleportFunction()
    end
end

---Get the hash from a model
---@param model string|number
---@return number
function Utility.GetEntityHashFromModel(model)
    return getModelHash(model)
end

---Get the closest player to given coordinates
---@param coords vector3|nil
---@param distanceScope number|nil
---@param includeMe boolean|nil
---@return number, number, number
function Utility.GetClosestPlayer(coords, distanceScope, includeMe)
    local players = GetActivePlayers()
    local closestPlayer = 0
    local selfPed = cache.ped
    local selfCoords = coords or GetEntityCoords(cache.ped)
    local closestDistance = distanceScope or 5

    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        if includeMe or playerPed ~= selfPed then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(selfCoords - playerCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance, GetPlayerServerId(closestPlayer)
end

-- Deprecated point functions (no changes)
function Utility.RegisterPoint(pointID, pointCoords, pointDistance, _onEnter, _onExit, _nearby)
    return Point.Register(pointID, pointCoords, pointDistance, nil, _onEnter, _onExit, _nearby)
end

function Utility.GetPointById(pointID)
    return Point.Get(pointID)
end

function Utility.GetActivePoints()
    return Point.GetAll()
end

function Utility.RemovePoint(pointID)
    return Point.Remove(pointID)
end

---Simple switch-case function
---@generic T
---@param value T The value to match against the cases
---@param cases table<T|false, fun(): any> Table with case functions and an optional default (false key)
---@return any|false result The return value of the matched case function, or false if none matched
function Utility.Switch(value, cases)
    local caseFunc = cases[value] or cases[false]

    if caseFunc and type(caseFunc) == "function" then
        local ok, result = pcall(caseFunc)
        return ok and result or false
    end

    return false
end

--[[
local vehicleType = "boat"

local result = Utility.Switch(vehicleType, {
    car = function()
        print("This is a Car")
        -- Car-related logic here
        return "Car logic executed"
    end,
    bike = function()
        print("This is a Bike")
        -- Bike-related logic here
        return "Bike logic executed"
    end,
    [false] = function()
        print("Unknown vehicle type. Running default logic.")
        -- Default logic here
        return "Default logic executed"
    end,
})

print("Result:", result)

]]


--- Pattern match-like function
---@generic T
---@param value T The value to match
---@param patterns table<T|fun(T):boolean|false, fun(): any> A list of matchers and their handlers
---@return any|false result The result of the first matched case, or false if none
function Utility.Match(value, patterns)
    for pattern, handler in pairs(patterns) do
        if type(pattern) == "function" then
            local ok, matched = pcall(pattern, value)
            if ok and matched then
                local success, result = pcall(handler)
                return success and result or false
            end
        elseif pattern == value then
            local success, result = pcall(handler)
            return success and result or false
        end
    end

    if patterns[false] then
        local ok, result = pcall(patterns[false])
        return ok and result or false
    end

    return false
end

--[[
local input = 42

local result = Utility.Match(input, {
    [function(v) return v < 0 end] = function()
        print("Negative number")
        return "Negative"
    end,
    [function(v) return v % 2 == 0 end] = function()
        print("Even number")
        return "Even"
    end,
    [false] = function()
        print("No match")
        return "Default"
    end,
})

print("Result:", result)

]]


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in pairs(blipIDs) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    for _, ped in pairs(spawnedPeds) do
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

exports('Utility', Utility)
return Utility
