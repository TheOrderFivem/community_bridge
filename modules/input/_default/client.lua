function QBTypeToOxType(_type)
    if _type == "text" then
        return "input"
    elseif _type == "password" then
        return "input"
    elseif _type == "number" then
        return "number"
    elseif _type == "radio" then
        return "checkbox"
    elseif _type == "checkbox" then
        return "checkbox"
    elseif _type == "select" then
        return "select"
    end
end

function QBToOxInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            label = v.text,
            name = i,
            type = QBTypeToOxType(v.type),
            required = v.isRequired,
            default = v.placeholder,
        }
        if v.type == "select" then
            input.options = {}
            for i, v in pairs(v.options) do
                table.insert(input.options, {value = v.value, label = v.text})
            end
        elseif v.type == "checkbox" then
            for i, v in pairs(v.options) do
                table.insert(returnData, {value = v.value, label = v.text})
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end


function OxTypeToQBType(_type)
    if _type == "input" then
        return "text"
    elseif _type == "number" then
        return "number"
    elseif _type == "checkbox" then
        return "checkbox"
    elseif _type == "select" then
        return "select"
    elseif _type == "multi-select" then
        return "select"
    elseif _type == "slider" then
        return "number"
    elseif _type == "color" then
        return "text"
    elseif _type == "date" then
        return "date"
    elseif _type == "date-range" then
        return "date"
    elseif _type == "time" then
        return "time"
    elseif _type == "textarea" then
        return "text"
    end
end

function OxToQBInput(data)
    local returnData = {}
    for i, v in pairs(data) do
        local input = {
            text = v.label,
            name = i,
            type = OxTypeToQBType(v.type),
            isRequired = v.required,
            default = v.default or "",
        }
        if v.type == "select" then
            input.text = ""
            input.options = {}
            for k, j in pairs(v.options) do
                table.insert(input.options, {value = j.value, text = j.label})
            end
        elseif v.type == "checkbox" then
            input.text = ""
            input.options = {}
            if v.options then -- Checks if options varible is valid so checkboxes are bundled together (not used by ox for each checkpoint)
                for k, j in pairs(v.options) do
                    table.insert(input.options, {value = #returnData + #input.options + 1, text = j.label, checked = j.checked}) -- added checked option (used to show box as ticked or not)
                end
            else -- If options is not valid or people pass a single checkbox then it will be a single checkbox per entry
                table.insert(input.options, {value = #returnData + 1, text = v.label, checked = v.checked}) -- Kept value just incase it's used for other stuffs
            end
        end
        table.insert(returnData, input)
    end
    return returnData
end