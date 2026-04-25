---@diagnostic disable: duplicate-set-field
local resourceName = "ox_target"
if GetResourceState(resourceName) == 'missing' then return end

Target = Target or {}
local targetDebug = BridgeSharedConfig and BridgeSharedConfig.DebugLevel == 2 or false
local ox_target = exports.ox_target
local targetZones = {}

local resourceTargets = {}
resourceTargets.models = {}
resourceTargets.entities = {}
resourceTargets.networkedEntities = {}

Target.GetResourceName = function()
    return "ox_target"
end

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
function Target.FixOptions(options)
    for _, v in pairs(options) do
        local action = v.onSelect or v.action
        if not action then 
            local _type = v.type
            if _type and _type == "server" then
                v.serverEvent = v.event
                v.event = nil
            end

        else
            local select = function(entityOrData)
                if type(entityOrData) == 'table' then
                    return action(entityOrData.entity)
                end
                return action(entityOrData)
            end
            v.onSelect = select
        end
        v.groups = v.job or v.groups
        local optionsCanInteract = v.canInteract
        if optionsCanInteract then
            local id = Target.CreateCanInteract(optionsCanInteract)
            v.canInteract = function(...)
                return Target.CanInteract(id, ...)
            end
        end
    end
    return options
end

---This will toggle the targeting system on or off. This is useful for when you want to disable the targeting system for a specific player entirely.
---@param bool boolean
function Target.DisableTargeting(bool)
    ox_target:disableTargeting(bool)
end

---This will add target options to players.
---@param options table
function Target.AddGlobalPlayer(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPlayer(options)
end

---This will remove target options from all players.
function Target.RemoveGlobalPlayer()
    ox_target:removeGlobalPlayer()
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param options table
function Target.AddGlobalPed(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPed(options)
end

---This will remove target options from all peds. This is useful for when you want to remove target options from all peds.
---@param options any
function Target.RemoveGlobalPed(options)
    ox_target:removeGlobalPed(options)
end

---This will add taget options to all vehicles.
---@param options table
function Target.AddGlobalVehicle(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalVehicle(options)
end

---This will remove target options from all vehicles.
---@param options table
function Target.RemoveGlobalVehicle(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.name)
    end
    ox_target:removeGlobalVehicle(assembledLables)
end

---This will generate targets on non networked entites with the passed options.
---@param entities number | table
---@param options table
function Target.AddLocalEntity(entities, options)
    options = Target.FixOptions(options)
    ox_target:addLocalEntity(entities, options)
    local resource = GetInvokingResource() 
    resourceTargets.entities[resource] = resourceTargets.entities[resource] or {}
    table.insert(resourceTargets.entities[resource], { entities = entities})
end

---This will remove the target options from a local entity. This is useful for when you want to remove target options from a specific entity.
---@param entities table
---@param optionNames string | table | nil
function Target.RemoveLocalEntity(entities, optionNames)
    ox_target:removeLocalEntity(entities, optionNames)
end

---This will add a networked entity to the target system.
---@param netids table | number
---@param options table
function Target.AddNetworkedEntity(netids, options)
    options = Target.FixOptions(options)
    ox_target:addEntity(netids, options)
    local resource = GetInvokingResource() 
    resourceTargets.networkedEntities[resource] = resourceTargets.networkedEntities[resource] or {}
    table.insert(resourceTargets.networkedEntities[resource], { netids = netids})
end

---This will remove a networked entity from the target system.
---@param netids table | number
---@param optionNames string
function Target.RemoveNetworkedEntity(netids, optionNames)
    ox_target:removeEntity(netids, optionNames)
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param models number | table
---@param options table
function Target.AddModel(models, options)
    options = Target.FixOptions(options)
    ox_target:addModel(models, options)
    local resource = GetInvokingResource() 
    resourceTargets.models[resource] = resourceTargets.models[resource] or {}
    table.insert(resourceTargets.models[resource], { models = models})
end

---This will remove target options from all specified models.
---@param model number
function Target.RemoveModel(model)
    ox_target:removeModel(model)
end

---This will add a box zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param size table
---@param heading number
---@param options table
function Target.AddBoxZone(name, coords, size, heading, options, debug)
    options = Target.FixOptions(options or {})
    if not next(options) then return end
    local target = ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = heading,
        debug = debug or targetDebug,
        options = options,
    })
    table.insert(targetZones, { name = name, id = target, creator = GetInvokingResource() })
    return target
end

---This will add a circle zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param radius number
---@param options table
function Target.AddSphereZone(name, coords, radius, options, debug)
    options = Target.FixOptions(options)
    local target = ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        name = name,
        debug = targetDebug or debug,
        options = options
    })
    table.insert(targetZones, { name = name, id = target, creator = GetInvokingResource() })
    return target
end

---This will remove target options from a specific zone.
---@param name string
function Target.RemoveZone(name)
    if not name then return end
    for _, data in pairs(targetZones) do
        if data.name == name then
            ox_target:removeZone(data.id)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            ox_target:removeZone(target.id)
        end
    end
    targetZones = {}
    if resourceTargets.entities[resource] and #resourceTargets.entities[resource] > 0 then
        for _, data in pairs(resourceTargets.entities[resource]) do
            Target.RemoveLocalEntity(data.entities)
        end
    end
    resourceTargets.entities[resource] = nil
    if resourceTargets.networkedEntities[resource] and #resourceTargets.networkedEntities[resource] > 0 then
        for _, data in pairs(resourceTargets.networkedEntities[resource]) do        
            Target.RemoveNetworkedEntity(data.netids)
        end
    end
    resourceTargets.networkedEntities[resource] = nil
    if resourceTargets.models[resource] and #resourceTargets.models[resource] > 0 then
        for _, data in pairs(resourceTargets.models[resource]) do
            for _, model in pairs(data.models) do
                ox_target:removeModel(model)
            end
        end
    end
    resourceTargets.models[resource] = nil
end)

return Target
