local resourceName = "ox_target"
local configValue = BridgeClientConfig.TargetSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


local targetDebug = false
local function detectDebugEnabled()
    if BridgeSharedConfig.DebugLevel == 2 then
        targetDebug = true
    end
end

detectDebugEnabled()

local ox_target = exports.ox_target
local targetZones = {}

Target = Target or {}

---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
Target.FixOptions = function(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        options[k].onSelect = select
    end
    return options
end

---This will add target options to players.
---@param options table
Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPlayer(options)
end

---This will remove target options from all players.
Target.RemoveGlobalPlayer = function()
---@diagnostic disable-next-line: missing-parameter
    ox_target:removeGlobalPlayer()
end

---This will toggle the targeting system on or off. This is useful for when you want to disable the targeting system for a specific player entirely.
---@param bool boolean
Target.DisableTargeting = function(bool)
    ox_target:disableTargeting(bool)
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
---@param entity any
Target.RemoveLocalEntity = function(entity)
    ox_target:removeLocalEntity(entity)
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
Target.AddBoxZone = function(name, coords, size, heading, options)
    options = Target.FixOptions(options)
    local target = ox_target:addBoxZone({
        coords = coords,
        size = size,
        rotation = heading,
        debug = targetDebug,
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
Target.AddSphereZone = function(name, coords, radius, heading, options)
    options = Target.FixOptions(options)
    local target = ox_target:addSphereZone({
        coords = coords,
        radius = radius,
        name = name,
        debug = targetDebug,
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