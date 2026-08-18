---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

ESX = exports.es_extended:getSharedObject()

Framework = Framework or {}

local cachedItemList = nil

---@description This is an internal function, its here to attempt to emulate qbs shared items mainly. This should not be used outside of bridge.
Framework.ItemList = function()
    if cachedItemList then return cachedItemList end
    local items = lib.callback.await('community_bridge:Callback:GetFrameworkItems', false)
    cachedItemList = { Items = items.Items or {} }
    return cachedItemList
end

---@description This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    --print("This is depricated, please use Framework.GetResourceName() instead.")
    return Framework.GetResourceName()
end

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'es_extended'
end

---@description This will return true if the player is loaded, false otherwise.
---This could be useful in scripts that rely on player loaded events and offer a debug mode to hit this function.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return ESX.IsPlayerLoaded()
end

---@description This is an internal function, do not use this outside of bridge as there is no standard format between the frameworks.
--- @return table
Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
end

---@description This will return a table of all the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    local jobs = lib.callback.await('community_bridge:Callback:GetFrameworkJobs', false)
    return jobs
end

---@description This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local playerData = Framework.GetPlayerData()
    local dob = playerData.dateofbirth
    return dob
end

---@description This will return the players metadata for the specified metadata key.
---@param metadata table | string
---@return table | string | number | boolean
Framework.GetPlayerMetaData = function(metadata)
    return Framework.GetPlayerData().metadata[metadata]
end

---@description This will send a notification to the player.
---@param message string
---@param type string
---@param time number
---@return nil
Framework.Notify = function(message, type, time)
    return ESX.ShowNotification(message, type, time)
end

---@description Will Display the help text message on the screen
---@param message string
---@param _position unknown
---@return nil
Framework.ShowHelpText = function(message, _position)
    return exports.esx_textui:TextUI(message, "info")
end

---@description This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports.esx_textui:HideUI()
end

---@description This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    local playerData = Framework.GetPlayerData()
    return playerData.identifier
end

---@description This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.firstName, playerData.lastName
end

---@description Depricated : This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    --print("This is depricated, please use Framework.GetPlayerJobData() instead.")
    local jobData = Framework.GetPlayerJobData()
    return jobData.jobName, jobData.jobLabel, jobData.gradeName, jobData.gradeRank
end

--- @description This will return the players job name, job label, job grade label job grade level,
--- boss status, and duty status in a table
--- @return table
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

---@description This is an internal function to get status data
--- @param search string
Framework.GetStatusData = function(search)
    local playerData = Framework.GetPlayerData()
    if not playerData then return 0 end
    local status = playerData.variables.status
    for _, entry in ipairs(status) do
        if entry.name == search then
            return entry.percent or 0
        end
    end
    return 0
end

---@description This will get the hunger of a player
---@return number
Framework.GetHunger = function()
    local status = Framework.GetStatusData("hunger")
    return math.floor((status) + 0.5) or 0
end

---@description This will get the thirst of a player
---@return number
Framework.GetThirst = function()
    local status = Framework.GetStatusData("thirst")
    return math.floor((status) + 0.5) or 0
end

---@description Will return boolean if the player has the item.
---@param item string
---@param requiredCount number (optional)
---@return boolean
Framework.HasItem = function(item, requiredCount)
	local hasItem = ESX.SearchInventory(item, true)
    return hasItem >= (requiredCount or 1)
end

---@description This is an internal function used as a fallback, please use the Inventory.GetItemCount instead.
--- @param item string
--- @return number
Framework.GetItemCount = function(item)
    local inventory = Framework.GetPlayerInventory()
    if not inventory then return 0 end
    return inventory[item].count or 0
end

---@description Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Framework.GetItemInfo = function(item)
    return {}, print("ESX has not implemented GetItemInfo for this framework. Please ensure the inventory you are using is supported and start order is correct.")
end

---@description This is an internal function used as a fallback, please use the Inventory.GetPlayerInventory instead.
--- @return table {name, label, count, slot, metadata, stack, close, weight}
Framework.GetPlayerInventory = function()
    local playerData = Framework.GetPlayerData()
    if not playerData then return {} end
    local repack = {}
    for k, v in pairs(playerData.inventory) do
        repack[k] = {
            name = v.name,
            label = v.label,
            count = v.count,
            slot = 0,
            metadata = {},
            stack = false,
            close = v.usable or false,
            weight = v.weight or 0,
        }
    end
    return repack
end

---@description This will return the players money by type, I recommend not useing this as its the client and not secure or to be trusted.
---Use case is for a ui or a menu I guess.
---@param _type string
---@return number
Framework.GetAccountBalance = function(_type)
    local player = Framework.GetPlayerData()
    if not player then return 0 end
    local accounts = player.accounts
    if _type == 'cash' then _type = 'money' end
    for _, account in ipairs(accounts) do
        if account.name == _type then
            if not account.money or account.money <= 0 then return 0 end
            return account.money or 0
        end
    end
    return 0
end

--- @description This will get a players dead status
--- @return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.dead
end

---@description Event handler for when player is loaded in ESX framework
---@param xPlayer table
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    Wait(1500)
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

---@description Event handler for when player logs out in ESX framework
RegisterNetEvent('esx:onPlayerLogout', function()
    TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

---@description Event handler for when player job is updated in ESX framework
---@param data table Job data containing name, label, grade_label, and grade
RegisterNetEvent('esx:setJob', function(data)
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate', data.name, data.label, data.grade_label, data.grade)
end)

return Framework