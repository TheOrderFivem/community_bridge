local resourceName = "qb-target"
local configValue = BridgeClientConfig.TargetSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
if GetResourceState('ox_target') == 'started' then return end -- this is for older versions of ox that supported the backwards compatability. As its depricated we dont want to touch that.

local targetDebug = false
local function detectDebugEnabled()
    if BridgeClientConfig.DebugLevel == 2 then
        targetDebug = true
    end
end

detectDebugEnabled()

local targetZones = {}

Target = Target or {}

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

Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = options.distance or 1.5
    })
end


Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddGlobalVehicle({
        options = options,
        distance = options.distance or 1.5
    })
end

Target.RemoveGlobalVehicle = function(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.label)
    end
    exports['qb-target']:RemoveGlobalVehicle(assembledLables)
end

Target.AddLocalEntity = function(entities, options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddTargetEntity(entities, {
        options = options,
        distance = options.distance or 1.5
    })
end

Target.AddModel = function(models, options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options.distance or 1.5,
    })
end

Target.AddBoxZone = function(name, coords, size, heading, options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddBoxZone(name, coords, size.x, size.y, {
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

Target.AddSphereZone = function(name, coords, radius, options)
    options = Target.FixOptions(options)
    exports['qb-target']:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = targetDebug,
    }, {
        options = options,
        distance = options.distance or 1.5,
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
end

Target.RemoveGlobalPlayer = function()
    exports['qb-target']:RemoveGlobalPlayer()
end

Target.RemoveLocalEntity = function(entity)
    exports['qb-target']:RemoveTargetEntity(entity)
end

Target.RemoveModel = function(model)
    exports['qb-target']:RemoveTargetModel(model)
end

Target.RemoveZone = function(name)
    for _, data in pairs(targetZones) do
        if data.name == name then
            exports['qb-target']:RemoveZone(name)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, target in pairs(targetZones) do
            if target.creator == resource then
                exports['qb-target']:RemoveZone(target.name)
            end
        end
        targetZones = {}
    end
end)