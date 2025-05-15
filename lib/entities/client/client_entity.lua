Utility = Utility or Require("lib/utility/client/utility.lua")
Ids = Ids or Require("lib/utility/shared/ids.lua")
Point = Point or Require("lib/points/client/points.lua")
ClientEntityActions = ClientEntityActions or Require("lib/entities/client/client_entity_actions_ext.lua")

---@class ClientEntity
local ClientEntity = {}
local Entities = {} -- Local storage for entity data

-- Constants
local DEFAULT_SPAWN_DISTANCE = 50.0

-- Local helper functions
local function applyEntityRotation(entity, rotation, entityType)
    if entityType == 'object' then
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    else
        SetEntityHeading(entity, type(rotation) == 'number' and rotation or rotation.z)
    end
end

local function createEntityByType(entityType, model, coords, rotation)
    local entity = nil

    if entityType == 'object' then
        entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        applyEntityRotation(entity, rotation, entityType)
    elseif entityType == 'ped' then
        entity = CreatePed(4, model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z,
            false, false)
    elseif entityType == 'vehicle' then
        entity = CreateVehicle(model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation
        .z, false, false)
    end

    return entity
end

local function setupEntity(entity, entityData)
    if not entity then return end

    entityData.spawned = entity
    SetModelAsNoLongerNeeded(entityData.model)
    SetEntityAsMissionEntity(entity, true, true)
    FreezeEntityPosition(entity, entityData.freeze or false)

    if entityData.OnSpawn and type(entityData.OnSpawn) == 'function' then
        entityData.OnSpawn(entityData)
    end
end

local function SpawnEntity(entityData)
    entityData = entityData and entityData.args
    if entityData.spawned and DoesEntityExist(entityData.spawned) then return end

    local model = entityData.model and type(entityData.model) == 'string' and GetHashKey(entityData.model) or
    entityData.model
    if not Utility.LoadModel(model) then
        print(string.format("[ClientEntity] Failed to load model %s for entity %s", entityData.model, entityData.id))
        return
    end

    local entity = nil
    local coords = entityData.coords
    local rotation = entityData.rotation

    if entityData.entityType == 'object' then
        entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    elseif entityData.entityType == 'ped' then
        entity = CreatePed(4, model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
        -- Apply ped specific settings from entityData.meta if needed
    elseif entityData.entityType == 'vehicle' then
        entity = CreateVehicle(model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
        -- Apply vehicle specific settings from entityData.meta if needed
    else
        print(string.format("[ClientEntity] Unknown entity type '%s' for entity %s", entityData.entityType, entityData.id))
    end
    if entity then
        -- print(string.format("[ClientEntity] Spawned %s entity %s (GameID: %s)", entityData.entityType, entityData.id, entity))
        entityData.spawned = entity
        SetModelAsNoLongerNeeded(model)
        SetEntityAsMissionEntity(entity, true, true) -- Keep entity from being deleted by game engine
        FreezeEntityPosition(entity, true) -- Optional freeze based on meta
        if entityData.OnSpawn and type(entityData.OnSpawn) == 'function' then
            entityData.OnSpawn(entityData)
        end
        -- print(string.format("[ClientEntity] Spawned %s entity %s (GameID: %s)", entityData.entityType, entityData.id, entity))
    else
        SetModelAsNoLongerNeeded(model)
    end
end

local function RemoveEntity(entityData)
    entityData = entityData and entityData.args or entityData
    if not entityData then return end
    ClientEntityActions.StopAction(entityData.id)
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        local entityHandle = entityData.spawned
        entityData.spawned = nil
        SetEntityAsMissionEntity(entityHandle, false, false)
        DeleteEntity(entityHandle)
    end

    if entityData.OnRemove and type(entityData.OnRemove) == 'function' then
        entityData.OnRemove(entityData)
    end
end

--- Registers an entity received from the server and sets up proximity spawning.
-- @param entityData table Data received from the server via 'community_bridge:client:CreateEntity'
function ClientEntity.Register(entityData)
    if Entities[entityData.id] then return end -- Already registered

    Entities[entityData.id] = entityData
    -- print(string.format("[ClientEntity] Registering %s entity %s", entityData.entityType, entityData.id))

    -- Use Point system for proximity checks
    -- print(string.format("[ClientEntity] Registering entity %s at %s", entityData.id, json.encode(entityData)))
    Point.Register(entityData.id, entityData.coords, entityData.spawnDistance or 50.0, entityData, SpawnEntity, RemoveEntity, function() end)
end

function ClientEntity.Unregister(id)
    local entityData = Entities[id]
    if not entityData then return end

    Point.Remove(id) 
    RemoveEntity(entityData) 
    Entities[id] = nil
end

function ClientEntity.Update(id, data)
    local entityData = Entities[id]
    -- print(string.format("[ClientEntity] Updating entity %s", id))
    if not entityData then return end

    local needsPointUpdate = false
    for key, value in pairs(data) do
        if key == 'coords' and #(entityData.coords - value) > 0.1 then
            -- print(string.format("[ClientEntity] Updating coords for entity %s", id))
             needsPointUpdate = true
        end
        if key == 'spawnDistance' and entityData.spawnDistance ~= value then
             needsPointUpdate = true
        end
        entityData[key] = value
    end

    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        if data.coords or data.rotation then
            updateEntityPosition(entityData.spawned, entityData.coords, data.rotation, entityData.entityType)
        end
        if data.freeze ~= nil then
            FreezeEntityPosition(entityData.spawned, data.freeze)
        end
    end

    if needsPointUpdate then
        Point.Remove(id)
        Point.Register(entityData.id, entityData.coords, entityData.spawnDistance or DEFAULT_SPAWN_DISTANCE,
            SpawnEntity, RemoveEntity, nil, entityData)
    end

    if entityData.OnUpdate and type(entityData.OnUpdate) == 'function' then
        entityData.OnUpdate(entityData, data)
    end
end

function ClientEntity.Get(id) return Entities[id] end

function ClientEntity.GetAll() return Entities end

function ClientEntity.RegisterAction(name, func)
    ClientEntityActions.RegisterAction(name, func)
end

-- Network Event Handlers
RegisterNetEvent("community_bridge:client:CreateEntity", ClientEntity.Register)
RegisterNetEvent("community_bridge:client:DeleteEntity", ClientEntity.Unregister)
RegisterNetEvent("community_bridge:client:UpdateEntity", ClientEntity.Update)

RegisterNetEvent("community_bridge:client:TriggerEntityAction", function(entityId, actionName, ...)
    local entityData = Entities[entityId]
    -- Check if entity exists locally (it doesn't need to be spawned to queue actions)
    if entityData then
        if actionName == "Stop" then
            ClientEntityActions.StopAction(entityId)
        elseif actionName == "Skip" then
            ClientEntityActions.SkipAction(entityId)
        else
            print(string.format("[ClientEntity] Triggering action '%s' for entity %s", actionName, entityId))
            local currentAction = ClientEntityActions.ActionQueue[entityId] and ClientEntityActions.ActionQueue[entityId][1]
            ClientEntityActions.QueueAction(entityData, actionName, ...)
        end
    -- else
        -- Optional: Log if action received but entity doesn't exist locally at all
        -- print(string.format("[ClientEntity] Received action '%s' for non-existent entity %s.", actionName, entityId))
    end
end)


RegisterNetEvent("community_bridge:client:TriggerEntityActions", function(entityId, actions, endPosition)
    local entityData = Entities[entityId]
    if entityData then
        for _, actionData in pairs(actions) do 
            local actionName = actionData.name
            local actionParams = actionData.params
            if actionName == "Stop" then
                ClientEntityActions.StopAction(entityId)
            elseif actionName == "Skip" then
                ClientEntityActions.SkipAction(entityId)
            else
                local currentAction = ClientEntityActions.ActionQueue[entityId] and ClientEntityActions.ActionQueue[entityId][1]
                ClientEntityActions.QueueAction(entityData, actionName, table.unpack(actionParams))
            end
        end
    else
        print(string.format("[ClientEntity] Received actions for non-existent entity %s.", entityId))
    end
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id, entityData in pairs(Entities) do
            Point.Remove(id)
            RemoveEntity(entityData)
        end
        Entities = {}
    end
end)

return ClientEntity
