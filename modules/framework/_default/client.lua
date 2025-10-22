---@diagnostic disable: duplicate-set-field
Framework = Framework or {}

local currentJobCounts = GlobalState.jobcounts or {}

---@description State bag change handler to update job counts when global state changes
---@param bagName string
---@param key string
---@param value table|nil
AddStateBagChangeHandler('jobcounts', 'global', function(bagName, key, value)
    if not value then currentJobCounts = {} return end
    currentJobCounts = value
end)

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'default'
end

---@description This is an internal function that will be used to retrieve job counts later.
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    if not currentJobCounts[jobName] then return 0 end
    return currentJobCounts[jobName]
end

---@description This will allow passing a table of job names and returning a sum of the total count.
---@param tbl table
---@return number
Framework.GetJobCountTotal = function(tbl)
    local total = 0
    for _, jobName in pairs(tbl) do
        total = total + Framework.GetJobCount(jobName)
    end
    return total
end

return Framework