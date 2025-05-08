---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_core') ~= 'started' then return end

local QBox = exports.qbx_core

Framework = {}

---Returns the name of the framework being used (if a supported framework).
---@return string
Framework.GetFrameworkName = function()
    return 'qbx_core'
end

---Returns the player date of birth.
---@param src number
---@return string
Framework.GetPlayerDob = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.birthdate
end

---Returns a table of the jobs in the framework.
---@return table
Framework.GetFrameworkJobs = function()
    return QBox.GetJobs()
end

---Returns the citizen ID of the player.
---@param src number
---@return string | boolean
Framework.GetPlayerIdentifier = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if not playerData then return false end
    return playerData.citizenid
end

---This will return a table of all logged in players
---@return table
Framework.GetPlayers = function()
    local players = QBox:GetQBPlayers()
    local playerList = {}
    for src, _ in pairs(players) do
        table.insert(playerList, src)
    end
    return playerList
end

---Returns the first and last name of the player.
---@param src number
---@return string | nil
Framework.GetPlayerName = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

-- Returns a table of items matching the specified name and if passed metadata from the player's inventory.
---@param src number
---@param item string
---@param metadata table
---@return table
Framework.GetItem = function(src, item, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerInventory = player.PlayerData.items
    local repackedTable = {}
    for _, v in pairs(playerInventory) do
        if v.name == item and (not metadata or v.info == metadata) then
            table.insert(repackedTable, {
                name = v.name,
                count = v.amount,
                metadata = v.info,
                slot = v.slot,
            })
        end
    end
    return repackedTable
end

---Returns the count of items matching the specified name and if passed metadata from the player's inventory.
---@param src number
---@param item string
---@param metadata table
---@return number
Framework.GetItemCount = function(src, item, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerInventory = player.PlayerData.items
    local count = 0
    for _, v in pairs(playerInventory) do
        if v.name == item and (not metadata or v.info == metadata) then
            count = count + v.amount
        end
    end
    return count
end

---Returns boolean if the player has the specified item in their inventory.
---@param src number
---@param item string
---@return boolean
Framework.HasItem = function(src, item)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount > 0
end

---Returns the entire inventory of the player as a table.
---@param src number
---@return table
Framework.GetPlayerInventory = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerItems = player.PlayerData.items
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.amount,
            metadata = v.metadata,
            slot = v.slot,
        })
    end
    return repackedTable
end

---Adds the specified metadata key and number value to the player's data.
---@param src number
---@param metadata string
---@param value string
---@return boolean
Framework.SetPlayerMetadata = function(src, metadata, value)
    local player = QBox:GetPlayer(src)
    if not player then return end
    player.Functions.SetMetaData(metadata, value)
    return true
end

---Gets the specified metadata key to the player's data.
---@param src number
---@param metadata string
---@return string | boolean | nil
Framework.GetPlayerMetadata = function(src, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.metadata[metadata] or false
end

---Adds the specified value to the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.AddStress = function(src, value)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newStress = playerData.metadata.stress + value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---Removes the specified value from the player's stress level and updates the client HUD.
---@param src number
---@param value number
---@return number | nil
Framework.RemoveStress = function(src, value)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newStress = (playerData.metadata.stress or 0) - value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

---Adds the specified value from the player's hunger level.
---@param src number
---@param value number
---@return number | nil
Framework.AddHunger = function(src, value)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0) + value
    player.Functions.SetMetaData('hunger', Math.Clamp(newHunger, 0, 100))
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newHunger
end

-- Adds the specified value from the player's thirst level.
---@param src number
---@param value number
---@return number | nil
Framework.AddThirst = function(src, value)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0) + value
    player.Functions.SetMetaData('thirst', Math.Clamp(newThirst, 0, 100))
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newThirst
end

---This will return the players hunger level.
---@param src number
---@return number | nil
Framework.GetHunger = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0)
    return newHunger
end

Framework.GetIsPlayerDead = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.metadata.isdead or false
end

---This will return the players thirst level.
---@param src number
---@return number
Framework.GetThirst = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0)
    return newThirst
end

---Returns the phone number of the player.
---@param src number
---@return string | nil
Framework.GetPlayerPhone = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    return playerData.charinfo.phone
end

---Returns the gang name of the player.
---@param src number
---@return string | nil
Framework.GetPlayerGang = function(src)
    local player = QBox:GetPlayer(src).PlayerData
    return player.gang.name
end

---This will return a table of all players with the specified job.
---@param job string
---@return table
Framework.GetPlayersByJob = function(job)
    local playerList = {}
    local players = QBox:GetQBPlayers()
    for src, player in pairs(players) do
        if player.PlayerData.job.name == job then
            table.insert(playerList, src)
        end
    end
    return playerList
end

---Returns the job name, label, grade name, and grade level of the player.
---@param src number
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
---@return string | string | string | number | nil
Framework.GetPlayerJob = function(src)
    local player = QBox:GetPlayer(src).PlayerData
    if not player then return end
    return player.job.name, player.job.label, player.job.grade.name, player.job.grade.level
end

---Sets the player's job to the specified name and grade.
---@param src number
---@param name string
---@param grade string
---@return boolean | nil
Framework.SetPlayerJob = function(src, name, grade)
    local player = QBox:GetPlayer(src)
    if not player then return end
    return player.Functions.SetJob(name, grade)
end

---This will toggle the duty status of the player.
---@param src number
---@param status boolean
Framework.SetPlayerDuty = function(src, status)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    QBox:SetJobDuty(playerData.citizenid, status)
    TriggerEvent('QBCore:Server:SetDuty', src, player.PlayerData.job.onduty)
end

---Returns the players duty status.
---@param src number
---@return boolean | nil
Framework.GetPlayerDuty = function(src)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if not playerData.job.onduty then return false end
    return true
end

---Adds the specified amount to the player's account balance of the specified type.
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local player = QBox:GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    return player.Functions.AddMoney(_type, amount)
end

---Removes the specified amount from the player's account balance of the specified type.
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local player = QBox:GetPlayer(src)
    if not player then return end
    if _type == 'money' then _type = 'cash' end
    return player.Functions.RemoveMoney(_type, amount)
end

---Returns the player's account balance of the specified type.
---@param src number
---@param _type string
---@return number | nil
Framework.GetAccountBalance = function(src, _type)
    local player = QBox:GetPlayer(src)
    if not player then return end
    local playerData = player.PlayerData
    if _type == 'money' then _type = 'cash' end
    return playerData.money[_type]
end

---Adds the specified item to the player's inventory.
---@param src number
---@param item string
---@param amount number
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.AddItem = function(src, item, amount, slot, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = amount, slot = slot, metadata = metadata})
    return player.Functions.AddItem(item, amount, slot, metadata)
end

---Removes the specified item from the player's inventory.
---@param src number
---@param item string
---@param amount number
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = amount, slot = slot, metadata = metadata})
    return player.Functions.RemoveItem(item, amount, slot)
end

---Sets the metadata for the specified item in the player's inventory.
-----@param src number
---@param item string
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.SetMetadata = function(src, item, slot, metadata)
    local player = QBox:GetPlayer(src)
    if not player then return end
    player.Functions.RemoveItem(item, 1, slot)
    return player.Functions.AddItem(item, 1, slot, metadata)
end

---Returns a table of owned vehicles for the player. format is {vehicle = vehicle, plate = plate}
---@param src number
---@return table
Framework.GetOwnedVehicles = function(src)
    local citizenId = Framework.GetPlayerIdentifier(src)
    local result = MySQL.Sync.fetchAll("SELECT vehicle, plate FROM player_vehicles WHERE citizenid = '" .. citizenId .. "'")
    local vehicles = {}
    for i=1, #result do
        local vehicle = result[i].vehicle
        local plate = result[i].plate
        table.insert(vehicles, {vehicle = vehicle, plate = plate})
    end
    return vehicles
end

---Registers a usable item with a callback function.
---@param itemName string
---@param cb function
---@return function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    return QBox:CreateUseableItem(itemName, func)
end

RegisterNetEvent("QBCore:Server:OnPlayerLoaded", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
end)

RegisterNetEvent("QBCore:Server:OnPlayerUnload", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)