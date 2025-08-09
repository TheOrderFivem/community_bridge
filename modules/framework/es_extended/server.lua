---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

Prints = Prints or Require("lib/utility/shared/prints.lua")
Callback = Callback or Require("lib/utility/shared/callbacks.lua")

ESX = exports["es_extended"]:getSharedObject()

Framework = Framework or {}

local cachedItemList = nil

---This will return the name of the framework in use.
---@return string
Framework.GetFrameworkName = function()
    return 'es_extended'
end

-- This is an internal function, its here to attempt to emulate qbs shared items mainly.
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

---This will return if the player is an admin in the framework.
---@param src any
---@return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' then return true end
    return false
end

---This will get the players birth date
---@return string|nil
Framework.GetPlayerDob = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    local dob = xPlayer.get("dateofbirth")
    return dob
end

--- Returns the player data of the specified source in the framework defualt format.
---@param src any
---@return table | nil
Framework.GetPlayer = function(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    return xPlayer
end

-- Framework.GetPlayerIdentifier(src)
-- Returns the citizen ID of the player.
---@param src number
---@return string | nil
Framework.GetPlayerIdentifier = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getIdentifier()
end

---This will return the jobs registered in the framework in a table.
---Format of the table is:
---{name = jobName, label = jobLabel, grade = {name = gradeName, level = gradeLevel}}
---@return table
Framework.GetFrameworkJobs = function()
    return ESX.GetJobs()
end
-- Framework.GetPlayerName(src)
-- Returns the first and last name of the player.
---@return string|nil, string|nil
Framework.GetPlayerName = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.variables.firstName, xPlayer.variables.lastName
end

---This will return a table of all logged in players
---@return table
Framework.GetPlayers = function()
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    for _, xPlayer in pairs(players) do
        table.insert(playerList, xPlayer.source)
    end
    return playerList
end

---Returns a table of items matching the specified name and if passed metadata from the player's inventory.
---returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
---@param src number
---@param item string
---@param _ table
---@return table|nil
Framework.GetItem = function(src, item, _)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    local playerItems = xPlayer.getInventory()
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        if v.name == item then
            table.insert(repackedTable, {
                name = v.name,
                count = v.count,
                --metadata = v.metadata,
                --slot = v.slot,
            })
        end
    end
    return repackedTable
end

---This will return the count of the item in the players inventory, if not found will return 0.
---if metadata is passed it will find the matching items count (esx_core does not feature metadata items).
---@param src number
---@param item string
---@param _ table
---@return number
Framework.GetItemCount = function(src, item, _)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getInventoryItem(item).count
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Framework.HasItem = function(src, item)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount > 0
end

-- Framework.GetPlayerInventory(src)
-- Returns the entire inventory of the player as a table.
-- returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
---@param src number
---@return table | nil
Framework.GetPlayerInventory = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    local playerItems = xPlayer.getInventory()
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        if v.count > 0 then
            table.insert(repackedTable, {
                name = v.name,
                count = v.count,
                --metadata = v.metadata,
                --slot = v.slot,
            })
        end
    end
    return repackedTable
end

-- Framework.SetMetadata(src, metadata, value)
-- Adds the specified metadata key and number value to the player's data.
---@return boolean|nil
Framework.SetPlayerMetadata = function(src, metadata, value)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.setMeta(metadata, value, nil)
    return true
end

-- Framework.GetMetadata(src, metadata)
-- Gets the specified metadata key to the player's data.
---@param src number
---@param metadata string
---@return any|nil
Framework.GetPlayerMetadata = function(src, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getMeta(metadata) or false
end

-- defualt esx Available tables are
-- identifier, accounts, group, inventory, job, job_grade, loadout,
-- metadata, position, firstname, lastname, dateofbirth, sex, height,
-- skin, status, is_dead, id, disabled, last_property, created_at, last_seen,
-- phone_number, pincode
Framework.GetStatus = function(src, column)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get(column) or nil
end

---This will return a boolean if the player is dead or in last stand.
---@param src number
---@return boolean|nil
Framework.GetIsPlayerDead = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get("is_dead") or false
end

---This will revive a player, if the player is dead or in last stand.
---@param src number
---@return boolean
Framework.RevivePlayer = function(src)
    src = tonumber(src)
    if not src then return false end
    TriggerEvent('esx_ambulancejob:revive', src)
    return true
end

-- Framework.AddThirst(src, value)
-- Adds the specified value from the player's thirst level.
---@param src number
---@param value number
---@return number | nil
Framework.AddThirst = function(src, value)
    local clampIT = Math.Clamp(value, 0, 200000)
    local levelForEsx = clampIT * 2000
    TriggerClientEvent('esx_status:add', src, 'thirst', levelForEsx)
    return levelForEsx
end

-- Framework.AddHunger(src, value)
-- Adds the specified value from the player's hunger level.
---@param src number
---@param value number
---@return number | nil
Framework.AddHunger = function(src, value)
    local clampIT = Math.Clamp(value, 0, 200000)
    local levelForEsx = clampIT * 2000
    TriggerClientEvent('esx_status:add', src, 'hunger', levelForEsx)
    return levelForEsx
end

---This will get the hunger of a player
---@param src number
---@return number | nil
Framework.GetHunger = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return 0 end
    return status.hunger
end

---This will get the thirst of a player
---@param src any
---@return number | nil
Framework.GetThirst = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return 0 end
    return status.thirst
end

-- Framework.GetPlayerPhone(src)
-- Returns the phone number of the player.
---@param src number
---@return string | nil
Framework.GetPlayerPhone = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get("phone_number")
end


---Depricated: Returns the job name, label, grade name, and grade level of the player.
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

---This will return the players job name, job label, job grade label job grade level, boss status, and duty status in a table
---@param src number
---@return table | nil
Framework.GetPlayerJobData = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
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

---Returns the players duty status.
---@param src number
---@return boolean
Framework.GetPlayerDuty = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob()
    if not job.onDuty then return false end
    return true
end

---This will toggle a players duty status
---@param src number
---@param status boolean
---@return boolean
Framework.SetPlayerDuty = function(src, status)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob()
    if job.jobName == 'unemployed' then return false end
    xPlayer.setJob(job.name, job.grade, status)
    return true
end

---This will get a table of player sources that have the specified job name.
---@param job string
---@return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

-- Sets the player's job to the specified name and grade.
---@param src number
---@param name string
---@param grade string
---@return nil
Framework.SetPlayerJob = function(src, name, grade)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if not ESX.DoesJobExist(name, grade) then
        Prints.Error("Job Does Not Exsist In Framework :NAME " .. name .. " Grade:" .. grade)
        return
    end
    xPlayer.setJob(name, grade, true)
    return true
end

---This will add money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    xPlayer.addAccountMoney(_type, amount)
    return true
end

---This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@param amount number
---@return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    xPlayer.removeAccountMoney(_type, amount)
    return true
end

---This will remove money based on the type of account (money/bank)
---@param src number
---@param _type string
---@return string | nil
Framework.GetAccountBalance = function(src, _type)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    return xPlayer.getAccount(_type).money
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
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.addInventoryItem(item, amount)
    return true
end

-- Framework.RemoveItem(src, item, amount, slot, metadata)
-- Removes the specified item from the player's inventory.
---@param src number
---@param item string
---@param amount number
---@param slot number
---@param metadata table
---@return boolean | nil
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

---This will get all owned vehicles for the player
---@param src number
---@return table
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


-- Framework.RegisterUsableItem(item, cb)
-- Registers a usable item with a callback function.
---@param itemName string
---@param cb function
Framework.RegisterUsableItem = function(itemName, cb)
    local func = function(src, item, itemData)
        itemData = itemData or item
        itemData.metadata = itemData.metadata or itemData.info or {}
        itemData.slot = itemData.id or itemData.slot
        cb(src, itemData)
    end
    ESX.RegisterUsableItem(itemName, func)
end

RegisterNetEvent("esx:playerLoaded", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
end)

RegisterNetEvent("esx:playerLogout", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

RegisterNetEvent("esx:setJob", function(src, job, lastJob)
    src = src or source
    if not job or not lastJob then return end
    TriggerEvent("community_bridge:Server:OnPlayerJobChange", src, job.name)
end)

AddEventHandler("playerDropped", function()
    local src = source
    TriggerEvent("community_bridge:Server:OnPlayerUnload", src)
end)

Callback.Register('community_bridge:Callback:GetFrameworkJobs', function(source)
    return Framework.GetFrameworkJobs() or {}
end)

-- This is linked to an internal function, its an attempt to standardize the item list across frameworks.
Callback.Register('community_bridge:Callback:GetFrameworkItems', function(source)
    return Framework.ItemList() or {}
end)

Framework.Commands = {}
Framework.Commands.Add = function(name, help, arguments, argsrequired, callback, permission, ...)
    ESX.RegisterCommand(name, permission, function(xPlayer, args, showError)
        callback(xPlayer, args)
    end, false, {
        help = help,
        arguments = arguments
    })
end

return Framework
