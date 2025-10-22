---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

Framework = Framework or {}

QBCore = exports['qb-core']:GetCoreObject()

Framework.Shared = QBCore.Shared

---@description This will get the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'qb-core'
end

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'qb-core'
end

---@description This will return true if the player is loaded, false otherwise.
---This could be useful in scripts that rely on player loaded events and offer a debug mode to hit this function.
---@return boolean
Framework.GetIsPlayerLoaded = function()
    return LocalPlayer.state.isLoggedIn or false
end

---@description This will return a table of the player data, this will be in the framework format. 
---This is mainly for internal bridge use and should be avoided.
---@return table
Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData()
end

---@description This will return a table of all the jobs in the framework.
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

---@description This will get the players birth date
---@return string
Framework.GetPlayerDob = function()
    local player = Framework.GetPlayerData()
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
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
    TriggerEvent('QBCore:Notify', message, 'primary', time)
end

---@description This will display the help text message on the screen
---@param message string
---@param _position unknown
---@return nil
Framework.ShowHelpText = function(message, _position)
    return exports['qb-core']:DrawText(message, _position)
end

---@description This will hide the help text message on the screen
---@return nil
Framework.HideHelpText = function()
    return exports['qb-core']:HideText()
end

---@description This will return the players money by type, I recommend not using this
---as its the client and not secure or to be trusted. Use case is for a ui or a menu I guess.
---@param _type string
---@return number
Framework.GetAccountBalance = function(_type)
    local player = Framework.GetPlayerData()
    if not player then return 0 end
    local account = player.money
    if _type == 'money' then _type = 'cash' end
    return account[_type] or 0
end

---@description This will return the item data for the specified item.
---@param item string
---@return table
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

---@description This will get the hunger of a player
---@return number
Framework.GetHunger = function()
    local hunger = Framework.GetPlayerMetaData("hunger") or 0
    return math.floor((hunger) + 0.5) or 0
end

---@description This will get the thirst of a player
---@return number
Framework.GetThirst = function()
    local thirst = Framework.GetPlayerMetaData("thirst") or 0
    return math.floor((thirst) + 0.5) or 0
end

---@description This will get the players identifier (citizenid) etc.
---@return string
Framework.GetPlayerIdentifier = function()
    return Framework.GetPlayerData().citizenid
end

---@description This will get the players name (first and last).
---@return string
---@return string
Framework.GetPlayerName = function()
    local playerData = Framework.GetPlayerData()
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

---@deprecated Deprecated: This will return the players job name, job label, job grade label and job grade level
---@return string
---@return string
---@return string
---@return string
Framework.GetPlayerJob = function()
    local playerData = Framework.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

---@description This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
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

---@description This will return if the player has the specified item in their inventory
---@param item string
---@return boolean
Framework.HasItem = function(item)
	return QBCore.Functions.HasItem(item)
end

---@description This will return the item count for the specified item in the players inventory
---@param item string
---@return number
Framework.GetItemCount = function(item)
    local frameworkInv = Framework.GetPlayerData().items
    local count = 0
    for _, v in pairs(frameworkInv) do
        if v.name == item then
            count = count + (v.amount or v.count)
        end
    end
    return count
end

---@description This will return the players inventory as a table in the ox_inventory style format
---@return table
Framework.GetPlayerInventory = function()
    local items = {}
    local frameworkInv = Framework.GetPlayerData().items
    for _, v in pairs(frameworkInv) do
        table.insert(items, {
            name = v.name,
            label = v.label,
            count = v.amount or v.count,
            slot = v.slot,
            metadata = v.info,
            stack = v.unique,
            close = v.useable,
            weight = v.weight
        })
    end
    return items
end

---@description This will return the vehicle properties for the specified vehicle
---@param vehicle number
---@return table
Framework.GetVehicleProperties = function(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return {} end
    local vehicleProps = QBCore.Functions.GetVehicleProperties(vehicle)
    return vehicleProps or {}
end

---@description This will set the vehicle properties for the specified vehicle
---@param vehicle number
---@param properties table
---@return boolean
Framework.SetVehicleProperties = function(vehicle, properties)
    if not vehicle or not DoesEntityExist(vehicle) then return false end
    if not properties then return false end
    if NetworkGetEntityIsNetworked(vehicle) then
        local vehNetID = NetworkGetNetworkIdFromEntity(vehicle)
        local entOwner = GetPlayerServerId(NetworkGetEntityOwner(vehNetID))
        if entOwner ~= GetPlayerServerId(PlayerId()) then
            NetworkRequestControlOfEntity(vehicle)
            local count = 0
            while not NetworkHasControlOfEntity(vehicle) and count < 3000 do
                Wait(1)
                count = count + 1
            end
        end
    end
    return true, QBCore.Functions.SetVehicleProperties(vehicle, properties)
end

---@description This will get a players dead status
---@return boolean
Framework.GetIsPlayerDead = function()
    local playerData = Framework.GetPlayerData()
    return playerData.metadata["isdead"] or playerData.metadata["inlaststand"]
end

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