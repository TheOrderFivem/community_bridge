local Callback = {}
local CallbackRegistry = {}

-- Constants
local RESOURCE = GetCurrentResourceName() or 'unknown'
local EVENT_NAMES = {
    CLIENT_TO_SERVER = RESOURCE .. ':CS:Callback',
    SERVER_TO_CLIENT = RESOURCE .. ':SC:Callback',
    CLIENT_RESPONSE = RESOURCE .. ':CSR:Callback',
    SERVER_RESPONSE = RESOURCE .. ':SCR:Callback'
}

-- Utility functions
local function generateCallbackId(name)
    return string.format('%s_%d', name, math.random(1000000, 9999999))
end

local function handleResponse(registry, name, callbackId, ...)
    local data = registry[callbackId]
    if not data then return end

    if data.callback then
        data.callback(...)
    end

    if data.promise then
        data.promise:resolve({ ... })
    end

    registry[callbackId] = nil
end

local function triggerCallback(eventName, target, name, args, callback)
    local callbackId = generateCallbackId(name)
    local promise = promise.new()

    CallbackRegistry[callbackId] = {
        callback = callback,
        promise = promise
    }

    if type(target) == 'table' then
        for _, id in ipairs(target) do
            TriggerClientEvent(eventName, tonumber(id), name, callbackId, table.unpack(args))
        end
    else
        TriggerClientEvent(eventName, tonumber(target), name, callbackId, table.unpack(args))
    end

    if not callback then
        local result = Citizen.Await(promise)
        local returnResults = (result and type(result) == 'table' ) and result or {result}
        return table.unpack(returnResults)
    end
end

-- Server-side implementation
if IsDuplicityVersion() then
    function Callback.Register(name, handler)
        Callback[name] = handler
    end

    function Callback.Trigger(name, target, ...)
        local args = { ... }
        local callback = type(args[1]) == 'function' and table.remove(args, 1) or nil
        return triggerCallback(EVENT_NAMES.SERVER_TO_CLIENT, target or -1, name, args, callback)
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_TO_SERVER, function(name, callbackId, ...)
        local handler = Callback[name]
        if not handler then return end

        local result = table.pack(handler(source, ...))
        TriggerClientEvent(EVENT_NAMES.CLIENT_RESPONSE, source, name, callbackId, table.unpack(result))
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_RESPONSE, function(name, callbackId, ...)
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

    -- Client-side implementation
else
    local ClientCallbacks = {}
    local ReboundCallbacks = {}

    function Callback.Register(name, handler)
        ClientCallbacks[name] = handler
    end

    function Callback.RegisterRebound(name, handler)
        ReboundCallbacks[name] = handler
    end

    function Callback.Trigger(name, ...)
        local args = { ... }
        local callback = type(args[1]) == 'function' and table.remove(args, 1) or nil

        local callbackId = generateCallbackId(name)
        local promise = promise.new()

        CallbackRegistry[callbackId] = {
            callback = callback,
            promise = promise
        }

        TriggerServerEvent(EVENT_NAMES.CLIENT_TO_SERVER, name, callbackId, table.unpack(args))

        if not callback then
            local result = Citizen.Await(promise)
            return #result == 1 and result[1] or table.unpack(result)
        end
    end

    RegisterNetEvent(EVENT_NAMES.CLIENT_RESPONSE, function(name, callbackId, ...)
        if ReboundCallbacks[name] then
            ReboundCallbacks[name](...)
        end
        handleResponse(CallbackRegistry, name, callbackId, ...)
    end)

    RegisterNetEvent(EVENT_NAMES.SERVER_TO_CLIENT, function(name, callbackId, ...)
        local handler = ClientCallbacks[name]
        if not handler then return end

        local result = table.pack(handler(...))
        TriggerServerEvent(EVENT_NAMES.SERVER_RESPONSE, name, callbackId, table.unpack(result))
    end)
end

-- Exports
exports('Callback', Callback)
exports('RegisterCallback', Callback.Register)
exports('TriggerCallback', Callback.Trigger)
if not IsDuplicityVersion() then
    exports('RegisterRebound', Callback.RegisterRebound)
end

return Callback
