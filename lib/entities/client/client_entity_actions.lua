---@class ClientEntityActions
local ClientEntityActions = {
    ActionThreads = {},    -- Store running action threads { [entityId] = thread }
    ActionQueue = {},      -- Stores pending actions { [entityId] = {{name="ActionName", args={...}}, ...} }
    IsActionRunning = {},  -- Tracks if an action is currently running { [entityId] = boolean }
    RegisteredActions = {} -- Registry for action implementations { [actionName] = function(entityData, ...) }
}

-- Local helper functions
local function clearEntityTasks(entityData)
    if not entityData or not entityData.spawned or not DoesEntityExist(entityData.spawned) then return end

    if IsEntityAPed(entityData.spawned) then
        ClearPedTasksImmediately(entityData.spawned)
    end
    -- Other entity types might need different stop logic
end

local function clearActionThread(entityId)
    if ClientEntityActions.ActionThreads[entityId] then
        ClientEntityActions.ActionThreads[entityId] = nil
    end
end

local function isEntityValid(entityData)
    return entityData and entityData.spawned and DoesEntityExist(entityData.spawned)
end

local function logAction(message, ...)
    print(string.format("[ClientEntityActions] " .. message, ...))
end

-- Core action processing functions
function ClientEntityActions.ProcessNextAction(entityId)
    if ClientEntityActions.IsActionRunning [entityId] then return end -- Already running something
    local queue = ClientEntityActions.ActionQueue[entityId]
    if not queue or #queue == 0 then return end -- Queue is empty

    logAction("Processing next action for entity %s", entityId)
    local queue = ClientEntityActions.ActionQueue[entityId]
    if not queue or #queue == 0 then return end

    local nextAction = table.remove(queue, 1)
    local entityData = ClientEntity.Get(entityId)

    if not isEntityValid(entityData) then
        ClientEntityActions.ActionQueue[entityId] = nil
        return
    end

    -- Look up the action in the registry
    local actionFunc = ClientEntityActions.RegisteredActions [nextAction.name]
    if actionFunc then
        ClientEntityActions.IsActionRunning[entityId] = true
        actionFunc(entityData, table.unpack(nextAction.args))
    else
        logAction("Unknown action '%s' dequeued for entity %s", nextAction.name, entityId)
        ClientEntityActions.ProcessNextAction(entityId)
    end
end

function ClientEntityActions.RegisterAction(actionName, actionFunc)
    assert(type(actionName) == "string", "actionName must be a string")
    assert(type(actionFunc) == "function", "actionFunc must be a function")

    if ClientEntityActions.RegisteredActions[actionName] then
        logAction("WARNING: Overwriting registered action '%s'", actionName)
    end

    logAction("Registered action: %s", actionName)
    ClientEntityActions.RegisteredActions[actionName] = actionFunc
end

function ClientEntityActions.QueueAction(entityData, actionName, ...)
    local entityId = entityData.id
    if not ClientEntityActions.ActionQueue[entityId] then
        ClientEntityActions.ActionQueue[entityId] = {}
    end

    local actionArgs = { ... }
    table.insert(ClientEntityActions.ActionQueue[entityId], { name = actionName, args = actionArgs })

    if not ClientEntityActions.IsActionRunning[entityId] then
        ClientEntityActions.ProcessNextAction(entityId)
    end
end

function ClientEntityActions.StopAction(entityId)
    ClientEntityActions.ActionQueue[entityId] = nil
    ClientEntityActions.IsActionRunning[entityId] = false

    clearActionThread(entityId)
    clearEntityTasks(ClientEntity.Get(entityId))
end

function ClientEntityActions.SkipAction(entityId)
    if not ClientEntityActions.IsActionRunning[entityId] then return end

    ClientEntityActions.IsActionRunning[entityId] = false
    clearActionThread(entityId)
    clearEntityTasks(ClientEntity.Get(entityId))

    ClientEntityActions.ProcessNextAction(entityId)
end

-- Public API wrappers
function ClientEntityActions.Stop(entityData)
    ClientEntityActions.StopAction(entityData.id)
end

function ClientEntityActions.Skip(entityData)
    ClientEntityActions.SkipAction(entityData.id)
end

return ClientEntityActions
