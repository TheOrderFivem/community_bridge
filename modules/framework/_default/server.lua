---@diagnostic disable: duplicate-set-field
Framework = Framework or {}

local jobsRegisteredTable = {}
local invertedJobsRegisteredTable = {}
local globalState = GlobalState

globalState.jobcounts = {}

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'default'
end

---@description This is an internal function that will be used to retrieve job counts later.
---@param jobName string
---@return number
Framework.GetJobCount = function(jobName)
    if not jobsRegisteredTable[jobName] then return 0 end
    local count = 0
    for _ in pairs(jobsRegisteredTable[jobName]) do
        count = count + 1
    end
    return count
end

---@description This will allow passing a table of job names and returning a sum of the total count.
---@param tbl any
---@return number
Framework.GetJobCountTotal = function(tbl)
    local total = 0
    for _, jobName in pairs(tbl) do
        total = total + Framework.GetJobCount(jobName)
    end
    return total
end

---@description This will return a list of player sources for a given job.
---@param jobName string
---@return table
Framework.GetPlayerSourcesByJob = function(jobName)
    if not jobsRegisteredTable[jobName] then return {} end
    local sources = {}
    for src in pairs(jobsRegisteredTable[jobName]) do
        table.insert(sources, src)
    end
    return sources
end

---@description This will update the cached tables for job counts.
---This is used to track how many players are in a job.
---@param src number
---@param jobName string
Framework.AddJobCount = function(src, jobName)
    if not src or not jobName then return false end
    if not jobsRegisteredTable[jobName] then jobsRegisteredTable[jobName] = {} end
    if jobsRegisteredTable[jobName][src] then return false end

    jobsRegisteredTable[jobName][src] = true
    invertedJobsRegisteredTable[src] = jobName

    local newJobCounts = {}
    for job, _ in pairs(jobsRegisteredTable) do
        newJobCounts[job] = Framework.GetJobCount(job)
    end
    globalState.jobcounts = newJobCounts

    return true
end

---@description This will return the job name for a given source.
---@param src number
Framework.SearchJobCountBySource = function(src)
    return invertedJobsRegisteredTable[src]
end

---@description This will remove the job count for a given source.
---@param src number
---@param jobName string | nil
Framework.RemoveJobCount = function(src, jobName)
    if not src then return false end

    if not jobName then jobName = invertedJobsRegisteredTable[src] end
    if not jobName then return false end

    invertedJobsRegisteredTable[src] = nil
    if jobsRegisteredTable[jobName] then
        jobsRegisteredTable[jobName][src] = nil
    end

    local newJobCounts = {}
    for job, _ in pairs(jobsRegisteredTable) do
        local count = Framework.GetJobCount(job)
        if count > 0 then
            newJobCounts[job] = count
        end
    end
    globalState.jobcounts = newJobCounts

    return true
end

---@description Event handler for when a player's job changes, updates job counts accordingly
---@param src number
---@param newJobName string
AddEventHandler('community_bridge:Server:OnPlayerJobChange', function(src, newJobName)
    local previousJob = invertedJobsRegisteredTable[src]
    if previousJob then Framework.RemoveJobCount(src, previousJob) end
    if newJobName then Framework.AddJobCount(src, newJobName) end
end)

---@description Event handler for when a player unloads, removes them from job counts
---@param src number
AddEventHandler('community_bridge:Server:OnPlayerUnload', function(src)
    Framework.RemoveJobCount(src)
end)

return Framework