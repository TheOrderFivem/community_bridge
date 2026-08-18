Utility = Utility or {}
local blipIDs = {}

Point = Point or Require('lib/points/client/points.lua')


---Get street and crossing names at given coordinates
---@param coords vector3
---@return string, string
function Utility.GetStreetNameAtCoords(coords)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    return GetStreetNameFromHashKey(streetHash), GetStreetNameFromHashKey(crossingHash)
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
5
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
end)

exports('Utility', Utility)
return Utility
