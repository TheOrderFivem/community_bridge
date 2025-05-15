local resourceName = "qb-target"
local configValue = BridgeClientConfig.TargetSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
if GetResourceState('ox_target') == 'started' then return end -- this is for older versions of ox that supported the backwards compatability. As its depricated we dont want to touch that.

local targetDebug = false
local function detectDebugEnabled()
    if BridgeSharedConfig.DebugLevel == 2 then
        targetDebug = true
    end
end

detectDebugEnabled()

local targetZones = {}

Target = Target or {}
local qb_target = exports['qb-target']


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
        options[k].action = select
        options[k].job = v.job or v.groups
    end
    return options
end

---This will toggle the targeting system on or off. This is useful for when you want to disable the targeting system for a specific player entirely.
---@param bool boolean
Target.DisableTargeting = function(bool)
    qb_target:AllowTargeting(not bool)
end

---This will add target options to players.
---@param options table
Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    qb_target:AddGlobalPlayer({
        options = options,
        distance = options.distance or 1.5
    })
end

---This will remove target options from all players.
Target.RemoveGlobalPlayer = function()
    qb_target:RemoveGlobalPlayer()
end

---This will add taget options to all vehicles.
---@param options table
Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    qb_target:AddGlobalVehicle({
        options = options,
        distance = options.distance or 1.5
    })
end

---This will remove target options from all vehicles. 
---@param options table
Target.RemoveGlobalVehicle = function(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.label)
    end
    qb_target:RemoveGlobalVehicle(assembledLables)
end

---This will generate targets on non networked entites with the passed options.
---@param entities number | table
---@param options table
Target.AddLocalEntity = function(entities, options)
    options = Target.FixOptions(options)
    qb_target:AddTargetEntity(entities, {
        options = options,
        distance = options.distance or 1.5
    })
end

---This will remove the target options from a local entity. This is useful for when you want to remove target options from a specific entity.
---@param entity any
Target.RemoveLocalEntity = function(entity)
    qb_target:RemoveTargetEntity(entity)
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param models number | table
---@param options table
Target.AddModel = function(models, options)
    options = Target.FixOptions(options)
    qb_target:AddTargetModel(models, {
        options = options,
        distance = options.distance or 1.5,
    })
end

---This will remove target options from all specified models.
---@param model number
Target.RemoveModel = function(model)
    qb_target:RemoveTargetModel(model)
end

---This will add a box zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param size table
---@param heading number
---@param options table
Target.AddBoxZone = function(name, coords, size, heading, options)
    options = Target.FixOptions(options)
    qb_target:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = targetDebug,
        heading = heading,
        minZ = coords.z - (size.x * 0.5),
        maxZ = coords.z + (size.x * 0.5),
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
end

---This will add a circle zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param radius number
---@param options table
Target.AddSphereZone = function(name, coords, radius, options)
    options = Target.FixOptions(options)
    qb_target:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = targetDebug,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
end

---This will remove target options from a specific zone.
---@param name string
Target.RemoveZone = function(name)
    if not name then return end
    for _, data in pairs(targetZones) do
        if data.name == name then
            qb_target:RemoveZone(name)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            qb_target:RemoveZone(target.name)
        end
    end
    targetZones = {}
end)

return Target