if GetResourceState('qbx_core') ~= 'started' then return end

local QBox = exports.qbx_core

Framework = {}

-- Framework.GetPlayerIdentifier(src)
-- Returns the citizen ID of the player.
Framework.GetPlayerIdentifier = function(src)
    local playerData = QBox:GetPlayer(src).PlayerData
    if not playerData then return false end
    return playerData.citizenid
end

-- Framework.GetPlayerName(src)
-- Returns the first and last name of the player.
Framework.GetPlayerName = function(src)
    local playerData = QBox:GetPlayer(src).PlayerData
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

-- Framework.GetItem(src, item, metadata)
-- Returns a table of items matching the specified name and if passed metadata from the player's inventory.
-- returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
Framework.GetItem = function(src, item, metadata)
    local playerInventory = QBox:GetPlayer(src).PlayerData.items
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

-- Framework.GetItemCount(src, item, metadata)
-- Returns the count of items matching the specified name and if passed metadata from the player's inventory.
Framework.GetItemCount = function(src, item, metadata)
    local playerInventory = QBox:GetPlayer(src).PlayerData.items
    local count = 0
    for _, v in pairs(playerInventory) do
        if v.name == item and (not metadata or v.info == metadata) then
            count = count + v.amount
        end
    end
    return count
end

-- Framework.GetPlayerInventory(src)
-- Returns the entire inventory of the player as a table.
-- returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
Framework.GetPlayerInventory = function(src)
    local playerItems = QBox:GetPlayer(src).PlayerData.items
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

-- Framework.SetMetadata(src, metadata, value)
-- Adds the specified metadata key and number value to the player's data.
Framework.SetPlayerMetadata = function(src, metadata, value)
    local player = QBox:GetPlayer(src)
    player.Functions.SetMetaData(metadata, value)
    return true
end

-- Framework.GetMetadata(src, metadata)
-- Gets the specified metadata key to the player's data.
Framework.GetPlayerMetadata = function(src, metadata)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    return playerData.metadata[metadata] or false
end

-- Framework.AddStress(src, value)
-- Adds the specified value to the player's stress level and updates the client HUD.
Framework.AddStress = function(src, value)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newStress = playerData.metadata.stress + value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

-- Framework.RemoveStress(src, value)
-- Removes the specified value from the player's stress level and updates the client HUD.
Framework.RemoveStress = function(src, value)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newStress = (playerData.metadata.stress or 0) - value
    player.Functions.SetMetaData('stress', Math.Clamp(newStress, 0, 100))
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newStress
end

-- Framework.AddHunger(src, value)
-- Adds the specified value from the player's hunger level.
Framework.AddHunger = function(src, value)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0) + value
    player.Functions.SetMetaData('hunger', Math.Clamp(newHunger, 0, 100))
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newHunger
end

-- Framework.AddThirst(src, value)
-- Adds the specified value from the player's thirst level.
Framework.AddThirst = function(src, value)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0) + value
    player.Functions.SetMetaData('thirst', Math.Clamp(newThirst, 0, 100))
    --TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    return newThirst
end

Framework.GetHunger = function(src)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newHunger = (playerData.metadata.hunger or 0)
    return newHunger
end

Framework.GetThirst = function(src)
    local player = QBox:GetPlayer(src)
    local playerData = player.PlayerData
    local newThirst = (playerData.metadata.thirst or 0)
    return newThirst
end

-- Framework.GetPlayerPhone(src)
-- Returns the phone number of the player.
Framework.GetPlayerPhone = function(src)
    local playerData = QBox:GetPlayer(src).PlayerData
    return playerData.charinfo.phone
end

-- Framework.GetPlayerGang(src)
-- Returns the gang name of the player.
Framework.GetPlayerGang = function(src)
    local player = QBox:GetPlayer(src).PlayerData
    return player.gang.name
end

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

-- Framework.GetPlayerJob(src)
-- Returns the job name, label, grade name, and grade level of the player.
Framework.GetPlayerJob = function(src)
    local player = QBox:GetPlayer(src).PlayerData
    return player.job.name, player.job.label, player.job.grade.name, player.job.grade.level
end

-- Framework.SetPlayerJob(src, name, grade)
-- Sets the player's job to the specified name and grade.
Framework.SetPlayerJob = function(src, name, grade)
    local player = QBox:GetPlayer(src)
    return player.Functions.SetJob(name, grade)
end

-- Framework.AddAccountBalance(src, _type, amount)
-- Adds the specified amount to the player's account balance of the specified type.
Framework.AddAccountBalance = function(src, _type, amount)
    local player = QBox:GetPlayer(src)
    if _type == 'money' then _type = 'cash' end
    return player.Functions.AddMoney(_type, amount)
end

-- Framework.RemoveAccountBalance(src, _type, amount)
-- Removes the specified amount from the player's account balance of the specified type.
Framework.RemoveAccountBalance = function(src, _type, amount)
    local player = QBox:GetPlayer(src)
    if _type == 'money' then _type = 'cash' end
    return player.Functions.RemoveMoney(_type, amount)
end

-- Framework.GetAccountBalance(src, _type)
-- Returns the player's account balance of the specified type.
Framework.GetAccountBalance = function(src, _type)
    local playerData = QBox:GetPlayer(src).PlayerData
    if _type == 'money' then _type = 'cash' end
    return playerData.money[_type]
end

-- Framework.AddItem(src, item, amount, slot, metadata)
-- Adds the specified item to the player's inventory.
Framework.AddItem = function(src, item, amount, slot, metadata)
    local player = QBox:GetPlayer(src)
    return player.Functions.AddItem(item, amount, slot, metadata)
end

-- Framework.RemoveItem(src, item, amount, slot, metadata)
-- Removes the specified item from the player's inventory.
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    local player = QBox:GetPlayer(src)
    return player.Functions.RemoveItem(item, amount, slot)
end

-- Framework.SetMetadata(src, item, slot, metadata)
-- Sets the metadata for the specified item in the player's inventory.
-- Notes, this is kinda a jank workaround. with the framework aside from updating the entire table theres not really a better way
Framework.SetMetadata = function(src, item, slot, metadata)
    local player = QBox:GetPlayer(src)
    player.Functions.RemoveItem(item, 1, slot)
    return player.Functions.AddItem(item, 1, slot, metadata)
end

-- Framework.RegisterUsableItem(item, cb)
-- Registers a usable item with a callback function.
Framework.RegisterUsableItem = function(item, cb)
    return QBox:CreateUseableItem(item, cb)
end