Behaviors = {
    All = {},
    isSetup = false,
    invoked = {}
}

function Behaviors.Setup()
    if Behaviors.isSetup then return end
    Behaviors.isSetup = true    
    local behaviors = Require("lib/entities/shared/init.lua")
    for _, behavior in ipairs(behaviors or {}) do 
        Behaviors.Create(behavior.property, behavior)
    end
end

function Behaviors.Create(behaviorId, behavior)
    if not behaviorId or not behavior then return end
    if Behaviors.All[behaviorId] then return print(string.format("[ClientEntity] Behavior %s already exists", behaviorId)) end
    local invoking = GetInvokingResource() or "community_bridge"
    Behaviors.All[behaviorId] = behavior
    Behaviors.invoked[invoking] = Behaviors.invoked[invoking] or {}
    table.insert(Behaviors.invoked[invoking], behaviorId)
end

function Behaviors.Get(behaviorId)
    return Behaviors.All[behaviorId]
end

function Behaviors.Remove(behaviorId)
    if not Behaviors.All[behaviorId] then return end
    Behaviors.All[behaviorId] = nil
    return true
end

function Behaviors.Trigger(actionName, clientEntityData, ...)
    if not clientEntityData or not actionName then return end
    for property, behavior in pairs(Behaviors.All) do
        local hasBehaviorArgs = Behaviors.Has(property, clientEntityData) -- this is everything that's contained inside the object's individual property
        if hasBehaviorArgs and behavior[actionName] then
            local success, result = pcall(behavior[actionName], clientEntityData, hasBehaviorArgs, ...)
            if not success then
                print(string.format("[ClientEntity] Behavior %s failed: %s", property, result))
            end
        end
    end
end

function Behaviors.Inherit(behaviorId, clientEntityData, defaultData)
    if not Behaviors.All[behaviorId] then
        print(string.format("[ClientEntity] Behavior %s does not exist", behaviorId))
        return false
    end
    if not clientEntityData or not clientEntityData.id then
        print("[ClientEntity] Invalid client entity data provided for inheritance")
        return false
    end
    clientEntityData[behaviorId] = defaultData or {} -- Mark the entity as having this behavior
    return true
end

function Behaviors.Has(behaviorId, clientEntityData)
    return clientEntityData and clientEntityData[behaviorId]
end

function Behaviors.Cleanup(resourceName)
    if not resourceName or not Behaviors.invoked[resourceName] then return end
    for _, behaviorId in ipairs(Behaviors.invoked[resourceName]) do
        Behaviors.Remove(behaviorId)
    end
    Behaviors.invoked[resourceName] = nil
end

AddEventHandler("onResourceStop", function(resourceName)
    Behaviors.Cleanup(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for behaviorId, _ in pairs(Behaviors.All) do
        Behaviors.Remove(behaviorId)
    end
end)

return Behaviors