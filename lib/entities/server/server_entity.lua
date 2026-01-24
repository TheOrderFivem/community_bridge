Ids = Ids or Require("lib/utility/shared/ids.lua")

local Entities = {}
ServerEntity = {} -- Renamed from EntityRelay
local Invoked = {}

--- Creates a server-side representation of an entity and notifies clients.
-- @param entityType string 'object', 'ped', or 'vehicle'
-- @param model string|number
-- @param coords vector3
-- @param rotation vector3|number Heading for peds/vehicles, rotation for objects
-- @param meta table Optional additional data
-- @return table The created entity data
function ServerEntity.New(id, entityType, model, coords, rotation, args)
    assert(coords, "Coords are required for entity creation")
    local self = args or {}
    self.id = id or Ids.CreateUniqueId(Entities)
    self.entityType = entityType
    self.model = model
    self.coords = coords
    self.rotation = rotation or vector3(0.0, 0.0, 0.0)
    local invoking = GetInvokingResource() or "community_bridge"
    self.invoked = invoking
    Invoked[invoking] = Invoked[invoking] or {}
    table.insert(Invoked[invoking], self)

    ServerEntity.Add(self)
    return self
end
function ServerEntity.Create(data)
    local self = ServerEntity.New(data.id, data.entityType, data.model, data.coords, data.rotation or vector3(0.0, 0.0, data.heading or 0.0), data)
    if not self then return nil end
    TriggerClientEvent("community_bridge:client:CreateEntity", -1, self)
    return self
end

function ServerEntity.CreateBulk(entities)
    local createdEntities = {}
    for _, entityData in pairs(entities) do
        local id = entityData.id or Ids.CreateUniqueId(Entities)
        local entity =  ServerEntity.New(id, entityData.entityType, entityData.model, entityData.coords, entityData.rotation, entityData)
        createdEntities[id] = entity
    end
    TriggerClientEvent("community_bridge:client:CreateEntities", -1, createdEntities)
    return createdEntities
end

--- Deletes a server-side entity representation and notifies clients.
-- @param id string|number The ID of the entity to delete.
function ServerEntity.Destroy(id)
    if not Entities[id] then return end
    ServerEntity.Remove(id)
    TriggerClientEvent("community_bridge:client:DeleteEntity", -1, id)
end
ServerEntity.Delete = ServerEntity.Destroy

function ServerEntity.DestroyBulk(entityDatas)
    for _, entityData in pairs(entityDatas) do
        ServerEntity.Remove(entityData.id)
    end
    print("[ServerEntity] DestroyBulk: Removed", #entityDatas, "entities")
    TriggerClientEvent("community_bridge:client:DeleteBulk", -1, entityDatas)
end

function ServerEntity.Get(id)
    return Entities[id]
end

function ServerEntity.Add(self)
    Entities[self.id] = self
end

function ServerEntity.Remove(id)
    Entities[id] = nil
end

--- Updates data for a server-side entity and notifies clients.
-- @param id string|number The ID of the entity to update.
-- @param data table The data fields to update.
function ServerEntity.Set(id, data)
    local entity = Entities[id]
    if not entity then return false end
    for key, value in pairs(data) do
        entity[key] = value
    end
    TriggerClientEvent("community_bridge:client:UpdateEntity", -1, id, data)
    return true
end


-- Clean up entities associated with a stopped resource
AddEventHandler('onResourceStop', function(resourceName)
    if Invoked[resourceName] then
        ServerEntity.DestroyBulk(Invoked[resourceName])
        Invoked[resourceName] = nil
    end
end)

AddEventHandler('community_bridge:Server:OnPlayerLoaded', function(source)
    -- print("Player loaded:", source)
    TriggerClientEvent("community_bridge:client:CreateEntities", source, Entities)
end)


return ServerEntity