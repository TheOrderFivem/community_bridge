Ids = Ids or {}


---This will generate a unique id.
---@param tbl table | nil
---@param len number | nil
---@param pattern string | nil
---@return string
Ids.CreateUniqueId = function(tbl, len, pattern) -- both optional
    tbl = tbl or {} -- table to check uniqueness. Ids to check against must be the key to the tables value
    len = len or 8

    local id = ""
    for i = 1, len do
        local char = ""
        if pattern then
            local charIndex = math.random(1, #pattern)
            char = pattern:sub(charIndex, charIndex)
        else
            char = math.random(1, 2) == 1 and string.char(math.random(65, 90)) or math.random(0, 9) -- CAP letter and number
        end
        id = id .. char
    end
    if tbl[id] then
        return Ids.CreateUniqueId(tbl, len, pattern)
    end
    return id
end


---This will generate a unique id.
---@param tbl table
---@param len number
---@return string
Ids.RandomUpper = function(tbl, len)
    return Ids.CreateUniqueId(tbl, len, "ABCDEFGHIJKLMNOPQRSTUVWXYZ")
end

---This will generate a unique id.
---@param tbl table
---@param len number
---@return string
Ids.RandomLower = function(tbl, len)
    return Ids.CreateUniqueId(tbl, len, "abcdefghijklmnopqrstuvwxyz")
end

---This will generate a unique id.
---@param tbl table
---@param len number
---@return string
Ids.RandomString = function(tbl, len)
    return Ids.CreateUniqueId(tbl, len, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
end

---This will generate a unique id.
---@param tbl table
---@param len number
---@return string
Ids.RandomNumber = function(tbl, len)
    return Ids.CreateUniqueId(tbl, len, "0123456789")
end

---This will generate a unique id.
---@param tbl table
---@param len number
---@return string
Ids.Random = function(tbl, len)
    return Ids.CreateUniqueId(tbl, len)
end

exports("Ids", Ids)
return Ids