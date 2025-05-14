---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

Framework = Framework or {}

---This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'qb-core'
end

Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData()
end

---This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    local jobs = {}
    for k, v in pairs(QBCore.Shared.Jobs) do
        table.insert(jobs, {
            name = k,
            label = v.label,
            grade = v.grades
        })
    end
    return jobs
end

---This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local player = Framework.GetPlayerData()
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
end

---This will return the players metadata for the specified metadata key.
---@param metadata table | string
---@return table | string | number | boolean
Framework.GetPlayerMetaData = function(metadata)
    return Framework.GetPlayerData().metadata[metadata]
end

Framework.Notify = function(message, type, time)
    TriggerEvent('QBCore:Notify', message, 'primary', time)
end

---Will Display the help text message on the screen
---@param message string
---@param _position unknown
---@return nil
Framework.ShowHelpText = function(message, _position)
    return exports['qb-core']:DrawText(message, _position)
end

---This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports['qb-core']:HideText()
end

Framework.GetItemInfo = function(item)
    local itemData = QBCore.Shared.Items[item]
    if not itemData then return {} end
    local repackedTable = {
        name = itemData.name,
        label = itemData.label,
        stack = itemData.unique,
        weight = itemData.weight,
        description = itemData.description,
        image = itemData.image
    }
    return repackedTable
end

---This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    return Framework.GetPlayerData().citizenid
end

---This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

---Depricated : This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

---This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@return table
Framework.GetPlayerJobData = function()
    local playerData = Framework.GetPlayerData()
    local jobData = playerData.job
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade.name,
        gradeLabel = jobData.grade.name,
        gradeRank = jobData.grade.level,
        boss = jobData.isboss,
        onDuty = jobData.onduty,
    }
end

Framework.HasItem = function(item)
	return QBCore.Functions.HasItem(item)
end

---comment
---@param item string
---@return number
Framework.GetItemCount = function(item)
    local frameworkInv = Framework.GetPlayerData().items
    local count = 0
    for _, v in pairs(frameworkInv) do
        if v.name == item then
            count = count + v.amount
        end
    end
    return count
end

Framework.GetPlayerInventory = function()
    local items = {}
    local frameworkInv = Framework.GetPlayerData().items
    for _, v in pairs(frameworkInv) do
        table.insert(items, {
            name = v.name,
            label = v.label,
            count = v.amount,
            slot = v.slot,
            metadata = v.info,
            stack = v.unique,
            close = v.useable,
            weight = v.weight
        })
    end
    return items
end

---This will get a players dead status.
---@return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.metadata["isdead"] or playerData.metadata["inlaststand"]
end

Framework.Shared = QBCore.Shared

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade_label, data.grade)
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(data)
    -- Unsure what data is passed in this, but considering the gang data isnt updating I doubt this was tested.
    --[[
    PlayerJobName = data.name
    PlayerJobLabel = data.label
    PlayerJobGradeName = data.grade.name
    PlayerJobGradeLevel = data.grade.level
    TriggerEvent('community_bridge:Client:OnPlayerGangUpdate', PlayerGangName, PlayerGangLabel, PlayerGangGradeName, PlayerGangGradeLevel)
    --]]
end)

return Framework