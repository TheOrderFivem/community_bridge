Placeable = Placeable or {}
Utility = Utility or Require("lib/utility/client/utility.lua")
if not lib then Require('init.lua', 'ox_lib') end

local activePlacementProp = nil


-- Object placer --
local placementText = {
    lib.locale('placeable_object.place_object_place'),
    lib.locale('placeable_object.place_object_cancel'),
    lib.locale('placeable_object.place_object_scroll_up'),
    lib.locale('placeable_object.place_object_scroll_down')
}

local function finishPlacing()
    Bridge.Notify.HideHelpText()
    if activePlacementProp == nil then return end
    DeleteObject(activePlacementProp)
    activePlacementProp = nil
end

--[[

RegisterCommand('testplacement', function()
    Placeable.PlaceObject("prop_cs_cardbox_01", 10, true, nil, 0.0)
end, false)

--]]

Placeable.PlaceObject = function(object, distance, snapToGround, allowedMats, offset)
    distance = tonumber(distance or 10.0 )
    if activePlacementProp then return end

    if not object then print('^6 placeable_object.no_prop_defined ^0') end

    local propObject = type(object) == 'string' and joaat(object) or object
    local heading = 0.0
    local checkDist = distance or 10.0
    local ped = PlayerPedId()

    Utility.LoadModel(propObject)

    activePlacementProp = CreateObject(propObject, 1.0, 1.0, 1.0, false, true, true)
    SetModelAsNoLongerNeeded(propObject)
    SetEntityAlpha(activePlacementProp, 150, false)
    SetEntityCollision(activePlacementProp, false, false)
    SetEntityInvincible(activePlacementProp, true)
    FreezeEntityPosition(activePlacementProp, true)

    Bridge.Notify.ShowHelpText(type(placementText) == 'table' and table.concat(placementText))

    local outLine = false

    while activePlacementProp do
        --local hit, _, coords, _, materialHash = lib.raycast.fromCamera(1, 4)
        --local hit, _, coords, _, materialHash = lib.raycast.fromCamera(1, 4, nil)
        local hit, _, coords, _, materialHash = lib.raycast.fromCamera(1, 4)
        if hit then
            if offset then
                coords += offset
            end

            SetEntityCoords(activePlacementProp, coords.x, coords.y, coords.z, false, false, false, false)
            local distCheck = #(GetEntityCoords(ped) - coords)
            SetEntityHeading(activePlacementProp, heading)

            if snapToGround then
                PlaceObjectOnGroundProperly(activePlacementProp)
            end

            if outLine then
                outLine = false
                SetEntityDrawOutline(activePlacementProp, false)
            end

            if (allowedMats and not allowedMats[materialHash]) or distCheck >= checkDist then
                if not outLine then
                outLine = true
                SetEntityDrawOutline(activePlacementProp, true)
                end
            end

            if IsControlJustReleased(0, 38) then
                if not outLine and (not allowedMats or allowedMats[materialHash]) and distCheck < checkDist then
                    finishPlacing()
                    return coords, heading
                end
            end

            if IsControlJustReleased(0, 73) then
                finishPlacing()

                return nil, nil
            end

            if IsControlJustReleased(0, 14) then
                heading = heading + 5
                if heading > 360 then heading = 0.0 end
            end

            if IsControlJustReleased(0, 15) then
                heading = heading - 5
                if heading < 0 then
                    heading = 360.0
                end
            end
        end
    end
end

Placeable.StopPlacing = function()
    if not activePlacementProp then return end
    finishPlacing()
end

return Placeable
-- This is derrived and slightly altered from its creator and licensed under GPL-3.0 license Author:Zoo, the original is located here https://github.com/Renewed-Scripts/Renewed-Lib/tree/main