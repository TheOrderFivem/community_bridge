Utility = Utility or {}
local blipIDs = {}
local spawnedPeds = {}
local spawnedProps = {}

Locales = Locales or Require('modules/locales/shared.lua')
Point = Point or Require('lib/points/client/points.lua')

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
    if HasModelLoaded(hash) then return true, hash end
    if not IsModelValid(hash) and not IsModelInCdimage(hash) then return false, hash end
    RequestModel(hash)
    local count = 0
    while not HasModelLoaded(hash) and count < 30000 do
        Wait(0)
        count = count + 1
    end
    return HasModelLoaded(hash), hash
end

---Create a prop with the given model and coordinates
---@param model string|number
---@param coords vector3
---@param heading number
---@param networked boolean
---@return number|nil
function Utility.CreateProp(model, coords, heading, networked)
    local loaded, hash = ensureModelLoaded(model)
    if not loaded then return nil, print("^6 community_bridge model was unable to load "..tostring(model).." ^0") end
    local propEntity = CreateObject(hash, coords.x, coords.y, coords.z, networked, false, false)
    SetEntityHeading(propEntity, heading)
    SetModelAsNoLongerNeeded(hash)
    spawnedProps[tostring(propEntity)] = true
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
    if not loaded then return nil, {}, print("^6 community_bridge model was unable to load "..tostring(model).." ^0") end
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, networked, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, "OFF")
    SetModelAsNoLongerNeeded(hash)
    return vehicle, {networkid = NetworkGetNetworkIdFromEntity(vehicle) or 0,coords = GetEntityCoords(vehicle),heading = GetEntityHeading(vehicle),}
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
    if not loaded then return nil, print("^6 community_bridge model was unable to load "..tostring(model).." ^0") end
    local spawnedEntity = CreatePed(0, hash, coords.x, coords.y, coords.z, heading, networked, false)
    SetModelAsNoLongerNeeded(hash)
    spawnedPeds[tostring(spawnedEntity)] = true
    return spawnedEntity
end

---Show a busy spinner with the given text
---@param text string
---@return boolean
function Utility.StartBusySpinner(text)
    AddTextEntry(text, text)
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
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite or 8)
    SetBlipColour(blip, color or 3)
    SetBlipScale(blip, scale or 0.8)
    SetBlipDisplay(blip, displayType or 2)
    SetBlipAsShortRange(blip, shortRange)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(blip)
    blipIDs[tostring(blip)] = blip
    return blip
end

function Utility.CreateRadiusBlip(coords, radius, color, alpha, label, shortRange, displayType)
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)
    SetBlipColour(blip, color or 3)
    SetBlipAlpha(blip, alpha or 255)
    SetBlipDisplay(blip, displayType or 2)
    SetBlipAsShortRange(blip, shortRange)
    AddTextEntry(label, label)
    BeginTextCommandSetBlipName(label)
    EndTextCommandSetBlipName(blip)
    blipIDs[tostring(blip)] = blip
    return blip
end

---Create a blip on the provided entity
---@param entity number
---@param sprite number
---@param color number
---@param scale number
---@param label string
---@param shortRange boolean
---@param displayType number
---@return number
function Utility.CreateEntityBlip(entity, sprite, color, scale, label, shortRange, displayType)
    local blip = AddBlipForEntity(entity)
    SetBlipSprite(blip, sprite or 8)
    SetBlipColour(blip, color or 3)
    SetBlipScale(blip, scale or 0.8)
    SetBlipDisplay(blip, displayType or 2)
    SetBlipAsShortRange(blip, shortRange)
    ShowHeadingIndicatorOnBlip(blip, true)
    AddTextEntry(label, label)
    BeginTextCommandSetBlipName(label)
    EndTextCommandSetBlipName(blip)
    blipIDs[tostring(blip)] = blip
    return blip
end

---Remove a blip if it exists
---@param blip number
---@return boolean
function Utility.RemoveBlip(blip)
    if not blipIDs[tostring(blip)] then return false end
    RemoveBlip(blipIDs[tostring(blip)])
    blipIDs[tostring(blip)] = nil
    return true
end

---Load a model into memory
---@param model string|number
---@return boolean, number
function Utility.LoadModel(model)
    return ensureModelLoaded(model)
end

---Request an animation dictionary
---@param dict string
---@return boolean
function Utility.RequestAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
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
    if not spawnedPeds[tostring(entity)] then return false end
    spawnedPeds[tostring(entity)] = nil
    if not DoesEntityExist(entity) then return false end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
    return true
end

---Remove a ped if it exists
---@param entity number
---@return boolean
function Utility.RemoveProp(entity)
    if not spawnedProps[tostring(entity)] then return false end
    spawnedProps[tostring(entity)] = nil
    if not DoesEntityExist(entity) then return false end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
    return true
end

---Show a native input menu and return the result
---@param text string
---@param length number
---@return string|boolean
function Utility.NativeInputMenu(text, length)
    local maxLength = Math and Math.Clamp and Math.Clamp(length, 1, 50) or math.min(math.max(length or 10, 1), 50)
    local menuText = text or 'enter text'
    AddTextEntry(menuText, menuText)
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
    local ped = PlayerPedId()
    local skinData = Utility.GetEntitySkinData(ped)
    Utility.SetEntitySkinData(ped, skinData)
    local poolObject = GetGamePool("CObject")
    for _, props in pairs(poolObject) do
        if IsEntityAttachedToEntity(ped, props) then
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
    AddTextEntry(text, text)
    BeginTextCommandDisplayHelp(text)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

---Show a floating help text in the world
---@param text string The text to show
---@param coords table The coords to show the message at
---@return nil
function Utility.FloatingHelpText(text, coords)
    AddTextEntry("community_bridge_"..text, text)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("community_bridge_"..text)
    EndTextCommandDisplayHelp(2, false, false, 100)
end

---Draw 3D help text in the world
---@param coords vector3
---@param text string
---@param scale number
function Utility.Draw3DHelpText(coords, text, scale)
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    if not onScreen then return end
    local lineCount = 0
    local maxLineLen = 0
    for line in string.gmatch(text, "[^\n]+") do
        lineCount = lineCount + 1
        maxLineLen = math.max(maxLineLen, string.len(line))
    end
    local widthFactor = maxLineLen * 0.012 * scale
    local height = 0.06 * scale * lineCount

    -- Set text properties
    SetTextScale(scale or 0.35, scale or 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(x, y)

    -- Draw background rectangle
    DrawRect(x, y + height / 2, widthFactor + 0.015 + 0.006, height + 0.015 + 0.006, 10, 25, 47, 200)
    DrawRect(x, y + height / 2, widthFactor + 0.015, height + 0.015, 17, 45, 78, 50)
end

function Utility.Draw3DHelpTextExt(coords, text, scale)

end

---Show a native notification
---@param text string
function Utility.NotifyText(text)
    AddTextEntry(text, text)
    SetNotificationTextEntry(text)
    DrawNotification(false, true)
end

---Teleport the player to given coordinates
---@param coords vector3
---@param conditionFunction function|nil
---@param afterTeleportFunction function|nil
function Utility.TeleportPlayer(coords, conditionFunction, afterTeleportFunction)
    local ped = PlayerPedId()
    if conditionFunction ~= nil then
        if not conditionFunction() then
            return
        end
    end
    DoScreenFadeOut(2500)
    Wait(2500)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then SetEntityHeading(ped, coords.w) end
    FreezeEntityPosition(ped, true)
    local count = 0
    while not HasCollisionLoadedAroundEntity(ped) and count <= 30000 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
        count = count + 1
    end
    FreezeEntityPosition(ped, false)
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
    local selfPed = PlayerPedId()
    local selfCoords = coords or GetEntityCoords(selfPed)
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

---Get the closest vehicle to given coordinates
---@param coords vector3|nil
---@param distanceScope number|nil
---@param includePlayerVeh boolean|nil
---@return number|nil, vector3|nil, number|nil
function Utility.GetClosestVehicle(coords, distanceScope, includePlayerVeh)
    local vehicleEntity = nil
    local vehicleNetID = nil
    local vehicleCoords = nil
    local ped = PlayerPedId()
    local selfCoords = coords or GetEntityCoords(ped)
    local closestDistance = distanceScope or 5
    local includeMyVeh = includePlayerVeh or false
    local gamePoolVehicles = GetGamePool("CVehicle")

    local playerVehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0

    for i = 1, #gamePoolVehicles do
        local thisVehicle = gamePoolVehicles[i]
        if DoesEntityExist(thisVehicle) and (includeMyVeh or thisVehicle ~= playerVehicle) then
            local thisVehicleCoords = GetEntityCoords(thisVehicle)
            local distance = #(selfCoords - thisVehicleCoords)
            if closestDistance == -1 or distance < closestDistance then
                vehicleEntity = thisVehicle
                vehicleNetID = NetworkGetNetworkIdFromEntity(thisVehicle) or nil
                vehicleCoords = thisVehicleCoords
                closestDistance = distance
            end
        end
    end

    return vehicleEntity, vehicleCoords, vehicleNetID
end

-- Deprecated point functions (no changes) 12/14/25
function Utility.RegisterPoint(pointID, pointCoords, pointDistance, _onEnter, _onExit)
    --print("^6 community_bridge ^: ^3Utility.RegisterPoint is deprecated. Please use Point.Register instead. ^0")
    return Point.Register(pointID, pointCoords, pointDistance, nil, _onEnter, _onExit)
end

function Utility.GetPointById(pointID)
    --print("^6 community_bridge ^: ^3Utility.GetPointById is deprecated. Please use Point.Get instead. ^0")
    return Point.Get(pointID)
end

function Utility.GetActivePoints()
    --print("^6 community_bridge ^: ^3Utility.GetActivePoints is deprecated. Please use Point.GetAll instead. ^0")
    return Point.GetAll()
end

function Utility.RemovePoint(pointID)
    --print("^6 community_bridge ^: ^3Utility.RemovePoint is deprecated. Please use Point.Remove instead. ^0")
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

function Utility.CopyToClipboard(text)
    if not text then return false end
    if type(text) ~= "string" then
        text = json.encode(text, { indent = true })
    end
    SendNUIMessage({
        type = "copytoclipboard",
        text = text
    })
    local message = Locales and Locales.Locale("clipboard.copy")
    --TriggerEvent('community_bridge:Client:Notify', message, 'success')
    return true
end

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

---Get zone name at coordinates
---@param coords vector3
---@return string
function Utility.GetZoneName(coords)
    local zoneHash = GetNameOfZone(coords.x, coords.y, coords.z)
    return GetLabelText(zoneHash)
end

local SpecialKeyCodes = {
    ['b_116'] = 'Scroll Up',
    ['b_115'] = 'Scroll Down',
    ['b_100'] = 'LMB',
    ['b_101'] = 'RMB',
    ['b_102'] = 'MMB',
    ['b_103'] = 'Extra 1',
    ['b_104'] = 'Extra 2',
    ['b_105'] = 'Extra 3',
    ['b_106'] = 'Extra 4',
    ['b_107'] = 'Extra 5',
    ['b_108'] = 'Extra 6',
    ['b_109'] = 'Extra 7',
    ['b_110'] = 'Extra 8',
    ['b_1015'] = 'AltLeft',
    ['b_1000'] = 'ShiftLeft',
    ['b_2000'] = 'Space',
    ['b_1013'] = 'ControlLeft',
    ['b_1002'] = 'Tab',
    ['b_1014'] = 'ControlRight',
    ['b_140'] = 'Numpad4',
    ['b_142'] = 'Numpad6',
    ['b_144'] = 'Numpad8',
    ['b_141'] = 'Numpad5',
    ['b_143'] = 'Numpad7',
    ['b_145'] = 'Numpad9',
    ['b_200'] = 'Insert',
    ['b_1012'] = 'CapsLock',
    ['b_170'] = 'F1',
    ['b_171'] = 'F2',
    ['b_172'] = 'F3',
    ['b_173'] = 'F4',
    ['b_174'] = 'F5',
    ['b_175'] = 'F6',
    ['b_176'] = 'F7',
    ['b_177'] = 'F8',
    ['b_178'] = 'F9',
    ['b_179'] = 'F10',
    ['b_180'] = 'F11',
    ['b_181'] = 'F12',
    ['b_194'] = 'ArrowUp',
    ['b_195'] = 'ArrowDown',
    ['b_196'] = 'ArrowLeft',
    ['b_197'] = 'ArrowRight',
    ['b_1003'] = 'Enter',
    ['b_1004'] = 'Backspace',
    ['b_198'] = 'Delete',
    ['b_199'] = 'Escape',
    ['b_1009'] = 'PageUp',
    ['b_1010'] = 'PageDown',
    ['b_1008'] = 'Home',
    ['b_131'] = 'NumpadAdd',
    ['b_130'] = 'NumpadSubstract',
    ['b_211'] = 'Insert',
    ['b_210'] = 'Delete',
    ['b_212'] = 'End',
    ['b_1055'] = 'Home',
    ['b_1056'] = 'PageUp',
}

local function translateKey(key)
    if string.find(key, "t_") then
        return string.gsub(key, "t_", "")
    elseif SpecialKeyCodes[key] then
        return SpecialKeyCodes[key]
    else
        return key
    end
end

function Utility.GetCommandKey(commandName)
    local hash = GetHashKey(commandName) | 0x80000000
    local button = GetControlInstructionalButton(2, hash, true)
    if not button or button == "" or button == "NULL" then
        hash = GetHashKey(commandName)
        button = GetControlInstructionalButton(2, hash, true)
    end

    return translateKey(button)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, blip in pairs(blipIDs) do
        if blip and DoesBlipExist(tonumber(blip)) then
            RemoveBlip(tonumber(blip))
        end
    end
    for _, ped in pairs(spawnedPeds) do
        if ped and DoesEntityExist(tonumber(ped)) then
            DeleteEntity(tonumber(ped))
        end
    end
    for _, prop in pairs(spawnedProps) do
        if prop and DoesEntityExist(tonumber(prop)) then
            DeleteEntity(tonumber(prop))
        end
    end
end)

exports('Utility', Utility)
return Utility
