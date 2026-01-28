---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

Framework = Framework or {}

QBCore = exports['qb-core']:GetCoreObject()

Framework.Shared = QBCore.Shared

---@description This will return the name of the framework in use.
---@return string
Framework.GetFrameworkName = function()
    print("[Community Bridge] Warning: Framework.GetFrameworkName is deprecated, use Framework.GetResourceName instead.")
    return Framework.GetResourceName()
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
    local isAdmin = QBCore.Functions.HasPermission(src, 'admin')
    local isGod = QBCore.Functions.HasPermission(src, 'god')
    local isAceAllowed = IsPlayerAceAllowed(src, 'command')
    return isAdmin or isGod or isAceAllowed
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

---@description Returns the player date of birth.
---@param src number
---@return string|nil
Framework.GetPlayerDob = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
end

---@description Returns a table of items matching the specified name and if passed metadata from the player's inventory.
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
    if not player then return false end
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

--- @description This will get the hunger of a player
--- @param src number
--- @return number
Framework.GetHunger = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0)
    return math.floor((newHunger) + 0.5) or 0
end

---@description This will get the thirst of a player
---@param src any
---@return number | nil
Framework.GetThirst = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
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

---@description Returns the gang name of the player.
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
    --print("[Community Bridge] Warning: Framework.GetPlayerJob is deprecated, use Framework.GetPlayerJobData instead.")
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    return jobData.jobName, jobData.jobLabel, jobData.gradeName, jobData.gradeLevel
end

---@description This will return the players job name, job label, job grade label job grade level, boss status,
---and duty status in a table
---@param src number
---@return table | nil
Framework.GetPlayerJobData = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return { } end
    local playerData = player.PlayerData
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

---@description Returns the players duty status.
---@param src number
---@return boolean | nil
Framework.GetPlayerDuty = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    local playerData = player.PlayerData
    if not playerData.job.onduty then return false end
    return true
end

--- @description This will toggle a players duty status
--- @param src number
--- @param status boolean
--- @return boolean
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
    if not player then return false end
    return player.Functions.SetJob(name, grade)
end

---@description This will add money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    if _type == 'money' then _type = 'cash' end
    if amount <= 0 then return false end
    return player.Functions.AddMoney(_type, amount)
end

---@description This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    if _type == 'money' then _type = 'cash' end
    return player.Functions.RemoveMoney(_type, amount)
end

---@description This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@return string | nil
Framework.GetAccountBalance = function(src, _type)
    local player = Framework.GetPlayer(src)
    if not player then return 0 end
    local playerData = player.PlayerData
    if _type == 'money' then _type = 'cash' end
    return playerData.money[_type]
end

---@description This will add an item, and return true or false based on success
---This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Framework.AddItem = function(src, item, count, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    local success = player.Functions.AddItem(item, count, slot, metadata)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, { action = "add", item = item, count = count, slot = slot, metadata = metadata })
    return success
end

---@description Internal function to search for items with specific metadata in player inventory
---@param src number
---@param metadata table
---@return boolean, number|nil
local function runMetadataSearch(src, metadata)
    local inv = Framework.GetPlayerInventory(src) or {}
    for k, v in pairs(inv) do
        if v.metadata and v.metadata == metadata then
            return true, v.slot
        end
    end
    return false
end

---@description This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Framework.RemoveItem = function(src, item, count, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    if metadata then
        local found, itemSlot = runMetadataSearch(src, metadata)
        if found then
            slot = itemSlot
        end
    end
    local success = player.Functions.RemoveItem(item, count, slot)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, { action = "remove", item = item, count = count, slot = slot, metadata = metadata })
    return success
end

---@description This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.SetMetadata = function(src, item, slot, metadata)
    local player = Framework.GetPlayer(src)
    if not player then return false end
    local success = Framework.RemoveItem(src, item, 1, slot, nil)
    if not success then return false end
    Framework.AddItem(src, item, 1, slot, metadata)
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Framework.GetItemInfo = function(item)
    local itemData = QBCore.Shared.Items[item]
    if not itemData then return {} end
    return {
        name = itemData.name,
        label = itemData.label or itemData.name,
        stack = itemData.unique,
        weight = itemData.weight,
        description = itemData.description,
        image = itemData.image
    }
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
---@param src number
---@param item string
---@param metadata table (optional)
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
---@param requiredCount number (optional)
---@return boolean
Framework.HasItem = function(src, item, requiredCount)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount >= (requiredCount or 1)
end

---@description This wil return the players inventory.
---@param src number
---@return table
Framework.GetPlayerInventory = function(src)
    local player = Framework.GetPlayer(src)
    if not player then return {} end
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

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {name, label, weight, count, metadata, slot, stack, description, image}
Framework.GetItemBySlot = function(src, slot)
    local inventory = Framework.GetPlayerInventory(src)
    if not inventory or #inventory == 0 then return {} end
    for _, v in pairs(inventory) do
        if v.slot == slot then
            local itemInfo = Framework.GetItemInfo(v.name)
            return {v.name, itemInfo.label or v.name, itemInfo.weight or 0, v.count or 0, v.metadata or {}, v.slot, itemInfo.stack or false, itemInfo.description or "No description available", itemInfo.image or nil}
        end
    end
    return {}
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

---@description Returns a table of owned vehicles for the player. format is {id = id, vehicle = model, plate = plate}
---@param src number
---@param plate string
---@return table
Framework.IsVehicleOwnedByPlayer = function(src, plate)
    local citizenId = Framework.GetPlayerIdentifier(src)
    local result = MySQL.Sync.fetchAll("SELECT id, vehicle, plate FROM player_vehicles WHERE citizenid = '" .. citizenId .. "' AND plate = '" .. plate .. "'")
    if not result[1] then return false end

    local id = result[1].id
    local vehicle = result[1].vehicle
    return { id = id, vehicle = vehicle, plate = plate }
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

---@description Event handler for when a player is loaded in QB-Core framework
---@param src number
RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    Framework.AddJobCount(src, jobData.jobName)
end)

---@description Event handler for when a player is unloaded in QB-Core framework
---@param src number
RegisterNetEvent("QBCore:Server:OnPlayerUnload", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

---@description Event handler for when a player's job is updated in QB-Core framework
---@param src number
---@param job table
RegisterNetEvent("QBCore:Server:OnJobUpdate", function(src, job)
    src = src or source
    if not job then return end
    TriggerEvent("community_bridge:Server:OnPlayerJobChange", src, job.name)
end)

---@description Event handler for when a player disconnects from the server
AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

Framework.Commands = {}
---@description Adds a command to the QB-Core framework
---@param name string
---@param help string
---@param arguments table
---@param argsrequired boolean
---@param callback function
---@param permission string
---@param ... any
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission, ...)
end

return Framework