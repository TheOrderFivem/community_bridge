---@class CacheEntry
---@field name  string
---@field Compare fun(): any
---@field wait integer | nil
---@field lastChecked integer|nil
---@field OnChange fun(new:any, old:any)[]
---@field value any

---@class CacheModule
---@field Caches table<string, CacheEntry>
---@field LoopRunning boolean
---@field Create fun(name:string, compare:fun():any, waitTime:integer | nil): CacheEntry
---@field Get fun(name:string): any
---@field OnChange fun(name:string, onChange:fun(new:any, old:any))
---@field Remove fun(name:string)
Cache = Cache or {} ---@type CacheModule -- <-- we use Cache as a global variable so that if we dont required it more than once

Table = Table or Require('lib/utility/shared/tables.lua')
Id = Id or Require('lib/utility/shared/ids.lua')

Cache.Caches = Cache.Caches or {}
Cache.Invoked = Cache.Invoked or {}
Cache.LoopRunning = Cache.LoopRunning or false


local function debugPrint(...)
    if Config.DebugLevel == 0 then return end
    print("^2[Cache]^0", ...)
end

local function sortByWaitTime(caches)
    table.sort(caches, function(a, b)
        return (a.wait or 0) < (b.wait or 0)
    end)
end

local function StartLoop()
    if Cache.LoopRunning then return end
    Cache.LoopRunning = true
    CreateThread(function()
        local updateWaitTime = true
        local minWait = nil
        while Cache.LoopRunning do
            if updateWaitTime then
                updateWaitTime = false
                minWait = sortByWaitTime(Cache.Caches)
                SetTimeout(10000, function() updateWaitTime = true end) -- recheck every 10 seconds
            end
            
            for _, cache in pairs(Cache.Caches) do
                if not cache.lastChecked or (GetGameTimer() - cache.lastChecked) > (cache.wait or 0) then
                    local oldValue = cache.value
                    local newValue = cache.Compare()
                    if newValue ~= oldValue then
                        cache.value = newValue
                        for _, onChange in pairs(cache.OnChange) do
                            onChange(newValue, oldValue)
                        end
                    end
                    cache.lastChecked = GetGameTimer()
                end
            end
            
            if minWait then
                collectgarbage("collect")
                Wait(math.max(0, minWait))
                
            else
                Wait(5000)
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
    if cache then
        debugPrint(name .. " already exists in cache, returning existing cache.")
        return cache
    end
    local ok, result = pcall(compare)
    if not ok then
        debugPrint("Error creating cache '" .. _name .. "': " .. tostring(result))
        return nil
    end
    ---@type CacheEntry
    local newCache = {
        name = _name,
        Compare = compare,
        wait = waitTime or 5000, -- can be nil
        lastChecked = nil,
        OnChange = {},
        value = result,
        invoking = GetInvokingResource() or "unknown"
    }

    -- Track the cache with its resource
    Cache.Invoked[newCache.invoking] = Cache.Invoked[newCache.invoking] or {}
    table.insert(Cache.Invoked[newCache.invoking], newCache)
    Cache.Caches[_name] = newCache
    for _, onChange in pairs(newCache.OnChange) do
        debugPrint("Invoking OnChange callback for cache '" .. _name .. "'")
        onChange(newCache.value, 0)
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
    return cache
end

--- This add a callback to the cache entry that will be called when the value changes.
--- The callback will be called with the new value and the old value.
--- you can call the value again to delete the callback.
---@param name string
---@param onChange fun(new:any, old:any)
---@return string id
function Cache.OnChange(name, onChange)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Get(name)
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")

    local id = Id.CreateUniqueId(cache.OnChange)
    cache.OnChange[id] = onChange
    return id
end

function Cache.RemoveOnChange(name, id)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Get(name)
    assert(cache, "Cache with name '" .. _name .. "' does not exist.")
    if cache.OnChange[id] then
        cache.OnChange[id] = nil
        debugPrint("Removed OnChange callback from cache '" .. _name .. "' with ID: " .. id)
        return true
    end
    debugPrint("No OnChange callback found with ID: " .. id .. " in cache '" .. _name .. "'")
    return false
end

---@param name string
function Cache.Remove(name)
    assert(name, "Cache name is required.")
    local _name = tostring(name)
    local cache = Cache.Get(name)
    if not cache then return end
    Cache.Caches[_name] = nil
    debugPrint(_name .. " removed from cache.")
    if next(Cache.Caches) == nil then
        Cache.LoopRunning = false
    end
end

return Cache