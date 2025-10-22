---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

Framework = Framework or {}

QBCore = exports['qb-core']:GetCoreObject()

Framework.Shared = QBCore.Shared

---@description This will return the name of the framework in use.
---@return string
Framework.GetFrameworkName = function()
    return 'qb-core'
end

---@description This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'qb-core'
end

---@description This will return if the player is an admin in the framework.
---@param src any
---@return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    return QBCore.Functions.HasPermission(src, 'admin')
end

---@description This will return the citizen ID of the player.
---@param src number
---@return string | nil
Framework.GetPlayerIdentifier = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.citizenid
end

---@description Returns the player data of the specified source in the framework defualt format.
---@param src any
---@return table | nil
Framework.GetPlayer = function(src)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end
    return player
end

---@description This will return the jobs registered in the framework in a table.
---@return table {name = jobName, label = jobLabel, grade = {name = gradeName, level = gradeLevel}}
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

---@description Returns the first and last name of the player.
---@return string|nil, string|nil
Framework.GetPlayerName = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

-- Framework.GetPlayerNameById(src)
-- Returns the full name of the player.
---@param citizenid number
---@return string|nil, string|nil
Framework.GetPlayerNameById = function(citizenid)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname
end

---Returns the player date of birth.
---@param src number
---@return string|nil
Framework.GetPlayerDob = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
end

-- Returns the player date of birth regardless if online or offline.
---@param citizenid string
---@return string|nil
Framework.GetPlayerDobById = function(citizenid)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
end

---Returns a table of items matching the specified name and if passed metadata from the player's inventory.
---returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
---@param src number
---@param item string
---@param metadata table
---@return table|nil {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
Framework.GetItem = function(src, item, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local playerInventory = playerData.items
    local repackedTable = {}
    for _, v in pairs(playerInventory) do
        if v.name == item and (not metadata or v.info == metadata) then
            table.insert(repackedTable, {
                name = v.name,
                count = v.amount or v.count,
                metadata = v.info,
                slot = v.slot,
            })
        end
    end
    return repackedTable
end

---@description This will return a table with the item info
---@param item string
---@return table {name, label, stack, weight, description, image}
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

---@description This will return the count of the item in the players inventory, if not found will return 0
---if metadata is passed it will find the matching items count.
---@param src number
---@param item string
---@param metadata table
---@return number
Framework.GetItemCount = function(src, item, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
    local playerData = player.PlayerData
    local playerInventory = playerData.items
    local count = 0
    for _, v in pairs(playerInventory) do
        if v.name == item and (not metadata or v.info == metadata) then
            count = count + (v.amount or v.count)
        end
    end
    return count
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Framework.HasItem = function(src, item)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount > 0
end

---@description Returns the entire inventory of the player as a table.
---@param src number
---@return table | nil {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
Framework.GetPlayerInventory = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local playerInventory = playerData.items
    local repackedTable = {}
    for _, v in pairs(playerInventory) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.amount or v.count,
            metadata = v.info,
            slot = v.slot,
        })
    end
    return repackedTable
end

---@description This will return a table of all logged in players
---@return table
Framework.GetPlayers = function()
    local players = QBCore.Functions.GetPlayers()
    local playerList = {}
    for _, src in pairs(players) do
        table.insert(playerList, src)
    end
    return playerList
end

---@description This will return the item data for the specified slot.
---@param src number
---@param slot number
---@return table|nil {name, label, weight, count, metadata, slot, stack, description}
Framework.GetItemBySlot = function(src, slot)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local playerInventory = playerData.items
    local repack = {}
    for _, v in pairs(playerInventory) do
        if v.slot == slot then
            return {
                name = v.name,
                label = v.label,
                weight = v.weight,
                count = v.amount or v.count,
                metadata = v.info,
                slot = v.slot,
                stack = v.unique or false,
                description = v.description or "none",
            }
        end
    end
    return repack
end

---@description Adds the specified metadata key and number value to the player's data.
---@return boolean|nil
Framework.SetPlayerMetadata = function(src, metadata, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    player.Functions.SetMetaData(metadata, value)
    return true
end

---@description Gets the specified metadata key to the player's data.
---@param src number
---@param metadata string
---@return any|nil
Framework.GetPlayerMetadata = function(src, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.metadata[metadata] or false
end


---@description Adds the specified value to the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.AddStress = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newStress = playerData.metadata.stress + value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---@description Removes the specified value from the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.RemoveStress = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newStress = (playerData.metadata.stress or 0) - value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---@description Adds the specified value from the player's hunger level.
---@param src number
---@param value number
---@return number | nil
Framework.AddHunger = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0) + value
    player.Functions.SetMetaData('hunger', Math.Clamp(newHunger, 0, 100))
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, playerData.metadata.thirst)
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newHunger
end

---@description Adds the specified value from the player's thirst level.
---@param src number
---@param value number
---@return number | nil
Framework.AddThirst = function(src, value)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0) + value
    player.Functions.SetMetaData('thirst', Math.Clamp(newThirst, 0, 100))
    TriggerClientEvent('hud:client:UpdateNeeds', src, playerData.metadata.hunger, newThirst)
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newThirst
end

---@description This will get the hunger of a player
---@param src number
---@return number | nil
Framework.GetHunger = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0)
    return math.floor((newHunger) + 0.5) or 0
end

---@description This will return a boolean if the player is dead or in last stand.
---@param src number
---@return boolean|nil
Framework.GetIsPlayerDead = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.metadata.isdead or playerData.metadata.inlaststand or false
end

---@description This will revive a player, if the player is dead or in last stand.
---@param src number
---@return boolean
Framework.RevivePlayer = function(src)
    src = tonumber(src)
    if not src then return false end
    TriggerClientEvent('hospital:client:Revive', src)
    return true
end


---@description This will get the thirst of a player
---@param src any
---@return number | nil
Framework.GetThirst = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0)
    return math.floor((newThirst) + 0.5) or 0
end

---@description Returns the phone number of the player.
---@param src number
---@return string | nil
Framework.GetPlayerPhone = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.phone
end

-- Returns the phone number of the player by citizen id.
---@param citizenid string
---@return string | nil
Framework.GetPlayerPhoneById = function(citizenid)
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.phone
end

-- Returns the gang name of the player.
---@param src number
---@return string | nil
Framework.GetPlayerGang = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.gang.name
end

---@description This will get a table of player sources that have the specified job name.
---@param job string
---@return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

---@deprecated Deprecated: Returns the job name, label, grade name, and grade level of the player.
---@param src number
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
Framework.GetPlayerJob = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

---@description This will return the players job name, job label, job grade label job grade level, boss status,
---and duty status in a table
---@param src number
---@return table | nil
Framework.GetPlayerJobData = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local jobData = playerData.job
    return {
        jobName = jobData.name,
        jobLabel = jobData.label,
        gradeName = jobData.grade.name,
        gradeLabel = jobData.grade.name,
        pay = jobData.grade.payment,
        gradeRank = jobData.grade.level,
        boss = jobData.isboss,
        onDuty = jobData.onduty,
    }
end

---@description Returns the players duty status.
---@param src number
---@return boolean | nil
Framework.GetPlayerDuty = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if not playerData.job.onduty then return false end
    return true
end

---@description This will toggle a players duty status
---@param src number
---@param status boolean
---@return boolean
Framework.SetPlayerDuty = function(src, status)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    player.Functions.SetJobDuty(status)
    TriggerEvent('QBCore:Server:SetDuty', src, player.PlayerData.job.onduty)
    return true
end

---@description Sets the player's job to the specified name and grade.
---@param src number
---@param name string
---@param grade string
---@return nil
Framework.SetPlayerJob = function(src, name, grade)
    local player = Framework.GetPlayer(src)
    if not player then return end
    return player.Functions.SetJob(name, grade)
end

---@description This will add money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    return player.Functions.AddMoney(_type, amount)
end

--- this will add money based on the citizen id and type of account (money/bank) regardless of online status.
--- @param citizenId string
--- @param _type string
--- @param amount number
Framework.AddAccountBalanceById = function(citizenId, _type, amount)
    if not citizenId or citizenId == '' then return end
    if _type == 'money' then _type = 'cash' end
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    if not player then
        local jsonPath = string.format("$.%s", _type)
        local add = MySQL.query.await('UPDATE players SET money = JSON_SET(money, ?, JSON_EXTRACT(money, ?) + ?) WHERE citizenid = ?',
            { jsonPath, jsonPath, amount, citizenId })
        if add.affectedRows > 0 then
            return true
        end
        return false
    end
    
    return player.Functions.AddMoney(_type, amount)
end

---This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    return player.Functions.RemoveMoney(_type, amount)
end

--- this will remove money based on the citizen id and type of account (money/bank) regardless of online status.
--- @param citizenId string
--- @param _type string
--- @param amount number
Framework.RemoveAccountBalanceById = function(citizenId, _type, amount)
    if not citizenId or citizenId == '' then return end
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    if _type == 'money' then _type = 'cash' end
    if not player then
        local jsonPath = string.format("$.%s", _type)
        local remove = MySQL.query.await('UPDATE players SET money = JSON_SET(money, ?, JSON_EXTRACT(money, ?) - ?) WHERE citizenid = ? AND JSON_EXTRACT(money, ?) >= ?',
            { jsonPath, jsonPath, amount, citizenId, jsonPath, amount })
        if remove.affectedRows > 0 then
            return true
        end
        return false
    end

    return player.Functions.RemoveMoney(_type, amount)
end
---This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@return string | nil
Framework.GetAccountBalance = function(src, _type)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if _type == 'money' then _type = 'cash' end
    return playerData.money[_type]
end

--- This will get the account balance for the specified citizen id and account type (money/bank) regardless of online status.
--- @param citizenId string
--- @param _type string
--- @return string | nil
Framework.GetAccountBalanceById = function(citizenId, _type)
    if not citizenId or citizenId == '' then return end
    local player = QBCore.Functions.GetPlayerByCitizenId(citizenId) or QBCore.Functions.GetOfflinePlayerByCitizenId(citizenId)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    return player.PlayerData.money[_type]
end

-- Framework.AddItem(src, item, amount, slot, metadata)
-- Adds the specified item to the player's inventory.
---@param src number
---@param item string
---@param amount number
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.AddItem = function(src, item, amount, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, { action = "add", item = item, count = amount, slot = slot, metadata = metadata })
    return player.Functions.AddItem(item, amount, slot, metadata)
end

---@description Removes the specified item from the player's inventory.
---@param src number
---@param item string
---@param amount number
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, { action = "remove", item = item, count = amount, slot = slot, metadata = metadata })
    return player.Functions.RemoveItem(item, amount, slot or nil)
end

---@description Sets the metadata for the specified item in the player's inventory.
---Notes, this is kinda a jank workaround. with the framework aside from updating the entire table theres not really a better way
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.SetMetadata = function(src, item, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local slotFinder = Framework.GetPlayerInventory(src)
    local freeSlot = Table.FindFirstUnoccupiedSlot(slotFinder)
    local itemSlot = slot or nil
    if itemSlot == nil then
        for _, v in pairs(slotFinder) do
            if v.name == item then
                slot = v.slot
                break
            end
        end
    end
    if not player.Functions.RemoveItem(item, 1, itemSlot) then return false end
    return player.Functions.AddItem(item, 1, slot, metadata)
end

---@description This will get all owned vehicles for the player
---@param src number
---@return table
Framework.GetOwnedVehicles = function(src)
    local citizenId = Framework.GetPlayerIdentifier(src)
    local result = MySQL.Sync.fetchAll("SELECT vehicle, plate FROM player_vehicles WHERE citizenid = '" .. citizenId .. "'")
    local vehicles = {}
    for i = 1, #result do
        local vehicle = result[i].vehicle
        local plate = result[i].plate
        table.insert(vehicles, { vehicle = vehicle, plate = plate })
    end
    return vehicles
end

---@description Registers a usable item with a callback function.
---@param itemName string
---@param cb function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    QBCore.Functions.CreateUseableItem(itemName, func)
end

RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    Framework.AddJobCount(src, jobData.jobName)
end)

RegisterNetEvent("QBCore:Server:OnPlayerUnload", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

RegisterNetEvent("QBCore:Server:OnJobUpdate", function(src, job)
    src = src or source
    if not job then return end
    TriggerEvent("community_bridge:Server:OnPlayerJobChange", src, job.name)
end)

AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

Framework.Commands = {}
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission, ...)
end

return Framework