---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_core') ~= 'started' then return end

QBox = exports.qbx_core

Framework = Framework or {}

Framework.GetFrameworkName = function()
    return 'qbx_core'
end

Framework.GetPlayerData = function()
    return QBox.GetPlayerData()
end

Framework.GetFrameworkJobs = function()
    return QBox.GetJobs()
end

Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.charinfo.birthdate
end

---Will Display the help text message on the screen
---@param message string
---@param _ unknown
---@return nil
Framework.ShowHelpText = function(message, _)
    if _ == nil then _ = 'left-center' end
    return exports.ox_lib:showTextUI(message, { position = _position })
end

---This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports.ox_lib:hideTextUI()
end

Framework.GetPlayerMetaData = function(metadata)
    local playerData = Framework.GetPlayerData()
    return playerData.metadata[metadata]
end

Framework.Notify = function(message, type, time)
    return QBox:Notify("Notification", type, time, message)
end

Framework.GetPlayerIdentifier = function()
    return Framework.GetPlayerData().citizenid
end

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

Framework.GetPlayerInventory = function()
    return Framework.GetPlayerData().items
end

---comment
---@param item string
---@return number
Framework.GetItemCount = function(item)
    -- This seems to be exclusively for ox_inventory, if other inventories are used, they need to be bridged in the inventory module. Until then we will return 0 and a print.
    return 0, print("Community_bridge:WARN: GetItemCount is not implemented for this framework, please use the inventory module to get the item count. If you are using a diffrent inventory please let us know so we can bridge it and have less nonsense.")
end

Framework.GetIsPlayerDead = function()
    local platerData = Framework.GetPlayerData()
    return platerData.metadata["isdead"] or platerData.metadata["inlaststand"]
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade.name, data.grade.level)
end)

return Framework