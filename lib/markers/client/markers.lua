---@diagnostic disable: duplicate-set-field
Marker = {}
local Created = setmetatable({}, { __mode = "k" }) --what is mode?
local Ids = Ids or Require("lib/utility/shared/ids.lua")
local point =  Point or Require("lib/points/client/points.lua")
local loopRunning = false
local Drawing = {}

--- This will validate the marker data.
--- @param data table{position: vector3, offset: vector3, rotation: vector3, size: vector3, color: vector3, alpha: number, bobUpAndDown: boolean, marker: number, interaction: function}
--- @return boolean
local function validateMarkerData(data)
    if not data.position or not data.position.x or not data.position.y or not data.position.z then
        print("Invalid marker position. Must be a vector3 with x, y, and z coordinates.")
        return false
    end
    if data.offset and (not data.offset.x or not data.offset.y or not data.offset.z) then
        print("Invalid marker offset. Must be a vector3 with x, y, and z coordinates.")
        return false
    end
    if data.rotation and (not data.rotation.x or not data.rotation.y or not data.rotation.z) then
        print("Invalid marker rotation. Must be a vector3 with x, y, and z coordinates.")
        return false
    end
    return true
end

--- This will create a marker.
--- @param data table{position: vector3, offset: vector3, rotation: vector3, size: vector3, color: vector3, alpha: number, bobUpAndDown: boolean, marker: number, interaction: function}
--- @return string|nil
function Marker.Create(data)
    local _id = data.id or Ids.CreateUniqueId(Created)
    if not validateMarkerData(data) then return end
    local basePosition = data.position or vector3(0.0, 0.0, 0.0)
    local baseOffset = data.offset or vector3(0.0, 0.0, 0.0)

    local data = {
        id = _id,
        position = vector3(basePosition.x + baseOffset.x, basePosition.y + baseOffset.y, basePosition.z + baseOffset.z), 
        marker = data.marker or 1,
        rotation = data.rotation or vector3(0, 0, 0),
        size = data.size or vector3(1.0, 1.0, 1.0),
        color = data.color or vector3(0, 255, 0),
        alpha = data.alpha or 255,
        bobUpAndDown = data.bobUpAndDown,
        -- interaction = data.interaction or false, -- Uncomment if you re-implement interaction logic
        rotate = data.rotate,
        textureDict = data.textureDict,
        textureName = data.textureName,
        drawOnEnts = data.drawOnEnts,
    }
    Created[_id] = data

    point.Register(
        _id, data.position, data.drawDistance or 50.0, data,
        function(_)     
            if not Created[_id] then return point.Remove(_id) end     
            Drawing[_id] = Created[_id]   
            Marker.Run()            
        end,
        function(markerData)                
            Drawing[_id] = nil               
        end, nil
    )
    return _id
end

--- This will remove a marker.
--- @param id string
--- @return boolean
function Marker.Remove(id)
    if not Created[id] then return false end
    point.Remove(id)
    Drawing[id] = nil
    Created[id] = nil
    return true
end

--- This will remove all markers.
--- @param id string
function Marker.RemoveAll()
    for id, _ in pairs(Created) do
        point.Remove(id)
        Created[id] = nil
    end    
end

-- This will loop through all marker(points) in range and draw them.
-- @param data table{marker: number, position: vector3, rotation: vector3, size: vector3, color: vector3, alpha: number, bobUpAndDown: boolean, faceCamera: boolean, rotate: boolean, textureDict: string, textureName: string, drawOnEnts: boolean}
-- @return nil
function Marker.Run()
    if loopRunning then return end
    loopRunning = true
    CreateThread(function()
        while loopRunning do
            if not next(Created) then
                loopRunning = false
                return
            end
            for drawingId, drawingData in pairs(Drawing) do
                if not Created[drawingId] then
                    Drawing[drawingId] = nil
                    goto continue
                end
                DrawMarker(
                    drawingData.marker,
                    drawingData.position.x, drawingData.position.y, drawingData.position.z,
                    0.0, 0.0, 0.0,
                    drawingData.rotation.x, drawingData.rotation.y, drawingData.rotation.z,
                    drawingData.size.x, drawingData.size.y, drawingData.size.z,
                    drawingData.color.x, drawingData.color.y, drawingData.color.z, drawingData.alpha,
                    drawingData.bobUpAndDown, drawingData.faceCamera, false,
                    drawingData.rotate, drawingData.textureDict, drawingData.textureName, drawingData.drawOnEnts
                )
                ::continue::
            end
            Wait(3)
        end
    end)
end

RegisterNetEvent("community_bridge:Client:Marker", function(data)
    Marker.Create(data)
end)

RegisterNetEvent("community_bridge:Client:MarkerBulk", function(datas)
    if not datas then return end
    for _, data in pairs(datas) do
        Marker.Create(data)
    end
end)

RegisterNetEvent("community_bridge:Client:MarkerRemove", function(id)
    Marker.Remove(id)
end)

RegisterNetEvent("community_bridge:Client:MarkerRemoveBulk", function(ids)
    if not ids then return end
    for _, id in pairs(ids) do
        Marker.Remove(id)
    end
end)

exports("Marker", Marker)


return Marker
