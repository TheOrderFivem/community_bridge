---@diagnostic disable: duplicate-set-field
local id = Ids or Require("lib/utility/shared/ids.lua")
Marker = {}
local Created = {}

function Marker.New(data)
    if not data.position or not data.position.x or not data.position.y or not data.position.z then
        print("Invalid marker position. Must be a vector3 with x, y, and z coordinates.")
        return
    end

    local _id = data.id or id.CreateUniqueId(Created)
    local data = {
        id = _id,
        position = data.position,
        offset = data.offset or vector3(0.0, 0.0, 0.0),
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
    return _id
end
function Marker.Destroy(id)
    if not id or not Created[id] then return end
    Created[id] = nil
    return true
end

function Marker.Create(data)
    local _id = Marker.New(data)
    if not _id then return end
    TriggerClientEvent("community_bridge:Client:Marker", -1, Created[_id])
    return _id
end

function Marker.Remove(id)
    if not Marker.Destroy(id) then return end
    TriggerClientEvent("community_bridge:Client:MarkerRemove", -1, id)
end

function Marker.CreateBulk(datas)
    if not datas then return end
    local toClient = {}
    for k, v in pairs(datas) do
        table.insert(toClient, Marker.Create(v))
    end
    TriggerClientEvent("community_bridge:Client:MarkerBulk", -1, toClient)
    return toClient
end

function Marker.RemoveBulk(ids)
    if not ids then return end
    local toClient = {}
    for k, v in pairs(ids) do
        local id = v
        if type(v) == "table" then
            id = v.id
        end
        Marker.Destroy(id)
        table.insert(toClient, id)
    end
    TriggerClientEvent("community_bridge:Client:MarkerRemoveBulk", -1, toClient)
end

exports("Marker", Marker)
return Marker
