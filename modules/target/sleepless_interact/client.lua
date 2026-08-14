---@diagnostic disable: duplicate-set-field
local resourceName = "sleepless_interact"
if GetResourceState(resourceName) == 'missing' then return end
if GetResourceState("ox_target") == 'started' then return end

local targetDebug = BridgeSharedConfig and BridgeSharedConfig.DebugLevel == 2 or false
local sleepless_interact = exports.sleepless_interact
local targetZones = {}

Target = Target or {}

function Target.GetResourceName()
    return "sleepless_interact"
end

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
function Target.FixOptions(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        options[k].onSelect = select
        options[k].groups = v.job or v.groups
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
function Target.DisableTargeting(bool) -- someone disabled this mistakenly
    sleepless_interact:disableInteract(bool)
end

---This will add target options to players.
---@param options table
function Target.AddGlobalPlayer(options)
    options = Target.FixOptions(options)
    sleepless_interact:addGlobalPlayer(options)
end

---This will remove target options from all players.
function Target.RemoveGlobalPlayer()
    sleepless_interact:removeGlobalPlayer()
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param options table
function Target.AddGlobalPed(options)
    options = Target.FixOptions(options)
    sleepless_interact:addGlobalPed(options)
end

---This will remove target options from all peds. This is useful for when you want to remove target options from all peds.
---@param options any
function Target.RemoveGlobalPed(options)
    sleepless_interact:removeGlobalPed(options)
end

---This will add taget options to all vehicles.
---@param options table
function Target.AddGlobalVehicle(options)
    options = Target.FixOptions(options)
    sleepless_interact:addGlobalVehicle(options)
end

---This will remove target options from all vehicles.
---@param options table
function Target.RemoveGlobalVehicle(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.name)
    end
    sleepless_interact:removeGlobalVehicle(assembledLables)
end

---This will add a networked entity to the target system.
---@param netids table | number
---@param options table
function Target.AddNetworkedEntity(netids, options)
    options = Target.FixOptions(options)
    sleepless_interact:addEntity(netids, options)
end

---This will remove a networked entity from the target system.
---@param netids table | number
---@param optionNames string
function Target.RemoveNetworkedEntity(netids, optionNames)
    sleepless_interact:removeEntity(netids, optionNames)
end

---This will generate targets on non networked entites with the passed options.
---@param entities number | table
---@param options table
function Target.AddLocalEntity(entities, options)
    options = Target.FixOptions(options)
    sleepless_interact:addLocalEntity(entities, options)
end

---This will remove the target options from a local entity. This is useful for when you want to remove target options from a specific entity.
---@param entity number | table
---@param labels string | table | nil
function Target.RemoveLocalEntity(entity, labels)
    sleepless_interact:removeLocalEntity(entity, labels)
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param models number | table
---@param options table
function Target.AddModel(models, options)
    options = Target.FixOptions(options)
    sleepless_interact:addModel(models, options)
end

---This will remove target options from all specified models.
---@param model number
function Target.RemoveModel(model)
    sleepless_interact:removeModel(model)
end

---This will add a box zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param size table
---@param heading number
---@param options table
function Target.AddBoxZone(name, coords, size, heading, options)
    options = Target.FixOptions(options)
    local target = sleepless_interact:addCoords({
        coords = coords,
        options = options,
    })
    table.insert(targetZones, { name = name, id = target, creator = GetInvokingResource() or GetCurrentResourceName() })
    return target
end

---This will add a circle zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param radius number
---@param options table
function Target.AddSphereZone(name, coords, radius, options, debug)
    options = Target.FixOptions(options)
    local target = sleepless_interact:addSphereZone({
        coords = coords,
        radius = radius,
        name = name,
        debug = targetDebug or debug,
        options = options
    })
    table.insert(targetZones, { name = name, id = target, creator = GetInvokingResource() or GetCurrentResourceName() })
    return target
end

---This will remove target options from a specific zone.
---@param name string
function Target.RemoveZone(name)
    for _, data in pairs(targetZones) do
        if data.name == name then
            sleepless_interact:removeCoords(data.id)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            sleepless_interact:removeZone(target.id)
        end
    end
    targetZones = {}
end)

return Target