Utility = Utility or Require("lib/utility/client/utility.lua")
Ids = Ids or Require("lib/utility/shared/ids.lua")
Point = Point or Require("lib/points/client/points.lua")
ClientEntity = {
    All = {},
    Invoked = {},
    OnCreates = {}
} -- Renamed from BaseEntity
----------------------------------------

---@alias ClientEntityId string|number
---@alias EntityHandle number

---@class ClientEntityAnim
---@field dict string
---@field name string
---@field blendIn number|nil
---@field blendOut number|nil
---@field duration number|nil
---@field flags number|nil
---@field playbackRate number|nil
---@field onComplete function|nil

---@class ClientEntityAttach
---@field target string|number Target reference. String may be a Bridge.Entity id; number may be a player server id; either may also be a FiveM entity handle.
---@field bone number|nil
---@field offset vector3|nil
---@field rotation vector3|nil

---@class EntityData
---@field id ClientEntityId|nil If omitted, one is generated.
---@field coords vector3
---@field entityType 'object'|'ped'|'vehicle'
---@field model string|number
---@field heading number|nil
---@field rotation vector3|nil
---@field spawnDistance number|nil
---@field freeze boolean|nil
---@field invincible boolean|nil
---@field targets table|nil Target options passed to Bridge.Target.AddLocalEntity.
---@field anim ClientEntityAnim|nil
---@field attach ClientEntityAttach|nil
---@field OnSpawn fun(entityData: EntityData)|nil
---@field OnRemove fun(entityData: EntityData)|nil
---@field spawned EntityHandle|nil FiveM entity handle created when the entry is in-range.

-- Set the entity and apply any relevant properties such as freezing and targets.
local function SetEntityProperties(id)
    local entityData = ClientEntity.Get(id)
    if not entityData then return end
    local entity = entityData.spawned
    if not entity or not DoesEntityExist(entity) then return end

    if entityData.freeze == nil or entityData.freeze then
        FreezeEntityPosition(entity, true)
    end
    if entityData.invincible then
        SetEntityInvincible(entity, entityData.invincible)
    end
    if entityData.targets then
        for k, v in pairs(entityData.targets) do
            print(v.label)
        end
        ClientEntity.SetTargets(id, entityData.targets)
    end
    if entityData.anim then
        ClientEntity.SetAnim(id, entityData.anim)
    end
    if entityData.attach then
        ClientEntity.SetAttach(id, entityData.attach)
    end
end

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
        entityData.spawned = entity
        SetEntityProperties(entityData.id)
        SetModelAsNoLongerNeeded(model)
    end
    if not entityData.OnSpawn then return end
    pcall(function (...)
        return entityData.OnSpawn(entityData)
    end)
end

local function RemoveEntity(entityData)
    entityData = entityData and entityData.args or entityData
    if not entityData then return end
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

--- Registers a ClientEntity definition and a proximity trigger that spawns/despawns it.
---
--- Note: When in-range, the spawned FiveM entity handle is stored on `entityData.spawned`.
--- @param entityData EntityData
--- @return table Registered point/entity entry (the value stored in ClientEntity.All[entityData.id]).
function ClientEntity.Create(entityData)
    entityData.id = entityData.id or Ids.CreateUniqueId(ClientEntity.All)
    if ClientEntity.All[entityData.id] then return ClientEntity.All[entityData.id] end
    entityData.rotation = entityData.rotation or vector3(0.0, 0.0, entityData.heading or 0.0)
    entityData.invoked =  entityData.invoked or GetInvokingResource() or "community_bridge"

    for k, v in pairs(ClientEntity.OnCreates) do
        if entityData[k] ~= nil then
            local success, results = pcall(function()
                return v(entityData)
            end)
            if success then
                entityData = results or entityData
            end
        end
    end


    local entityPoint = Point.Register(entityData.id, entityData.coords, entityData.spawnDistance or 50.0, entityData, SpawnEntity, RemoveEntity, UpdateEntity)
    ClientEntity.All[entityData.id] = entityPoint
    ClientEntity.Invoked[entityData.invoked] = ClientEntity.Invoked[entityData.invoked] or {}
    ClientEntity.Invoked[entityData.invoked][entityData.id] = entityData

    for k, v in pairs(entityPoint) do
        ClientEntity.SetKey(entityData.id, k, v)
    end
    return entityPoint
end

--- Gets the entity that was spawned or nil if player is not in range
---@param id ClientEntityId
---@return EntityHandle|nil
function ClientEntity.GetEntity(id)
    local entityData = ClientEntity.Get(id)
    if not entityData then return nil end
    return entityData.spawned
end
---Deprecated use ClientEntity.Create instead
ClientEntity.Register = ClientEntity.Create

--- Registers multiple entities.
--- @param entities table<number, EntityData> List of ClientEntity definitions.
--- @return table<ClientEntityId, table> Map of ClientEntity id to registered entries.
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

--- Unregisters a ClientEntity registration and deletes its spawned FiveM entity (if any).
--- @param id ClientEntityId ClientEntity id (key used in ClientEntity.All / Point system), not a FiveM entity handle.
function ClientEntity.Destroy(id)
    local entityData = ClientEntity.All[id]
    if not entityData then return end
    Point.Remove(id)
    RemoveEntity(entityData)
    ClientEntity.All[id] = nil
end
ClientEntity.Unregister = ClientEntity.Destroy

--- Sets a property on a registered ClientEntity entry.
--- If the entry defines an On<Key> handler (example: key='coords' -> OnCoords), it will be called.
--- @param id ClientEntityId ClientEntity id (key used in ClientEntity.All), not a FiveM entity handle.
--- @param key string Field name on the stored entity data table.
--- @param value any Value to set.
--- @return nil
function ClientEntity.SetKey(id, key, value)
    local entityData = ClientEntity.Get(id)
    if not entityData then return print(string.format("[ClientEntity] SetKey: Entity %s does not exist", id)) end

    local oldData = entityData[key]
    local handlerKey = "On" .. key:sub(1, 1):upper() .. key:sub(2)
    local handler = rawget(entityData, handlerKey)
    entityData[key] = value
    if handler then
        pcall(function()
            handler(entityData, key, value, oldData)
        end)
    end

end

--- Gets a registered ClientEntity entry.
--- @param id ClientEntityId ClientEntity id (key used in ClientEntity.All), not a FiveM entity handle.
--- @return EntityData|nil The registered entry; when spawned, entityData.spawned is the FiveM entity handle.
function ClientEntity.Get(id)
    return ClientEntity.All[id]
end

--- Gets all registered ClientEntity entries keyed by ClientEntity id.
--- @return table<ClientEntityId, EntityData>
function ClientEntity.GetAll()
    return ClientEntity.All
end

--- Plays or stops an animation on the spawned FiveM entity for a ClientEntity.
--- @param id ClientEntityId ClientEntity id.
--- @param anim ClientEntityAnim|nil Animation data; pass nil to stop.
function ClientEntity.SetAnim(id, anim)
    local entityData = ClientEntity.Get(id)
    if not entityData then return print(string.format("[ClientEntity] SetAnim: Entity %s does not exist", id)) end
    local entity = entityData.spawned
    if not entity or not DoesEntityExist(entity) then return end
    if not anim then
        return Bridge.Anim.Stop(nil, entity)
    end
    Bridge.Anim.Play(nil, entity, anim.dict, anim.name, anim.blendIn or 8.0, anim.blendOut or -8.0, anim.duration, anim.flags, anim.playbackRate or 0.0, anim.onComplete)
end

--- Attaches the spawned FiveM entity for a ClientEntity to a target, or detaches when nil.
--- @param id ClientEntityId ClientEntity id.
--- @param attachData ClientEntityAttach|nil Attachment data; pass nil to detach.
function ClientEntity.SetAttach(id, attachData)
    local entityData = ClientEntity.Get(id)
    if not entityData then return print(string.format("[ClientEntity] Attach: Entity %s does not exist", id)) end
    local entity = entityData.spawned
    if not attachData then
        if not entityData.spawned or not IsEntityAttached(entityData.spawned) then return end
        DetachEntity(entityData.spawned, true, true)
        return
    end
    local targetEntity =  attachData.target
    if type(targetEntity) == "string" then
        targetEntity = Bridge.Entity.Get(targetEntity)?.spawned or targetEntity
    else
        local player = GetPlayerFromServerId(targetEntity)
        if player and player ~= -1 then
            targetEntity = GetPlayerPed(player)
        end
    end
    targetEntity = tonumber(targetEntity)
    if not targetEntity then return end
    local bone = attachData.bone or 0
    local offset = attachData.offset or vector3(0.0, 0.0, 0.0)
    local rotation = attachData.rotation or vector3(0.0, 0.0, 0.0)
    AttachEntityToEntity(entity, targetEntity, GetPedBoneIndex(targetEntity, bone), offset.x, offset.y, offset.z, rotation.x, rotation.y, rotation.z, true, true, false, true, 1, true)
end

--- Adds target options to the spawned FiveM entity for a ClientEntity.
--- @param id ClientEntityId ClientEntity id.
--- @param options table Target config passed to Bridge.Target.AddLocalEntity.
function ClientEntity.SetTargets(id, options)
    local entityData = ClientEntity.Get(id)
    if not entityData then return end
    Bridge.Target.RemoveLocalEntity(entityData.spawned)
    entityData.targets = options
    if not options then return end
    Bridge.Target.AddLocalEntity(entityData.spawned, options)
end

--- Updates the stored coords for a ClientEntity and updates its proximity trigger.
--- @param id ClientEntityId ClientEntity id.
--- @param coords vector3 New coords.
function ClientEntity.UpdateCoords(id, coords)
    local entityData = ClientEntity.All[id]
    if not entityData then
        print(string.format("[ClientEntity] UpdateCoords: Entity %s does not exist", id))
        return
    end
    entityData.coords = coords
    Point.UpdateCoords(id, coords)
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        print(coords.x, coords.y, coords.z)
        SetEntityCoords(entityData.spawned, coords.x, coords.y, coords.z, false, false, false, true)
    end
end

function ClientEntity.UpdateRotation(id, rotation)
    local entityData = ClientEntity.All[id]
    if not entityData then
        print(string.format("[ClientEntity] UpdateRotation: Entity %s does not exist", id))
        return
    end
    if type(rotation) == "number" or type(rotation) == "string" then
        rotation = vector3(0.0, 0.0, tonumber(rotation))
    end
    entityData.rotation = rotation
    if entityData.spawned and DoesEntityExist(entityData.spawned) then
        SetEntityRotation(entityData.spawned, rotation.x, rotation.y, rotation.z, 2, true)
    end
end

--- Changes the model used by a ClientEntity and respawns it if currently spawned.
--- @param id ClientEntityId ClientEntity id.
--- @param model string|number Model name or hash.
function ClientEntity.ChangeModel(id, model)
    local entityData = ClientEntity.All[id]
    if not entityData then return print(string.format("[ClientEntity] ChangeModel: Entity %s does not exist", id)) end

    entityData.model = model
    if not entityData.spawned or not DoesEntityExist(entityData.spawned) then return end

    RemoveEntity(entityData)
    SpawnEntity(entityData)
end

--- Hooks onto entity creation by checking for a property on the entityData. Includes ServerEntity creations.
--- func = function(entityData) return modifiedEntityData end
--- @param property any property to look for when creating the entity
--- @param func any
function ClientEntity.SetOnCreate(property, func)
    ClientEntity.OnCreates[property] = func
end

--- Sets the OnSpawn callback for a ClientEntity.
--- @param id ClientEntityId ClientEntity id.
--- @param func fun(entityData: EntityData) Called when in-range spawn happens; entityData.spawned is the FiveM entity handle.
function ClientEntity.SetOnSpawn(id, func)
    local entityData = ClientEntity.All[id]
    if not entityData then
        print(string.format("[ClientEntity] SetOnSpawn: Entity %s does not exist", id))
        return
    end
    entityData.OnSpawn = func
end

--- Sets the OnRemove callback for a ClientEntity.
--- @param id ClientEntityId ClientEntity id.
--- @param func fun(entityData: EntityData) Called when out-of-range removal happens (and before deleting the spawned entity).
function ClientEntity.SetOnRemove(id, func)
    local entityData = ClientEntity.All[id]
    if not entityData then
        print(string.format("[ClientEntity] SetOnRemove: Entity %s does not exist", id))
        return
    end
    entityData.OnRemove = func
end

-- Network Event Handlers
RegisterNetEvent("community_bridge:client:CreateEntity", function(entityData)
    local src = source
    if src ~= 65535 then return end -- Server only
    ClientEntity.Create(entityData)
end)

RegisterNetEvent("community_bridge:client:CreateEntities", function(entities)
    local src = source
    if src ~= 65535 then return end -- Server only
    ClientEntity.CreateBulk(entities)
end)

RegisterNetEvent("community_bridge:client:DeleteEntity", function(id)
    local src = source
    if src ~= 65535 then return end -- Server only
    ClientEntity.Destroy(id)
end)

RegisterNetEvent("community_bridge:client:UpdateEntity", function(id, data)
    local src = source
    if src ~= 65535 then return end -- Server only
    for k, v in pairs(data) do
        ClientEntity.SetKey(id, k, v)
    end
end)

-- Resource Stop Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for id, entityData in pairs(ClientEntity.All) do
            Point.Remove(id)
            RemoveEntity(entityData)
        end
        ClientEntity.All = {}
    else
        for id, entityData in pairs(ClientEntity.Invoked[resourceName] or {}) do
            Point.Remove(id)
            RemoveEntity(entityData)
            ClientEntity.All[id] = nil
        end
    end
end)

return ClientEntity