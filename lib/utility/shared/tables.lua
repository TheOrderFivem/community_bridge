Table = {}

Table.CheckPopulated = function(tbl)
    if #tbl == 0 then
        for _, _ in pairs(tbl) do
            return true
        end
        return false
    end
    return true
end

Table.DeepClone = function(tbl, out, omit)
    if type(tbl) ~= "table" then return tbl end
    local new = out or {}
    omit = omit or {}
    for key, data in pairs(tbl) do
        if not omit[key] then
            if type(data) == "table" then
                new[key] = Table.DeepClone(data)
            else
                new[key] = data
            end
        end
    end
    return new
end

Table.TableContains = function(tbl, search, nested)
    for _, v in pairs(tbl) do
        if nested and type(v) == "table" then
            return Table.TableContains(v, search)
        elseif v == search then
            return true, v
        end
    end
    return false
end

Table.TableContainsKey = function(tbl, search)
    for k, _ in pairs(tbl) do
        if k == search then
            return true, k
        end
    end
    return false
end

Table.TableGetKeys = function(tbl)
    local keys = {}
    for k ,_ in pairs(tbl) do
        table.insert(keys,k)
    end
    return keys
end

Table.GetClosest = function(coords, tbl)
    local closestPoint = nil
    local dist = math.huge
    for k, v in pairs(tbl) do
        local c = v.coords
        local d = c and #(coords - c)
        if d < dist then
            dist = d
            closestPoint = v
        end
    end
    return closestPoint
end

Table.FindFirstUnoccupiedSlot = function(tbl)
    local occupiedSlots = {}
    for _, v in pairs(tbl) do
        if v.slot then 
            occupiedSlots[v.slot] = true
        end
    end
    for i = 1, BridgeServerConfig.MaxInventorySlots do
        if not occupiedSlots[i] then
            return i
        end
    end
    return nil
end

Table.Append = function(tbl1, tbl2)
    for _, v in pairs(tbl2) do
        table.insert(tbl1, v)
    end
    return tbl1
end

Table.Split = function(tbl, size)
    local new1 = {}
    local new2 = {}
    size = size or math.floor(#tbl / 2)

    if size > #tbl then
        assert(false, "Size is greater than the length of the table.")
    end
    for i = 1, size do
        table.insert(new1, tbl[i])
    end
    for i = size + 1, #tbl do
        table.insert(new2, tbl[i])
    end
    return new1, new2
end

Table.Shuffle = function(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end


--- Filters elements from a table based on a predicate function
---@param tbl table The table to filter
---@param predicate function Function that returns true for elements to keep
---@return table Filtered table
Table.Filter = function(tbl, predicate)
    local filtered = {}
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            filtered[k] = v
        end
    end
    return filtered
end

--- Maps a function over all elements in a table
---@param tbl table The table to map over
---@param fn function Function to apply to each element
---@return table New table with mapped values
Table.Map = function(tbl, fn)
    local mapped = {}
    for k, v in pairs(tbl) do
        mapped[k] = fn(v, k)
    end
    return mapped
end

--- Reduces a table to a single value
---@param tbl table The table to reduce
---@param fn function The reducer function
---@param initial any Initial accumulator value
---@return any The final accumulated value
Table.Reduce = function(tbl, fn, initial)
    local acc = initial
    for k, v in pairs(tbl) do
        acc = fn(acc, v, k)
    end
    return acc
end

--- Finds first element matching predicate
---@param tbl table Table to search in
---@param predicate function Function that returns true for matching element
---@return any, any The matched value and key or nil if not found
Table.Find = function(tbl, predicate)
    for k, v in pairs(tbl) do
        if predicate(v, k) then
            return v, k
        end
    end
    return nil
end

--- Merges two tables deeply
---@param t1 table First table
---@param t2 table Second table
---@return table Merged table
Table.Merge = function(t1, t2)
    local result = Table.DeepClone(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = Table.Merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

--- Checks if two tables are equal in content
---@param t1 table First table
---@param t2 table Second table
---@return boolean True if tables are equal
Table.Equals = function(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return t1 == t2
    end

    for k, v in pairs(t1) do
        if not Table.Equals(v, t2[k]) then
            return false
        end
    end

    for k, _ in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end

    return true
end

--- Gets real size of a table (including non-numeric indices)
---@param tbl table Table to measure
---@return number Number of elements in table
Table.Size = function(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Converts table to string representation for debugging
---@param tbl table Table to convert
---@param indent? string Optional indentation
---@return string String representation of table
Table.ToString = function(tbl, indent)
    if not indent then indent = "" end
    local result = "{\n"
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and string.format("[\"%s\"]", k) or string.format("[%s]", tostring(k))
        result = result .. indent .. "  " .. key .. " = "
        if type(v) == "table" then
            result = result .. Table.ToString(v, indent .. "  ")
        else
            result = result .. tostring(v)
        end
        result = result .. ",\n"
    end
    return result .. indent .. "}"
end

--- Creates a new table with unique values
---@param tbl table Table to deduplicate
---@return table New table with unique values
Table.Unique = function(tbl)
    local seen = {}
    local result = {}
    for _, v in ipairs(tbl) do
        if not seen[v] then
            seen[v] = true
            table.insert(result, v)
        end
    end
    return result
end

exports("Table", Table)
return Table