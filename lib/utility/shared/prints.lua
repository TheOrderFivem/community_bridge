Prints = Prints or {}

local function handle(result, value)
    if type(value) == 'function' then
        return tostring(value)
    end
    return result
end

local function format(color, ...)
    local data = {...}
    for i = 1, #data do
        if data[i] == nil then
            data[i] = 'nil'
        end
    end
    local newForm = {}
    local jsonDecode = {sort_keys = true, indent = true, exception = handle}
    for k, v in pairs(data) do
        local formatted
        if type(v) == 'table' then
            formatted = json.encode(v, jsonDecode)
        elseif type(v) == 'number' then
            formatted = tostring(v)
        elseif type(v) == 'boolean' then
            formatted = tostring(v)
        elseif type(v) == 'nil' then
            formatted = 'nil Value'
        elseif type(v) == 'string' then
            formatted = v
        elseif type(v) == 'function' then
            formatted = tostring(v)
        else
            formatted = tostring(v)
        end
        table.insert(newForm, color .. formatted)
    end
    return table.concat(newForm, color .. '  \n ')
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Info = function(...)
    print('^5 [INFO] '.. format('^5  ', ...))
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Warn = function(...)
    print('^3 [WARN] '.. format('^3', ...))
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Error = function(...)
    print('^1 [ERROR] '.. format('^1', ...))
end

---This will print a colored message to the console with the designated prefix.
---@param message string
Prints.Debug = function(...)
    print('^2 [DEBUG] '.. format('^2', ...))
end

return Prints
