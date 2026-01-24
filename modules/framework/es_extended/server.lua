---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

Prints = Prints or Require("lib/utility/shared/prints.lua")
Callback = Callback or Require("lib/callback/shared/callback.lua")

ESX = exports.es_extended:getSharedObject()

Framework = Framework or {}

local cachedItemList = nil

--- @description This will return the name of the framework in use
--- @return string
Framework.GetFrameworkName = function()
    --print("This is deprecated, please use Framework.GetResourceName() instead.")
    return Framework.GetResourceName()
end

---@description This will get the name of the in use resource.
--- @return string
Framework.GetResourceName = function()
    return 'es_extended'
end

---@description This is an internal function, its here to attempt to emulate qbs shared items mainly, do not use this outside of bridge.
Framework.ItemList = function()
    if cachedItemList then return cachedItemList end
    local items = ESX.Items
    local repackedTable = {}
    for k, v in pairs(items) do
        if v.label then
            repackedTable[k] = {
                name = k,
                label = v.label,
                weight = v.weight,
                type = "item",
                image = k .. ".png",
                unique = false,
                useable = true,
                shouldClose = true,
                description = 'No description provided.',
            }
        end
    end
    cachedItemList = { Items = repackedTable or {} }
    return cachedItemList
end

---@description This will return if the player is an admin in the framework.
---@param src number
---@return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' then return true end
    return false
end

---@description Returns the player date of birth.
--- @param src number
--- @return string|nil
Framework.GetPlayerDob = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    local dob = xPlayer.get("dateofbirth")
    return dob
end

--- @description Returns the player data of the specified source in the framework defualt format
--- @param src any
--- @return table | nil
Framework.GetPlayer = function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    return xPlayer
end

--- @description Returns the citizen ID of the player.
--- @param src number
--- @return string | nil returns the citizen ID of the player if it exists
Framework.GetPlayerIdentifier = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getIdentifier()
end

--- @description This will return the jobs registered in the framework in a table.
--- @return table in the format "{name = jobName, label = jobLabel, grade = {name = gradeName, level = gradeLevel}}"
Framework.GetFrameworkJobs = function()
    return ESX.GetJobs()
end

--- @description This will return the first and last name of the player.
--- @return string|nil, string|nil returns the first and last name of the player
Framework.GetPlayerName = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.variables.firstName, xPlayer.variables.lastName
end

---@description This will return a table of all logged in players
--- @return table
Framework.GetPlayers = function()
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    for _, xPlayer in pairs(players) do
        table.insert(playerList, xPlayer.source)
    end
    return playerList
end

---@description Returns a table of items matching the specified name and if passed metadata from the player's inventory.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param src number
--- @param item string
--- @param metadata table
--- @return table {name, count, metadata, slot}
Framework.GetItem = function(src, item, metadata)
    print("ESX does not support item metadata searches, please ensure you are using a supported inventory system or that you have the correct start order.")
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return {} end
    local playerItems = xPlayer.getInventory()
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        if v.name == item then
            table.insert(repackedTable, {
                name = v.name,
                count = v.count,
                metadata = {}, -- ESX does not support item metadata
                slot = 0, -- ESX does not support item slots
            })
        end
    end
    return repackedTable
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param item string
--- @return table {name, label, stack, weight, description, image}
Framework.GetItemInfo = function(item)
    local items = Framework.ItemList()
    if not items[item] then return {} end
    return {name = item, label = items[item].label, stack = false, weight = items[item].weight, description = items[item].description, image = items[item].image}
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
---@param src number
---@param item string
---@param metadata table (optional)
---@return number
Framework.GetItemCount = function(src, item, metadata)
    if metadata then
        print("ESX does not support item metadata searches, please ensure you are using a supported inventory system or that you have the correct start order.")
    end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return 0 end
    return xPlayer.getInventoryItem(item).count
end

---@description This will return a boolean if the player has the item.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param src number
--- @param item string
--- @return boolean
Framework.HasItem = function(src, item)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount > 0
end

---@description Returns the entire inventory of the player as a table.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
---@param src number
---@return table {name, count, metadata, slot}
Framework.GetPlayerInventory = function(src)
    print("ESX does not support item metadata or slots, please ensure you are using a supported inventory system or that you have the correct start order.")
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return {} end
    local playerItems = xPlayer.getInventory()
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        if v.count > 0 then
            table.insert(repackedTable, {
                name = v.name,
                count = v.count,
                metadata = {}, -- ESX does not support item metadata
                slot = 0, -- ESX does not support item slots
            })
        end
    end
    return repackedTable
end

---@description This will return the item data for the specified slot.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param src number
--- @param slot number
--- @return table {name, label, weight, count, metadata, slot, stack, description}
Framework.GetItemBySlot = function(src, slot)
    print("ESX does not support item slots, please ensure you are using a supported inventory system or that you have the correct start order.")
    return {} -- ESX does not support item slots
end

---@description Adds the specified metadata key and number value to the player's data.
--- @param src number
--- @param metadata string
--- @param value any
--- @return boolean|nil returns true if the metadata was set successfully, otherwise it returns nil
Framework.SetPlayerMetadata = function(src, metadata, value)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.setMeta(metadata, value, nil)
    return true
end

---@description Gets the specified metadata key to the player's data.
--- @param src number
--- @param metadata string
--- @return any|nil
Framework.GetPlayerMetadata = function(src, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getMeta(metadata) or false
end

---@description This is an internal function and should not be used outside of bridge, this is only present in the esx portion.
--- @param src number
--- @param column string
--- @return string|nil
Framework.GetStatus = function(src, column)
    --[[
    defualt esx Available tables are:
        identifier, accounts, group, inventory, job, job_grade, loadout, metadata, position,
        firstname, lastname, dateofbirth, sex, height, skin, status, is_dead, id, disabled,
        last_property, created_at, last_seen, phone_number, pincode
    ]]
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get(column) or nil
end

---@description This will return a boolean if the player is dead or in last stand.
--- @param src number
--- @return boolean
Framework.GetIsPlayerDead = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    return xPlayer.get("is_dead") or false
end

---@description This will revive a player, if the player is dead or in last stand.
--- @param src number
--- @return boolean
Framework.RevivePlayer = function(src)
    src = tonumber(src)
    if not src then return false end
    TriggerEvent('esx_ambulancejob:revive', src)
    return true
end

--- @description Adds the specified value from the player's thirst level
--- @param src number
--- @param value number
--- @return number | nil
Framework.AddThirst = function(src, value)
    local clampIT = Math.Clamp(value, 0, 200000)
    local levelForEsx = clampIT * 2000
    TriggerClientEvent('esx_status:add', src, 'thirst', levelForEsx)
    return levelForEsx
end

--- @description Adds the specified value from the player's hunger level
--- @param src number
--- @param value number
--- @return number | nil
Framework.AddHunger = function(src, value)
    local clampIT = Math.Clamp(value, 0, 200000)
    local levelForEsx = clampIT * 2000
    TriggerClientEvent('esx_status:add', src, 'hunger', levelForEsx)
    return levelForEsx
end

---@description This will get the hunger of a player
--- @param src number
--- @return number
Framework.GetHunger = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return 0 end
    if type(status) ~= "table" then return 0 end
    for _, entry in ipairs(status) do
        if entry.name == "hunger" then
            return math.floor((entry.percent) + 0.5) or 0
        end
    end
end

---@description This will get the thirst of a player
--- @param src any
--- @return number
Framework.GetThirst = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return 0 end
    if type(status) ~= "table" then return 0 end
    for _, entry in ipairs(status) do
        if entry.name == "thirst" then
            return math.floor((entry.percent) + 0.5) or 0
        end
    end
end

---@description Returns the phone number of the player.
--- @param src number
--- @return string | nil
Framework.GetPlayerPhone = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get("phone_number")
end

---@description This will return the job name, label, grade name, and grade level of the player.
---@deprecated
---@param src number
---@return string | nil
---@return string | nil
---@return string | nil
---@return string | nil
Framework.GetPlayerJob = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    local job = xPlayer.getJob()
    return job.name, job.label, job.grade_label, job.grade
end

---@description This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
--- @param src number
--- @return table {jobName, jobLabel, gradeName, gradeLabel, gradeRank, boss, onDuty}
Framework.GetPlayerJobData = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return {} end
    local job = xPlayer.getJob()
    local isBoss = (job.grade_name == "boss")
    return {
        jobName = job.name,
        jobLabel = job.label,
        gradeName = job.grade_name,
        gradeLabel = job.grade_label,
        gradeRank = job.grade,
        boss = isBoss,
        onDuty = job.onduty,
    }
end

---@description Returns the players duty status.
--- @param src number
--- @return boolean
Framework.GetPlayerDuty = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob()
    if not job.onDuty then return false end
    return true
end

---@description This will toggle a players duty status
--- @param src number
--- @param status boolean
--- @return boolean
Framework.SetPlayerDuty = function(src, status)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob()
    if job.name == 'unemployed' then return false end
    xPlayer.setJob(job.name, job.grade, status)
    return true
end

---@description Returns the gang name of the player.
---@param src number
---@return string | nil
Framework.GetPlayerGang = function(src)
    print("ESX does not support gangs, please ensure you are using a supported gang system or that you have the correct start order.")
    return
end

---@description This will get a table of player sources that have the specified job name.
--- @param job string
--- @return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

---@description Sets the player's job to the specified name and grade.
--- @param src number
--- @param name string
--- @param grade string
Framework.SetPlayerJob = function(src, name, grade)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if not ESX.DoesJobExist(name, grade) then
        print("^6 Job Does Not Exsist In Framework :NAME " .. name .. " Grade:" .. grade .. " ^0 ")
        return
    end
    xPlayer.setJob(name, grade, true)
    return true
end

---@description This will add money based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @param amount number
--- @return boolean
Framework.AddAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    if _type == 'cash' then _type = 'money' end
    if amount <= 0 then return false end
    xPlayer.addAccountMoney(_type, amount)
    return true
end

---@description This will remove money based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @param amount number
--- @return boolean
Framework.RemoveAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    if _type == 'cash' then _type = 'money' end
    if amount <= 0 then return false end
    local accountVal = Framework.GetAccountBalance(src, _type)
    if accountVal < amount then return false end
    xPlayer.removeAccountMoney(_type, amount)
    return true
end

---@description This will get money based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @return number
Framework.GetAccountBalance = function(src, _type)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return 0 end
    if _type == 'cash' then _type = 'money' end
    local balance = xPlayer.getAccount(_type).money or 0
    if balance <= 0 then return 0 end
    return balance
end

---@description This will add an item, and return true or false based on success
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Framework.AddItem = function(src, item, count, slot, metadata)
    if slot then print("ESX does not support item slots, please ensure you are using a supported inventory system or that you have the correct start order.") end
    if metadata then print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.") end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    xPlayer.addInventoryItem(item, count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, { action = "add", item = item, count = count, slot = slot, metadata = metadata })
    return true
end

---@description Removes the specified item from the player's inventory.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param src number
--- @param item string
--- @param amount number
--- @param slot number (optional)
--- @param metadata table (optional)
--- @return boolean
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    if slot then
        print("ESX does not support item slots, please ensure you are using a supported inventory system or that you have the correct start order.")
    end
    if metadata then
        print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.")
    end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

---@description Sets the metadata for the specified item in the player's inventory.
--- This is an internal function and should not be used outside of bridge, use the Inventory module instead when dealing with items.
--- @param src number
--- @param item string
--- @param slot number
--- @param metadata table
--- @return boolean
Framework.SetMetadata = function(src, item, slot, metadata)
    print("ESX does not support item metadata, please ensure you are using a supported inventory system or that you have the correct start order.")
    return false
end

---@description This will get all owned vehicles for the player
--- @param src number
--- @return table
Framework.GetOwnedVehicles = function(src)
    local citizenId = Framework.GetPlayerIdentifier(src)
    local result = MySQL.Sync.fetchAll("SELECT vehicle, plate FROM owned_vehicles WHERE owner = '" .. citizenId .. "'")
    local vehicles = {}
    for i = 1, #result do
        local vehicle = result[i].vehicle
        local plate = result[i].plate
        local model = json.decode(vehicle).model
        table.insert(vehicles, { vehicle = model, plate = plate })
    end
    return vehicles
end

---@description Returns a table of owned vehicles for the player. format is {id = id, vehicle = model, plate = plate}
---@param src number
---@param plate string
---@return table
Framework.IsVehicleOwnedByPlayer = function(src, plate)
    local citizenId = Framework.GetPlayerIdentifier(src)
    local result = MySQL.Sync.fetchAll("SELECT id, vehicle, plate FROM owned_vehicles WHERE owner = '" .. citizenId .. "' AND plate = '" .. plate .. "'")
    if not result[1] then return false end

    local id = result[1].id
    local vehicle = result[1].vehicle
    local model = json.decode(vehicle).model
    return { id = id, vehicle = model, plate = plate }
end

---@description Registers a usable item with a callback function.
--- @param itemName string
--- @param cb function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    ESX.RegisterUsableItem(itemName, func)
end

---@description Event handler for when a player is loaded in ESX framework
---@param src number
RegisterNetEvent("esx:playerLoaded", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    Framework.AddJobCount(src, jobData.jobName)
end)

---@description Event handler for when a player logs out in ESX framework
---@param src number
RegisterNetEvent("esx:playerLogout", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

---@description Event handler for when a player's job is updated in ESX framework
---@param src number
---@param job table
---@param lastJob table
RegisterNetEvent("esx:setJob", function(src, job, lastJob)
    src = src or source
    if not job or not lastJob then return end
    TriggerEvent("community_bridge:Server:OnPlayerJobChange", src, job.name)
end)

---@description Event handler for when a player disconnects from the server
AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

---@description Callback to get framework jobs list
---@param source number
Callback.Register('community_bridge:Callback:GetFrameworkJobs', function(source)
    return Framework.GetFrameworkJobs() or {}
end)

---@description This is linked to an internal function, its an attempt to standardize the item list across frameworks.
---@param source number
Callback.Register('community_bridge:Callback:GetFrameworkItems', function(source)
    return Framework.ItemList() or {}
end)

Framework.Commands = {}
---@description Adds a command to the ESX framework
---@param name string
---@param help string
---@param arguments table
---@param argsrequired boolean
---@param callback function
---@param permission string
---@param ... any
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    ESX.RegisterCommand(name, permission, function(xPlayer, args, showError)
        callback(xPlayer, args)
    end, false, {
        help = help,
        arguments = arguments
    })
end

return Framework
