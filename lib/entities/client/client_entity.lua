Utility = Utility or Require("lib/utility/client/utility.lua")
Ids = Ids or Require("lib/utility/shared/ids.lua")
Point = Point or Require("lib/points/client/points.lua")
Behaviors = Behaviors or Require("lib/entities/shared/behaviors.lua")
local Entities = {} -- Stores entity data received from server
ClientEntity = {
    Invoked = {}
} -- Renamed from BaseEntity
ClientEntity.Behaviors = Behaviors

--------------------

local function SpawnEntity(entityData)
    if entityData.spawned and DoesEntityExist(entityData.spawned) then return end -- Already spawned
    if entityData.model then
        local loaded, model = Utility.LoadModel(entityData.model)
        if not loaded then
            print(string.format("[ClientEntity] Failed to load model %s for entity %s", entityData.model, entityData.id))
            return
        end

        local entity = nil
        local coords = entityData.coords
        local rotation = entityData.rotation or vector3(0.0, 0.0, entityData.heading or 0.0) -- Default rotation if not provided

        if entityData.entityType == 'object' then
            entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
            SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
        elseif entityData.entityType == 'ped' then
            entity = CreatePed(4, model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
        elseif entityData.entityType == 'vehicle' then
            entity = CreateVehicle(model, coords.x, coords.y, coords.z, type(rotation) == 'number' and rotation or rotation.z, false, false)
        else
            print(string.format("[ClientEntity] Unknown entity type '%s' for entity %s", entityData.entityType, entityData.id))
        end
        if entity and model then
            entityData.spawned = entity
            SetModelAsNoLongerNeeded(model)
            SetEntityAsMissionEntity(entity, true, true)
            FreezeEntityPosition(entity, entityData.freeze)
            SetEntityInvincible(entity, entityData.invincible)
            if entityData.ignoreGunshots then SetBlockingOfNonTemporaryEvents(entity, true) end
        else
            SetModelAsNoLongerNeeded(model)
        end
    end
    if entityData.OnSpawn then
        pcall(function (...)
            return entityData.OnSpawn(entityData)
        end)
    end
    Behaviors.Trigger("OnSpawn", entityData)
end

local function RemoveEntity(entityData)
    entityData = entityData and entityData.args or entityData
    if not entityData then return end
    Behaviors.Trigger("OnRemove", entityData)
    if entityData.OnRemove then
        pcall(function (...)
            return entityData.OnRemove(entityData)
        end)
    end
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        local entityHandle = entityData.spawned
        entityData.spawned = nil
        SetEntityAsMissionEntity(entityHandle, true, true)
        DeleteEntity(entityHandle)
    end
end

local function UpdateEntity(_entityData)
    local entityData = ClientEntity.Get(_entityData.id)
    if not entityData then return end
    if entityData.OnUpdate then
        pcall(function (...)
            return entityData.OnUpdate(entityData)
        end)
    end
    Behaviors.Trigger("OnUpdate", entityData)
    local coords = vector3(entityData.coords.x, entityData.coords.y, entityData.coords.z)
    entityData.oldCoords = entityData.oldCoords and vector3(entityData.oldCoords.x, entityData.oldCoords.y, entityData.oldCoords.z) or coords
    local dist = #(coords - entityData.oldCoords)
    if entityData.oldCoords and dist > 0.5 then
        if entityData.OnMove then
            pcall(function (...)
                return entityData.OnMove(entityData)
            end)
        end
        Behaviors.Trigger("OnMove", entityData, entityData.oldCoords, entityData.coords)
    end

    if not entityData.oldRotation or entityData.oldRotation ~= entityData.rotation then
        if entityData.spawned and DoesEntityExist(entityData.spawned) then
            if entityData.entityType == 'object' then
                SetEntityRotation(entityData.spawned, entityData.rotation.x, entityData.rotation.y, entityData.rotation.z, 2, true)
            else -- Ped/Vehicle heading
                SetEntityHeading(entityData.spawned, type(entityData.rotation) == 'number' and entityData.rotation or entityData.rotation.z)
            end
        end
        entityData.oldRotation = entityData.rotation
    end
end

--- Registers an entity received from the server and sets up proximity spawning.
-- @param entityData table Data received from the server via 'community_bridge:client:CreateEntity'
function ClientEntity.Create(entityData)
    entityData.id = entityData.id or Ids.CreateUniqueId(Entities)
    if Entities[entityData.id] then return Entities[entityData.id] end
    entityData.rotation = entityData.rotation or vector3(0.0, 0.0, entityData.heading or 0.0)
    entityData.oldCoords = entityData.oldCoords or vector3(0.0, 0.0, 0.0)
    entityData.oldRotation = entityData.rotation
    entityData.invoked =  entityData.invoked or GetInvokingResource() or "community_bridge"
    local entityPoint = Point.Register(entityData.id, entityData.coords, entityData.spawnDistance or 50.0, entityData, SpawnEntity, RemoveEntity, UpdateEntity)
    entityData.freeze = entityData.freeze == nil and true or entityData.freeze
    entityData.ignoreGunshots = entityData.ignoreGunshots or false
    entityData.invincible = entityData.invincible or false
    Entities[entityData.id] = entityPoint

    ClientEntity.Invoked[entityData.invoked] = ClientEntity.Invoked[entityData.invoked] or {}
    ClientEntity.Invoked[entityData.invoked][entityData.id] = entityData
    Behaviors.Trigger("OnCreate", entityPoint)
    return entityPoint
end

--Depricated use ClientEntity.Create instead
--- Registers an entity and spawns it in the world if not already spawned.
ClientEntity.Register = ClientEntity.Create


function ClientEntity.CreateBulk(entities)
    local registeredEntities = {}
    for _, entityData in pairs(entities) do
        local entity = ClientEntity.Create(entityData)
        registeredEntities[entity.id] = entity
    end
    return registeredEntities
end

-- Depricated use ClientEntity.CreateBulk instead
ClientEntity.RegisterBulk = ClientEntity.CreateBulk

--- Unregisters an entity and removes it from the world if spawned.
-- @param id string|number The ID of the entity to unregister.
function ClientEntity.Destroy(id)
    local entityData = Entities[id]
    if not entityData then return end
    Behaviors.Trigger("OnDestroy", entityData)
    Point.Remove(id)
    RemoveEntity(entityData)
    Entities[id] = nil
end
ClientEntity.Unregister = ClientEntity.Destroy

function ClientEntity.RegisterBehavior(id, behavior)
    Behaviors.Create(id, behavior)
end

--- Sets a key-value pair for a client entity.
---@param id any
---@param key any
---@param value any
---@return nil
function ClientEntity.Set(id, key, value)
    local entityData = ClientEntity.Get(id)
    if not entityData then return print(string.format("[ClientEntity] SetKey: Entity %s does not exist", id)) end
    local oldData = entityData[key]
    if oldData == value then return end
    if entityData.OnSet then
        pcall(function (...)
            return entityData.OnSet(entityData, key, value, oldData)
        end)
    end
    if value then
        entityData[key] = value
        Behaviors.Trigger("OnSet", entityData, key, value, oldData)
        return
    end
    Behaviors.Trigger("OnSet", entityData, key, value, oldData)
    entityData[key] = nil
end

function ClientEntity.Get(id)
    return Entities[id]
end

function ClientEntity.GetAll()
    return Entities
end

function ClientEntity.OnCreate(_type, func)
    ClientEntity.OnCreates = ClientEntity.OnCreates or {}
    if not ClientEntity.OnCreates[_type] then
        ClientEntity.OnCreates[_type] = {}
    end
    table.insert(ClientEntity.OnCreates[_type], func)
end

function ClientEntity.SetOnSpawn(id, func)
    local entityData = Entities[id]
    if not entityData then
        print(string.format("[ClientEntity] SetOnSpawn: Entity %s does not exist", id))
        return
    end
    entityData.OnSpawn = func
end

function ClientEntity.SetOnRemove(id, func)
    local entityData = Entities[id]
    if not entityData then
        print(string.format("[ClientEntity] SetOnRemove: Entity %s does not exist", id))
        return
    end
    entityData.OnRemove = func
end

function ClientEntity.UpdateCoords(id, coords)
    local entityData = Entities[id]
    if not entityData then
        print(string.format("[ClientEntity] UpdateCoords: Entity %s does not exist", id))
        return
    end
    entityData.coords = coords
    Point.UpdateCoords(id, coords)
end

function ClientEntity.ChangeModel(id, model)
    local entityData = Entities[id]
    if not entityData then return print(string.format("[ClientEntity] ChangeModel: Entity %s does not exist", id)) end

    if not entityData.spawned or not DoesEntityExist(entityData.spawned) then
        entityData.model = model
        return
    end

    if entityData.entityType == 'object' then
        local oldModel = entityData.model
        local loaded, newModelHandle = Utility.LoadModel(model)
        if not loaded then
            print(string.format("[ClientEntity] Failed to load model %s for entity %s", model, id))
            return
        end
        CreateModelSwap(entityData.coords.x, entityData.coords.y, entityData.coords.z, 10, oldModel, model, true)
        entityData.model = model
        SetModelAsNoLongerNeeded(newModelHandle)
    else
        RemoveEntity(entityData)
        entityData.model = model
        SpawnEntity(entityData)
    end
end


-- Network Event Handlers
RegisterNetEvent("community_bridge:client:CreateEntity", function(entityData)
    ClientEntity.Create(entityData)
end)

RegisterNetEvent("community_bridge:client:CreateEntities", function(entities)
    ClientEntity.CreateBulk(entities)
end)

RegisterNetEvent("community_bridge:client:DeleteEntity", function(id)
    ClientEntity.Unregister(id)
end)

RegisterNetEvent("community_bridge:client:UpdateEntity", function(id, data)
    for k, v in pairs(data) do
        ClientEntity.Set(id, k, v)
    end
end)

local Loaded = false
AddEventHandler('community_bridge:Client:OnPlayerLoaded', function(resourceName)
    if Loaded then return end
    Loaded = true
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if Loaded then return end
    Loaded = true
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id, entityData in pairs(Entities) do
            Point.Remove(id) -- Clean up point registration
            RemoveEntity(entityData) -- Clean up spawned game entity
        end
        Entities = {} -- Clear local cache
    else
        for id, entityData in pairs(ClientEntity.Invoked[resourceName] or {}) do
            Point.Remove(id) -- Clean up point registration
            RemoveEntity(entityData) -- Clean up spawned game entity
            Entities[id] = nil
        end
    end
end)

return ClientEntity