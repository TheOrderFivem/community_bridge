local resourceName = "ox_target"
local configValue = BridgeClientConfig.TargetSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


local targetDebug = false
local function detectDebugEnabled()
    if BridgeClientConfig.DebugLevel == 2 then
        targetDebug = true
    end
end

detectDebugEnabled()

local ox_target = exports.ox_target
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
        options[k].onSelect = select
    end
    return options
end

---comment
---@param options table
---@return nil
Target.AddGlobalPlayer = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalPlayer(options)
end

---comment
---@param options table
---@return nil
Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    ox_target:addGlobalVehicle(options)
end

---comment
---@param options table
---@return nil
Target.RemoveGlobalVehicle = function(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.name)
    end
    ox_target:removeGlobalVehicle(assembledLables)
end

---comment
---@param entities table
---@param options table
---@return nil
Target.AddLocalEntity = function(entities, options)
    options = Target.FixOptions(options)
    ox_target:addLocalEntity(entities, options)
end

---comment
---@param models table
---@param options table
---@return nil
Target.AddModel = function(models, options)
    options = Target.FixOptions(options)
    ox_target:addModel(models, options)
end

---comment
---@param name string
---@param coords table
---@param size table
---@param heading number
---@param options table
---@return number
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

---comment
---@param name string
---@param coords vector3
---@param radius number
---@param heading number -- unused, but kept for compatibility
---@param options table
---@return number
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

Target.RemoveGlobalPlayer = function()
    ox_target:removeGlobalPlayer()
end

---comment
---@param entity number
---@return nil
Target.RemoveLocalEntity = function(entity)
    ox_target:removeLocalEntity(entity)
end

---comment
---@param model string
---@return nil
Target.RemoveModel = function(model)
    ox_target:removeModel(model)
end

---comment
---@param name string
---@return nil
Target.RemoveZone = function(name)
    for _, data in pairs(targetZones) do
        if data.name == name then
            ox_target:removeZone(data.id)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, target in pairs(targetZones) do
            if target.creator == resource then
                ox_target:removeZone(target.id)
            end
        end
        targetZones = {}
    end
end)
