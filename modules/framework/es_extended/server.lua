---@diagnostic disable: duplicate-set-field
if GetResourceState('es_extended') ~= 'started' then return end

-- Currently esx doesn't support gangs natively, so some functions will just print a message.
-- Already in contact with other resource creators to add the important exports to retrieve gang data.
-- Later on we can update this module to support third-party-based gang systems.

Prints = Prints or Require("lib/utility/shared/prints.lua")
Callback = Callback or Require("lib/callback/shared/callback.lua")

ESX = exports.es_extended:getSharedObject()

Framework = Framework or {}

local cachedItemList = nil

--- @description This will return the name of the framework in use
--- @return string
Framework.GetFrameworkName = function()
    return 'es_extended'
end

---This will get the name of the in use resource.
---@return string
Framework.GetResourceName = function()
    return 'es_extended'
end

--- @description This is an internal function, its here to attempt to emulate qbs shared items mainly
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

--- @description This will return if the player is an admin in the framework
--- @param src any
--- @return boolean
Framework.GetIsFrameworkAdmin = function(src)
    if not src then return false end
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local group = xPlayer.getGroup()
    if group == 'admin' or group == 'superadmin' then return true end
    return false
end

--- @description This will get the players birth date
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

--- @description This will return the gangs registered in the framework in a table. Currently ESX Extended does not natively support gangs.
--- @return table in the format "{name = gangName, label = gangLabel, grade = {name = gradeName, level = gradeLevel}}" or empty table
Framework.GetFrameworkGangs = function()
    print("ESX Extended does not natively support gangs. Please use a different framework module for gang support.")
    return {}
end

--- @description This will return the first and last name of the player.
--- @return string|nil, string|nil returns the first and last name of the player
Framework.GetPlayerName = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.variables.firstName, xPlayer.variables.lastName
end

--- @description This will return a table of all logged in players
--- @return table
Framework.GetPlayers = function()
    local players = ESX.GetExtendedPlayers()
    local playerList = {}
    for _, xPlayer in pairs(players) do
        table.insert(playerList, xPlayer.source)
    end
    return playerList
end

--- @description This will return a table of items matching the specified name and if passed metadata from the player's inventory
--- @param src number
--- @param item string
--- @param _ table
--- @return table|nil returns {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
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

--- @param src number
--- @param item string
--- @param _ table
--- @return number returns the count of the item in the players inventory, if not found will return 0.
--- If metadata is passed it will find the matching items count (esx_core does not feature metadata items)
Framework.GetItemCount = function(src, item, _)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getInventoryItem(item).count
end

--- @description This will return true if the player has the item, false otherwise
--- @param src number
--- @param item string
--- @return boolean returns true if the player has the item, false otherwise.
Framework.HasItem = function(src, item)
    local getCount = Framework.GetItemCount(src, item, nil)
    return getCount > 0
end

--- @description This will return the player's inventory as a table
--- @param src number
--- @return table | nil returns the player's inventory as a table in format: {name = v.name, count = v.amount, metadata = v.info, slot = v.slot}
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

--- @description Adds the specified metadata key and number value to the player's data.
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

-- Framework.GetMetadata(src, metadata)
--- @description Gets the specified metadata key to the player's data.
--- @param src number
--- @param metadata string
--- @return any|nil
Framework.GetPlayerMetadata = function(src, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.getMeta(metadata) or false
end

--- @description This will return the specified status column of the player.
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

--- @description This will return a boolean if the player is dead or in last stand
--- @param src number
--- @return boolean|nil
Framework.GetIsPlayerDead = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get("is_dead") or false
end

--- @description This will revive a player, if the player is dead or in last stand
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

--- @description This will get the hunger of a player (ESX we get the percent of the status)
--- @param src number
--- @return number | nil
Framework.GetHunger = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return end
    if type(status) ~= "table" then return end
    for _, entry in ipairs(status) do
        if entry.name == "hunger" then
            return math.floor((entry.percent) + 0.5) or 0
        end
    end
end

--- @description This will get the thirst of a player (ESX we get the percent of the status)
--- @param src any
--- @return number | nil
Framework.GetThirst = function(src)
    local status = Framework.GetStatus(src, "status")
    if not status then return nil end
    if type(status) ~= "table" then return end
    for _, entry in ipairs(status) do
        if entry.name == "thirst" then
            return math.floor((entry.percent) + 0.5) or 0
        end
    end
end

--- @description This will get the phone number of a player
--- @param src number
--- @return string | nil return the phone number of the player
Framework.GetPlayerPhone = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    return xPlayer.get("phone_number")
end

---@deprecated This will return the job name, label, grade name, and grade level of the player.
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

--- @description This will return the players job name, job label, job grade label job grade level,
--- boss status, and duty status in a table
--- @param src number
--- @return table | nil
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

--- @description This will return the players gang name, gang label, gang grade label gang grade level,
--- and boss status in a table or empty table. Currently ESX Extended does not natively support gangs.
--- @param src number
--- @return table | nil
Framework.GetPlayerGangData = function(src)
    print("ESX Extended does not natively support gangs. Please use a different framework module for gang support.")
    return {}
end

--- @description This will return the players duty status, true if on duty false otherwise
--- @param src number
--- @return boolean return the players duty status
Framework.GetPlayerDuty = function(src)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return false end
    local job = xPlayer.getJob()
    if not job.onDuty then return false end
    return true
end

--- @description This will toggle a players duty status
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

--- @description This will get a table of player sources that have the specified job name
--- @param job string
--- @return table
Framework.GetPlayersByJob = function(job)
    return Framework.GetPlayerSourcesByJob(job) or {}
end

--- @description This will get a table of player sources that have the specified gang name
--- @param gang string
--- @return table
Framework.GetPlayersByGang = function(gang)
    return Framework.GetPlayerSourcesByGang(gang) or {}
end


--- @description This will set the player's job to the specified name and grade
--- @param src number
--- @param name string
--- @param grade string
--- @return nil
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

--- @description This will add money based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @param amount number
--- @return boolean | nil
Framework.AddAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    xPlayer.addAccountMoney(_type, amount)
    return true
end

--- @description This will remove money based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @param amount number
--- @return boolean | nil
Framework.RemoveAccountBalance = function(src, _type, amount)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    xPlayer.removeAccountMoney(_type, amount)
    return true
end

--- @description This will get the account balance based on the type of account (money/bank)
--- @param src number
--- @param _type string
--- @return string | nil
Framework.GetAccountBalance = function(src, _type)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    if _type == 'cash' then _type = 'money' end
    return xPlayer.getAccount(_type).money
end

--- @description Adds the specified item to the player's inventory
--- @param src number
--- @param item string
--- @param amount number
--- @param slot number
--- @param metadata table
--- @return boolean | nil
Framework.AddItem = function(src, item, amount, slot, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.addInventoryItem(item, amount)
    return true
end

--- @description Removes the specified item from the player's inventory
--- @param src number
--- @param item string
--- @param amount number
--- @param slot number
--- @param metadata table
---@return boolean | nil
Framework.RemoveItem = function(src, item, amount, slot, metadata)
    local xPlayer = Framework.GetPlayer(src)
    if not xPlayer then return end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

--- @description This will get all owned vehicles for the player
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

--- @description Registers a usable item with a callback function
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

RegisterNetEvent("esx:playerLoaded", function(src)
    src = src or source
    TriggerEvent("community_bridge:Server:OnPlayerLoaded", src)
    local jobData = Framework.GetPlayerJobData(src)
    if not jobData then return end
    Framework.AddJobCount(src, jobData.jobName)
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
