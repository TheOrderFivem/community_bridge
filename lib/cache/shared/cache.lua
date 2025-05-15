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

local function StartLoop()
    if Cache.LoopRunning then return end
    if not HasActiveCaches() then return end
    Cache.LoopRunning = true
    CreateThread(function()
        while Cache.LoopRunning do
            local now = GetGameTimer()
            local minWait = nil
            for name, cache in pairs(Cache.Caches) do
                if cache.Compare and cache.WaitTime ~= nil then
                    cache.LastChecked = cache.LastChecked or now
                    cache.WaitTime = cache.WaitTime or max
                    local elapsed = now - cache.LastChecked
                    local remaining = cache.WaitTime - elapsed
                    if remaining <= 0 then
                        local oldValue = cache.Value
                        cache.Value = cache.Compare()
                        if cache.Value ~= oldValue and cache.OnChange then
                            for i = 1, #cache.OnChange do
                                cache.OnChange[i](cache.Value, oldValue)
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
            -- if there is no cache valid, stop the loop
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
    assert(type(compare) == "function", "Comparison function must be a function.")
    if not waitTime or type(waitTime) == "number" then
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
    for _, onCache in pairs(newCache.OnChange) do
      onChange(newCache.value,nil)
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

---@param name string
---@param onChange fun(new:any, old:any)
function Cache.OnChange(name, onChange)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Caches[_name]
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")
    cache.OnChange[#cache.OnChange + 1] = onChange
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
     for _, onCache in pairs(cache.OnChange) do
        onChange(cache.value,oldValue)
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
    __call = function(self, key)
        return self.Get(self, key)
    end,
})

-- with this change now we can use Cache("name") to get the value or simple Cache.name (Cache.Get("name"))

return Cache
