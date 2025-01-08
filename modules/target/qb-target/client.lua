if GetResourceState('qb-target') ~= 'started' or GetResourceState('ox_target') == 'started' then return end

local targetDebug = false
local function detectDebugEnabled()
    if BridgeClientConfig.DebugLevel == 3 then
        targetDebug = true
    end
end

detectDebugEnabled()

local targetZones = {}

Target = {}

Target.AddGlobalPlayer = function(options)
    for k, v in pairs(options) do
        options[k].action = v.onSelect
    end
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = options.distance or 1.5
    })
end

Target.AddLocalEntity = function(entities, options)
    for k, v in pairs(options) do
        options[k].action = v.onSelect
    end
    exports['qb-target']:AddTargetEntity(entities, {
        options = options,
        distance = options.distance or 1.5
    })
end

Target.AddModel = function(models, options)
    for k, v in pairs(options) do
        options[k].action = v.onSelect
    end
    exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options.distance or 1.5,
    })
end

Target.AddBoxZone = function(name, coords, size, heading, options)
    for k, v in pairs(options) do
        options[k].action = v.onSelect
    end
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
    if resource ~= GetCurrentResourceName() then
        for _, target in pairs(targetZones) do
            if target.creator == resource then
                exports['qb-target']:RemoveZone(target.name)
            end
        end
        targetZones = {}
    end
end)