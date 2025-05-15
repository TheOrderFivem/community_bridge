---@class CacheEntry
---@field Name string
---@field Compare fun(): any
---@field WaitTime integer | nil
---@field LastChecked integer|nil
---@field OnChange fun(new:any, old:any)[]
---@field Value any

---@class CacheModule
---@field Caches table<string, CacheEntry>
---@field LoopRunning boolean
---@field Create fun(name:string, compare:fun():any, waitTime:integer | nil): CacheEntry
---@field Get fun(name:string): any
---@field OnChange fun(name:string, onChange:fun(new:any, old:any))
---@field Remove fun(name:string)
local Cache = {} ---@type CacheModule

local Config = Require("settings/sharedConfig.lua")
local max = 5000
local CreateThread = CreateThread
local Wait = Wait
local GetGameTimer = GetGameTimer

Cache.Caches = Cache.Caches or {}
Cache.LoopRunning = Cache.LoopRunning or false

---@param ... any
local function debugPrint(...)
    if Config.DebugLevel == 0 then return end
    print("^2[Cache]^0", ...)
end

local function HasActiveCaches()
    for _, cache in pairs(Cache.Caches) do
        if cache.WaitTime ~= nil then
            return true
        end
    end
    return false
end

local function processCacheEntry(now, cache)
    cache.LastChecked = cache.LastChecked or now
    cache.WaitTime = tonumber(cache.WaitTime) or max
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

    return remaining
end

local function getNextWait(now)
    local minWait = nil
    for name, cache in pairs(Cache.Caches) do
        if cache.Compare and cache.WaitTime ~= nil then
            local remaining = processCacheEntry(now, cache)
            if not minWait or remaining < minWait then
                minWait = remaining
                if minWait <= 0 then break end
            end
        end
    end
    return minWait
end

local function StartLoop()
    if Cache.LoopRunning then return end
    if not HasActiveCaches() then return end
    Cache.LoopRunning = true
    CreateThread(function()
        while Cache.LoopRunning do
            local now = GetGameTimer()
            local minWait = getNextWait(now)
            if minWait then
                Wait(math.max(0, minWait))
            else
                Wait(max)
            end
            if not HasActiveCaches() then
                Cache.LoopRunning = false
            end
        end
    end)
end

---@param name string
---@param compare fun():any
---@param waitTime integer | nil
---@return CacheEntry | nil
function Cache.Create(name, compare, waitTime)
    assert(name, "Cache name is required.")
    assert(compare, "Comparison function is required.")
    if type(waitTime) ~= "number" then
        waitTime = nil
    end
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    if cache and cache.Compare == compare then
        debugPrint(_name .. " already exists with the same comparison function.")
        return cache
    end
    local ok, result = pcall(compare)
    if not ok then
        debugPrint("Error creating cache '" .. _name .. "': " .. tostring(result))
        return nil
    end
    ---@type CacheEntry
    local newCache = {
        Name = _name,
        Compare = compare,
        WaitTime = waitTime, -- can be nil
        LastChecked = nil,
        OnChange = {},
        Value = result
    }
    Cache.Caches[_name] = newCache
    debugPrint(_name .. " created with initial value: " .. tostring(result))
    for _, onChange in pairs(newCache.OnChange) do
        onChange(newCache.Value, nil)
    end
    StartLoop()
    return newCache
end

---@param name string
---@return any
function Cache.Get(name)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    return cache and cache.Value or nil
end

--- This add a callback to the cache entry that will be called when the value changes.
--- The callback will be called with the new value and the old value.
--- you can call the value again to delete the callback.
---@param name string
---@param onChange fun(new:any, old:any)
---@return function unsubscribe
function Cache.OnChange(name, onChange)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")
    table.insert(cache.OnChange, onChange)
    return function()
        for i, cb in ipairs(cache.OnChange) do
            if cb == onChange then
                table.remove(cache.OnChange, i)
                break
            end
        end
    end
end

---@param name string
function Cache.Remove(name)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    if cache then
        Cache.Caches[_name] = nil
        debugPrint(_name .. " removed from cache.")
        if next(Cache.Caches) == nil then
            Cache.LoopRunning = false
        end
    end
end

---@param name string
---@param newValue any
function Cache.Update(name, newValue)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")
    local oldValue = cache.Value
    if oldValue ~= newValue then
        cache.Value = newValue
        for _, onChange in pairs(cache.OnChange) do
            onChange(newValue, oldValue)
        end
    end
end

setmetatable(Cache, {
    __index = function(self, key)
        local cache = self.Caches[key]
        if cache then
            return cache.Value
        else
            return rawget(self, key)
        end
    end,
    __call = function(self, name, compare, waitTime)
        if compare == nil then
            -- only name thats mean you only want to get the value
            return self.Get(self, name)
        else
            -- if compare is not nil then create cache
            return self.Create(self, name, compare, waitTime)
        end
    end,
})

--[[ -- Create new cache:
Cache("mycache", function() return math.random(1, 100) end, 1000)

-- get a value:
local value = Cache("mycache") ]]
return Cache
