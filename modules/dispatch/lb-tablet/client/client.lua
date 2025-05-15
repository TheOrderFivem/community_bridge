if GetResourceState('lb-tablet') ~= 'started' then return end
Dispatch = Dispatch or {}

local function getPriorityLevel(priority)
    if priority == 1 then
        return 'low'
    elseif priority == 2 then
        return 'medium'
    elseif priority == 3 then
        return 'high'
    else
        return 'medium'
    end
end

---commentThis will send an alert to the passed jobs
---@param data table
Dispatch.SendAlert = function(data)
    local streetName, _ = Utility.GetStreetNameAtCoords(data.coords)
    local priority = getPriorityLevel(data.priority)
    if type(data.jobs) == 'table' then
        data.jobs = data.jobs[1]
    end
    if data.time and data.time > 1000 then
        data.time = math.floor((data.time / 1000) + 0.5)
    end
    local alertData = {
        priority = priority,
        code = data.code or '10-80',
        title = 'Dispatch Alert!',
        description = data.message,
        location = {
            label = streetName,
            coords = vec2(data.coords.x, data.coords.y)
        },
        time = data.time or 10000,
        job = data.jobs,
    }
    TriggerServerEvent("community_bridge:server:dispatch:sendAlert", alertData)
end

return Dispatch