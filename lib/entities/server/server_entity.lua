Ids = Ids or Require("lib/utility/shared/ids.lua")

local Entities = {}
ServerEntity = {} -- Renamed from EntityRelay

--- Creates a server-side representation of an entity and notifies clients.
-- @param entityType string 'object', 'ped', or 'vehicle'
-- @param model string|number
-- @param coords vector3
-- @param rotation vector3|number Heading for peds/vehicles, rotation for objects
-- @param meta table Optional additional data
-- @return table The created entity data
function ServerEntity.Create(id, entityType, model, coords, rotation, meta)
    local self = meta or {}
    self.id = id or Ids.CreateUniqueId(Entities)
    self.entityType = entityType
    self.model = model
    self.coords = coords
    self.rotation = rotation or (entityType == 'object' and vector3(0.0, 0.0, 0.0) or 0.0) -- Default rotation or heading
    self.resource = GetInvokingResource()

    assert(self.id, "ID Failed to generate")
    assert(self.entityType, "EntityType is required")
    assert(self.model, "Model is required for entity creation")
    assert(self.coords, "Coords are required for entity creation")

    ServerEntity.Add(self)
    TriggerClientEvent("community_bridge:client:CreateEntity", -1, self)
    Wait(1000)
    return self
end

--- Deletes a server-side entity representation and notifies clients.
-- @param id string|number The ID of the entity to delete.
function ServerEntity.Delete(id)
    if Entities[id] then
        ServerEntity.Remove(id)
        TriggerClientEvent("community_bridge:client:DeleteEntity", -1, id)
    end
end

--- Updates data for a server-side entity and notifies clients.
-- @param id string|number The ID of the entity to update.
-- @param data table The data fields to update.
function ServerEntity.Update(id, data)
    local entity = Entities[id]
    print("Updating entity: ", id, entity)
    if not entity then return false end

    for key, value in pairs(data) do
        entity[key] = value
    end
    TriggerClientEvent("community_bridge:client:UpdateEntity", -1, id, data)
    return true
end

--- Triggers a specific action on the client-side entity.
-- Clients will only execute the action if the entity is currently spawned for them.
-- @param entityId string|number The ID of the entity.
-- @param actionName string The name of the action to trigger (must match a function in ClientEntityActions).
-- @param ... any Additional arguments for the action function.
function ServerEntity.TriggerAction(entityId, actionName, endPosition, ...)
    print("Triggering action: ", entityId, actionName, ...)
    local entity = Entities[entityId]
    if not entity then
        print(string.format("[ServerEntity] Attempted to trigger action '%s' on non-existent entity %s", actionName, entityId))
        return
    end
    TriggerClientEvent("community_bridge:client:TriggerEntityAction", -1, entityId, actionName, endPosition, ...)
end

function ServerEntity.TriggerActions(entityId, actions, endPosition)
    local entity = Entities[entityId]
    if not entity then
        print(string.format("[ServerEntity] Attempted to trigger actions on non-existent entity %s", entityId))
        return
    end
    TriggerClientEvent("community_bridge:client:TriggerEntityActions", -1, entityId, actions, endPosition)
end

function ServerEntity.GetAll()
    return Entities
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

-- Clean up entities associated with a stopped resource
AddEventHandler('onResourceStop', function(resourceName)
    local toDelete = {}
    for id, entity in pairs(Entities) do
        if entity.resource == resourceName then
            table.insert(toDelete, id)
        end
    end
    for _, id in pairs(toDelete) do
        ServerEntity.Delete(id) 
    end
end)


return ServerEntity
