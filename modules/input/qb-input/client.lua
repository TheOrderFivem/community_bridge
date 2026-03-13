---@diagnostic disable: duplicate-set-field
local resourceName = "qb-input"
local configValue = BridgeClientConfig.InputSystem
if (configValue == "auto" and GetResourceState(resourceName) == "missing") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Input = {}

-- this probably needs improvement
function Input.Open(title, data, isQBFormat, submitText)
    local input = data.inputs
    if not isQBFormat then
        input = OxToQBInput(data)
    end
    local returnData = exports['qb-input']:ShowInput({
        header = title,
        submitText = submitText or "Submit",
        inputs = input
    })
    if not returnData then return end
    if returnData[1] then return returnData end
    --converting to standard format (ox)
    local convertedData = {}
    if isQBFormat then
        for i, v in pairs(input) do
            for k, j in pairs(returnData) do
                if k == v.name then
                    convertedData[v.name] = j
                end
            end
        end
        return convertedData
    end

    for i, v in pairs(returnData) do
        local index = i and tonumber(i)
        v = tostring(v) == "true" and true or (tostring(v) == "false" and false or v)
        if not index then
            table.insert(convertedData, v)
        else
            convertedData[index] = v
        end
    end
    return convertedData
end

function Input.GetResourceName()
    return resourceName
end

return Input
