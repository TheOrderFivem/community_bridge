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
        if d and d < dist then
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

Table.Compare = function(a, b)
    if type(a) == "table" then
        for k, v in pairs(a) do
            if not Table.Compare(v, b[k]) then return false end
        end
        return true
    else
        return a == b
    end
end

Table.Count = function(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

exports("Table", Table)
return Table