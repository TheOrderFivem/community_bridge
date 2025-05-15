local resourceName = "sleepless_interact"
local configValue = BridgeClientConfig.TargetSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


local targetDebug = false
local function detectDebugEnabled()
    if BridgeSharedConfig.DebugLevel == 2 then
        targetDebug = true
    end
end

detectDebugEnabled()

local sleepless_interact = exports.sleepless_interact
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
    sleepless_interact:addGlobalPlayer(options)
end

Target.DisableTargeting = function(bool)
    --sleepless_interact:disableTargeting(bool)
    sleepless_interact:disableInteract(bool)
end

---comment
---@param options table
---@return nil
Target.AddGlobalVehicle = function(options)
    options = Target.FixOptions(options)
    sleepless_interact:addGlobalVehicle(options)
end

---comment
---@param options table
---@return nil
Target.RemoveGlobalVehicle = function(options)
    local assembledLables = {}
    for k, v in pairs(options) do
        table.insert(assembledLables, v.name)
    end
    sleepless_interact:removeGlobalVehicle(assembledLables)
end

---comment
---@param entities table
---@param options table
---@return nil
Target.AddLocalEntity = function(entities, options)
    options = Target.FixOptions(options)
    sleepless_interact:addLocalEntity(entities, options)
end

---comment
---@param models table
---@param options table
---@return nil
Target.AddModel = function(models, options)
    options = Target.FixOptions(options)
    sleepless_interact:addModel(models, options)
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
    local target = sleepless_interact:addCoords({
        coords = coords,
        options = options,
    })
    table.insert(targetZones, { name = name, id = target, creator = GetInvokingResource() })
    return target
end

Target.RemoveGlobalPlayer = function()
    sleepless_interact:removeGlobalPlayer()
end

---comment
---@param entity number
---@return nil
Target.RemoveLocalEntity = function(entity)
    sleepless_interact:removeLocalEntity(entity)
end

---comment
---@param model string
---@return nil
Target.RemoveModel = function(model)
    sleepless_interact:removeModel(model)
end

---comment
---@param name string
---@return nil
Target.RemoveZone = function(name)
    for _, data in pairs(targetZones) do
        if data.name == name then
            sleepless_interact:removeCoords(data.id)
            table.remove(targetZones, _)
            break
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, target in pairs(targetZones) do
            if target.creator == resource then
                sleepless_interact:removeZone(target.id)
            end
        end
        targetZones = {}
    end
end)

return Target