---@diagnostic disable: duplicate-set-field
local resourceName = "0r-target"
if GetResourceState(resourceName) == 'missing' then return end

Target = Target or {}
local targetDebug = BridgeSharedConfig and BridgeSharedConfig.DebugLevel == 2 or false
local targetZones = {}
local or_target = exports['0r-target']

function Target.GetResourceName()
    return "0r-target"
end

local function warnUser(feature)
    print("^3[Community Bridge] 0r-target might not natively support global functions like: " .. tostring(feature) .. ". Try specific targeting instead.^0")
end

local function getLargestDistance(data)
    local largestDistance = -1
    for _, v in pairs(data) do
        if v.distance and v.distance > largestDistance then
            largestDistance = v.distance
        end
    end
    return largestDistance ~= -1 and largestDistance or 2.0
end

---FixOptions makes Community Bridge options compatible with 0r-target format
function Target.FixOptions(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = action and function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        
        -- Event routing
        if v.serverEvent then
            v.type = "server"
            v.event = v.serverEvent
        elseif v.event then
            v.type = "client"
            v.event = v.event
        end
        
        -- Assigning fixed structure
        options[k].action = select
        options[k].job = v.job or v.groups
        options[k].jobType = v.jobType
        
        -- Mapping bridge 'title' to 0r-target 'label' if label is missing
        if not options[k].label and v.title then
            options[k].label = v.title
        end
        
        -- Wrapping canInteract function safely
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

function Target.DisableTargeting(bool)
    warnUser("DisableTargeting")
end

function Target.AddGlobalPlayer(options)
    warnUser("AddGlobalPlayer")
end

function Target.RemoveGlobalPlayer()
    warnUser("RemoveGlobalPlayer")
end

function Target.AddGlobalPed(options)
    warnUser("AddGlobalPed")
end

function Target.RemoveGlobalPed(options)
    warnUser("RemoveGlobalPed")
end

function Target.AddGlobalVehicle(options)
    warnUser("AddGlobalVehicle")
end

function Target.RemoveGlobalVehicle(options)
    warnUser("RemoveGlobalVehicle")
end

function Target.AddNetworkedEntity(netids, options)
    options = Target.FixOptions(options)
    or_target:targetEntity(netids, {
        options = options,
        distance = getLargestDistance(options)
    })
end

function Target.RemoveNetworkedEntity(netids, optionNames)
    or_target:removeTEntity(netids, optionNames)
end

function Target.AddLocalEntity(entities, options)
    options = Target.FixOptions(options)
    or_target:targetEntity(entities, {
        options = options,
        distance = getLargestDistance(options)
    })
end

function Target.RemoveLocalEntity(entity, labels)
    or_target:removeTEntity(entity, labels)
end

function Target.AddModel(models, options, distance)
    options = Target.FixOptions(options)
    or_target:targetModel(models, {
        options = options,
        distance = getLargestDistance(options),
    })
end

function Target.RemoveModel(model)
    -- Using fallback due to typo in original docs for 0r-target mentioning qb-target
    pcall(function()
        or_target:removeTargetModel(model)
    end)
end

function Target.AddBoxZone(name, coords, size, heading, options, debug)
    options = Target.FixOptions(options)
    if not next(options) then return end
    or_target:boxZone(name, coords, size.x, size.y, {
        name = name,
        debugPoly = debug or targetDebug,
        heading = heading,
        minZ = coords.z - (size.z * 0.5),
        maxZ = coords.z + (size.z * 0.5),
    }, {
        options = options,
        distance = getLargestDistance(options),
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
    return name
end

function Target.AddSphereZone(name, coords, radius, options, debug)
    options = Target.FixOptions(options)
    or_target:circleZone(name, coords, radius, {
        name = name,
        useZ = true,
        debugPoly = targetDebug or debug,
    }, {
        options = options,
        distance = getLargestDistance(options),
    })
    table.insert(targetZones, { name = name, creator = GetInvokingResource() })
    return name
end

function Target.RemoveZone(name)
    if not name then return end
    for _, data in pairs(targetZones) do
        if data.name == name then
            or_target:removeZone(name)
            table.remove(targetZones, _)
            break
        end
    end
end

-- Automatically cleanup zones on stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, target in pairs(targetZones) do
        if target.creator == resource then
            or_target:removeZone(target.name)
        end
    end
    targetZones = {}
end)

return Target
