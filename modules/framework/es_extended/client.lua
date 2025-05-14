---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports["es_extended"]:getSharedObject()

Framework = Framework or {}

Framework.GetFrameworkName = function()
    return 'es_extended'
end

---This will return a table of the players data, this is an internal table and should not be used.
---@return table
Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
end

--<-- TODO swap to internal callback system
---This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    local jobs = lib.callback.await('community_bridge:Callback:GetFrameworkJobs', false)
    return jobs
end

---This will return the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    local dob = playerData.dateofbirth
    return dob
end

---This will return the players metadata for the specified metadata key.
---@param metadata string
---@return table | nil
Framework.GetPlayerMetaData = function(metadata)
    return Framework.GetPlayerData().metadata[metadata]
end

---This will prompt the user with a notification message
---@param message string
---@param type string
---@param time number
---@return nil
Framework.Notify = function(message, type, time)
    return ESX.ShowNotification(message, type, time)
end

---Will Display the help text message on the screen
---@param message string
---@param _ unknown
---@return nil
Framework.ShowHelpText = function(message, _)
    return exports['esx_textui']:TextUI(message, "info")
end

---This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports['esx_textui']:HideUI()
end

---This will return the players identifier
---@return string
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData.identifier
end

---This will return the players first name, and the last name
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.firstName, playerData.lastName
end

---Depricated : This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade_label, playerData.job.grade
end

---This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@return table
Framework.GetPlayerJobData = function()
    local playerData = Framework.GetPlayerData()
    local jobData = playerData.job
    local isBoss = (jobData.grade_name == "boss")
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade_name,
        gradeLabel = jobData.grade_label,
        gradeRank = jobData.grade,
        boss = isBoss,
        onDuty = jobData.onduty,
    }
end

---This will return a boolean if the player has the item in their inventory
---@param item string
---@return boolean
Framework.HasItem = function(item)
	local hasItem = ESX.SearchInventory(item, true)
	return hasItem > 0 and true or false
end

---This will return a table of the players inventory
---@return table
Framework.GetPlayerInventory = function()
    local playerData = Framework.GetPlayerData()
    return playerData.inventory
end

---This will return a number of the item in the players inventory
---@param item string
---@return number
Framework.GetItemCount = function(item)
    local inventory = Framework.GetPlayerInventory()
    if not inventory then return 0 end
    return inventory[item].count or 0
end

---This will return a boolean if the player is dead
---@return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.dead
end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('esx:setJob', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade_label, data.grade)
end)

return Framework