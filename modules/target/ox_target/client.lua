---@diagnostic disable: duplicate-set-field
local resourceName = "ox_target"
if GetResourceState(resourceName) == 'missing' then return end

Target = Target or {}
local targetDebug = BridgeSharedConfig and BridgeSharedConfig.DebugLevel == 2 or false

local ox_target = exports.ox_target
local targetZones = {}

Target = Target or {}

Target.GetResourceName = function()
    return "ox_target"
end

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
Target.FixOptions = function(options)
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
Target.DisableTargeting = function(bool)
    ox_target:disableTargeting(bool)
end

---This will add target options to players.
---@param options table
Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPlayer(options)
end

---This will remove target options from all players.
Target.RemoveGlobalPlayer = function()
    ox_target:removeGlobalPlayer()
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param options table
Target.AddGlobalPed = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPed(options)
end

---This will remove target options from all peds. This is useful for when you want to remove target options from all peds.
---@param options any
Target.RemoveGlobalPed = function(options)
    ox_target:removeGlobalPed(options)
end

---This will add taget options to all vehicles.
---@param options table
Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalVehicle(options)
end

---This will remove target options from all vehicles.
---@param options table
Target.RemoveGlobalVehicle = function(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.name)
    end
    ox_target:removeGlobalVehicle(assembledLables)
end

---This will generate targets on non networked entites with the passed options.
---@param entities number | table
---@param options table
Target.AddLocalEntity = function(entities, options)
    options = Target.FixOptions(options)
    ox_target:addLocalEntity(entities, options)
end

---This will remove the target options from a local entity. This is useful for when you want to remove target options from a specific entity.
---@param entities table
---@param optionNames string | table | nil
Target.RemoveLocalEntity = function(entities, optionNames)
    ox_target:removeLocalEntity(entities, optionNames)
end

---This will add a networked entity to the target system.
---@param netids table | number
---@param options table
Target.AddNetworkedEntity = function(netids, options)
    options = Target.FixOptions(options)
    ox_target:addEntity(netids, options)
end

---This will remove a networked entity from the target system.
---@param netids table | number
---@param optionNames string
Target.RemoveNetworkedEntity = function(netids, optionNames)
    ox_target:removeEntity(netids, optionNames)
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param models number | table
---@param options table
Target.AddModel = function(models, options)
    options = Target.FixOptions(options)
    ox_target:addModel(models, options)
end

---This will remove target options from all specified models.
---@param model number
Target.RemoveModel = function(model)
    ox_target:removeModel(model)
end

---This will add a box zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param size table
---@param heading number
---@param options table
Target.AddBoxZone = function(name, coords, size, heading, options, debug)
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
Target.AddSphereZone = function(name, coords, radius, options, debug)
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
Target.RemoveZone = function(name)
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
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            ox_target:removeZone(target.id)
        end
    end
    targetZones = {}
end)

return Target