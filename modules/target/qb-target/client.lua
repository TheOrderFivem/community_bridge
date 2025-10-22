---@diagnostic disable: duplicate-set-field
local resourceName = "qb-target"
if GetResourceState(resourceName) == 'missing' then return end
if GetResourceState("ox_target") ~= 'missing' then return end

Target = Target or {}
local targetDebug = BridgeSharedConfig and BridgeSharedConfig.DebugLevel == 2 or false

local targetZones = {}

Target = Target or {}

local qb_target = exports['qb-target']

Target.GetResourceName = function()
    return "qb-target"
end

function GetLargestDistance(data)
    local largestDistance = -1
    for _, v in pairs(data) do
        if v.distance and v.distance > largestDistance then
            largestDistance = v.distance
        end
    end
    return largestDistance ~= -1 and largestDistance or 2.0
end


---This is an internal function that is used to fix the options passed to fit alternative target systems, for example qb-ox or ox-qb etc.
---@param options table
---@return table
Target.FixOptions = function(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = action and function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        if v.serverEvent then
            v.type = "server"
            v.event = v.serverEvent
        elseif v.event then
            v.type = "client"
            v.event = v.event
        end
        options[k].action = select
        options[k].job = v.job or v.groups
        options[k].jobType = v.jobType
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
    qb_target:AllowTargeting(not bool)
end

---This will add target options to players.
---@param options table
Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    qb_target:AddGlobalPlayer({
        options = options,
        distance = GetLargestDistance(options)
    })
end

---This will remove target options from all players.
Target.RemoveGlobalPlayer = function()
    qb_target:RemoveGlobalPlayer()
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param options table
Target.AddGlobalPed = function(options)
    options = Target.FixOptions(options)
    qb_target:AddGlobalPed({
        options = options,
        distance = GetLargestDistance(options)
    })
end

---This will remove target options from all peds. This is useful for when you want to remove target options from all peds.
---@param options any
Target.RemoveGlobalPed = function(options)
    qb_target:RemoveGlobalPed(options)
end

---This will add taget options to all vehicles.
---@param options table
Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    qb_target:AddGlobalVehicle({
        options = options,
        distance = GetLargestDistance(options)
    })
end

---This will add a networked entity to the target system.
---@param netids table | number
---@param options table
Target.AddNetworkedEntity = function(netids, options)
    options = Target.FixOptions(options)
    qb_target:AddTargetEntity(netids, options)
end

---This will remove a networked entity from the target system.
---@param netids table | number
---@param optionNames string
Target.RemoveNetworkedEntity = function(netids, optionNames)
    qb_target:RemoveTargetEntity(netids, optionNames)
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
        distance = GetLargestDistance(options)
    })
end

---This will remove the target options from a local entity. This is useful for when you want to remove target options from a specific entity.
---@param entity number | table
---@param labels string | table | nil
Target.RemoveLocalEntity = function(entity, labels)
    qb_target:RemoveTargetEntity(entity, labels)
end

---This will add target options to all specified models. This is useful for when you want to add target options to all models of a specific type.
---@param models number | table
---@param options table
Target.AddModel = function(models, options, distance)
    options = Target.FixOptions(options)
    qb_target:AddTargetModel(models, {
        options = options,
        distance = GetLargestDistance(options),
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
Target.AddBoxZone = function(name, coords, size, heading, options, debug)
    options = Target.FixOptions(options)
    if not next(options) then return end
    qb_target:AddBoxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = debug or targetDebug,
        heading = heading,
        minZ = coords.z - (size.z * 0.5),
        maxZ = coords.z + (size.z * 0.5),
    }, {
        options = options,
        distance = GetLargestDistance(options),
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
    return name
end

---This will add a circle zone to the target system. This is useful for when you want to add target options to a specific area.
---@param name string
---@param coords table
---@param radius number
---@param options table
Target.AddSphereZone = function(name, coords, radius, options, debug)
    options = Target.FixOptions(options)
    qb_target:AddCircleZone(name, coords, radius, {
        name = name,
        debugPoly = targetDebug or debug,
    }, {
        options = options,
        distance = GetLargestDistance(options),
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
    return name
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