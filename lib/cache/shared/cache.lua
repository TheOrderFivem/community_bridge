local Cache = {}
local Config = Require("settings/sharedConfig.lua")
local max = 5000
local CreateThread = CreateThread
local Wait = Wait
local GetGameTimer = GetGameTimer


Cache.Caches = Cache.Caches or {}
Cache.LoopRunning = Cache.LoopRunning or false

local function print(...)
    if Config.DebugLevel == 0 then return end
    print("^2[Cache]^0", ...)
end

local function StartLoop()
    if Cache.LoopRunning then return end
    Cache.LoopRunning = true
    CreateThread(function()
        while Cache.LoopRunning do
            local now = GetGameTimer()
            local minWait = nil
            local caches = Cache.Caches
            for name, cache in pairs(caches) do
                if cache.Compare then
                    cache.LastChecked = cache.LastChecked or now
                    cache.WaitTime = cache.WaitTime or max
                    local elapsed = now - cache.LastChecked
                    local remaining = cache.WaitTime - elapsed
                    if remaining <= 0 then
                        local oldValue = cache.Value
                        cache.Value = cache.Compare()
                        if cache.Value ~= oldValue and cache.OnChange then
                            for _, onChange in pairs(cache.OnChange) do
                                onChange(cache.Value, oldValue)
                            end
                        end
                        cache.LastChecked = now
                        remaining = cache.WaitTime
                    end
                    if not minWait or remaining < minWait then
                        minWait = remaining
                        if minWait <= 0 then break end
                    end
                end
            end
            if minWait then
                Wait(math.max(0, minWait))
            else
                Wait(max)
            end
        end
    end)
end

function Cache.Create(name, compare, waitTime)
    assert(name, "Cache name is required.")
    assert(compare, "Comparison function is required.")
    assert(type(compare) == "function", "Comparison function must be a function.")
    local _name = tostring(name) -- Ensure name is a string
    local cache = Cache.Caches[_name]
    if cache and cache.Compare == compare then
        print(name .. " already exists with the same comparison function.")
        return cache
    end
    cache = nil                   -- clean variable, so we can use the same name for the new cache
    local s, r = pcall(function() -- Try to create the cache and catch any errors
        local _cache <const> = {
            Name = _name,
            Compare = compare,
            WaitTime = waitTime or max,
            LastChecked = nil,
            OnChange = {},
            Value = compare()
        }
        Cache.Caches[_name] = _cache
        print(_name .. " created with initial value: " .. tostring(Cache.Caches[_name].Value))
        for _, onChange in pairs(_cache.OnChange) do
            onChange(_cache.Value, nil)
        end
    end)
    if not s then
        print("Error creating cache '" .. _name .. "': " .. tostring(r))
        return nil
    end

    return StartLoop()
end

function Cache.Get(name)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    return cache and cache.Value or nil
end

function Cache.OnChange(name, onChange)
    assert(name, "Cache name is required.")
    local _name = tostring(name) -- Ensure name is a string
    local cache = Cache.Caches[_name]
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")
    cache.OnChange[#cache.OnChange + 1] = onChange
end

function Cache.Remove(name)
    assert(name, "Cache name is required.")
    local _name = tostring(name) -- Ensure name is a string
    local cache = Cache.Caches[_name]
    if cache then
        Cache.Caches[_name] = nil
        print(_name .. " removed from cache.")
        if next(Cache.Caches) == nil then
            Cache.LoopRunning = false -- Stop the loop if no caches are left
        end
    end
end

return Cache
