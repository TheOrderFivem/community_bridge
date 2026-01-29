---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-inventory') == 'missing' then return end
if GetResourceState('ox_inventory') ~= 'missing' then return end
if GetResourceState('codem-inventory') ~= 'missing' then return end
if GetResourceState('origen_inventory') ~= 'missing' then return end
local qbInventory = exports['qb-inventory']

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}
Inventory.Old = {}
Inventory.Version = nil
Inventory.ShopData = {}

local function getInventoryNewVersion()
    if tonumber(string.sub(GetResourceMetadata("qb-inventory", "version", 0), 1, 1)) >= 2 then
        Inventory.Version = true
        return
    end
    Inventory.Version = false
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= "community_bridge" then return end
    getInventoryNewVersion()
end)

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "qb-inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    if Inventory.Version then if not qbInventory:CanAddItem(src, item, count) then return false end end
    local success = qbInventory:AddItem(src, item, count, slot, metadata, 'community_bridge')
    if not success then return false end
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

---@description This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    local success = qbInventory:RemoveItem(src, item, count, slot, 'community_bridge')
    if not success then return false end
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = Framework.Shared.Items[item]
    if not itemData then return {} end
    return {
        name = itemData.name,
        label = itemData.label,
        stack = itemData.unique,
        weight = itemData.weight,
        description = itemData.description,
        image = Inventory.GetImagePath(itemData.image or itemData.name)
    }
end

---@description This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return Framework.Shared.Items
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(src, slot)
    local slotData = qbInventory:GetItemBySlot(src, slot)
    if not slotData then return {} end
    return {
        name = slotData.name,
        label = slotData.name,
        weight = slotData.weight,
        slot = slotData.slot,
        count = slotData.amount,
        metadata = slotData.info,
        stack = slotData.unique,
        description = slotData.description
    }
end

---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string "stash", "trunk", "glovebox"
---@param id string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"

    if not Inventory.Version then return Inventory.Old.OpenStash(src, _type, id) end
    return qbInventory:OpenInventory(src, id)
end

---@description This will add items to a stash, and return true or false based on success
---@param id string
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(id, items)
    if type(items) ~= "table" then return false end
    if not Inventory.Version then return Inventory.Old.AddStashItems(id, items) end
    local success = false
    for _, item in pairs(items) do
        success = qbInventory:AddItem(id, item.item, item.count or item.amount, nil, item.metadata or item.info, "community_bridge, adding items to stash")
    end
    return success
end

---@description This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    local fullTrunkId = "trunk-"..identifier
    if not Inventory.Version then return Inventory.Old.AddTrunkItems(fullTrunkId, items) end
    if not qbInventory:GetInventory(fullTrunkId) then
        qbInventory:CreateInventory(fullTrunkId, {label = fullTrunkId, slots = 15, maxweight = 10000})
    end
    Wait(1000)
    for i = 1, #items do
        qbInventory:AddItem(fullTrunkId, items[i].name, items[i].amount or items[i].count, items[i].slot or nil, items[i].info or items[i].metadata or {}, "community_bridge, adding items to trunk")
    end
    return true
end

---@description This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    if not Inventory.Version then return Inventory.Old.ClearStash(id, _type) end
    if _type == "trunk" then
        id = "trunk-"..id
    elseif _type == "glovebox" then
        id = "glovebox-"..id
    end
    local inv = qbInventory:GetInventory(id)
    if not inv then return true end
    qbInventory:ClearStash(id)
    return true
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(src, item, requiredCount)
    return qbInventory:HasItem(src, item, requiredCount or 1)
end

---@description This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    if not Inventory.Version then return Inventory.Old.CanCarryItem(src, item, count) end
    return qbInventory:CanAddItem(src, item, count)
end

---@description This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qb-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qb-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    if not Inventory.Version then return Inventory.Old.UpdatePlate(oldplate, newplate) end
    local gloveboxInv = qbInventory:GetInventory('glovebox-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
    local storedGloveBox = Bridge.Tables.DeepClone(gloveboxInv, nil, nil)
    local trunkInv = qbInventory:GetInventory('trunk-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
    local storedTrunk = Bridge.Tables.DeepClone(trunkInv, nil, nil)
    qbInventory:ClearStash('glovebox-'..oldplate)
    qbInventory:ClearStash('trunk-'..oldplate)
    qbInventory:CreateInventory('glovebox-'..newplate, {label = 'glovebox-'..newplate, slots = storedGloveBox.slots, maxweight = storedGloveBox.maxweight})
    qbInventory:SetInventory('glovebox-'..newplate, storedGloveBox.items, "Community Bridge Moving Items In GloveBox")
    qbInventory:CreateInventory('trunk-'..newplate, {label = 'trunk-'..newplate, slots = storedTrunk.slots, maxweight = storedTrunk.maxweight})
    qbInventory:SetInventory('trunk-'..newplate, storedTrunk.items, "Community Bridge Moving Items In Trunk")
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---@description This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    if not Inventory.Version then return Inventory.Old.OpenShop(src, shopTitle) end
    return qbInventory:OpenShop(src, shopTitle)
end

---@description This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param inventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, inventory, shopCoords, shopGroups)
    if not shopTitle or not inventory then return end
    if Inventory.ShopData[shopTitle] then return true end
    if not Inventory.Version then return Inventory.Old.RegisterShop(shopTitle, inventory, shopCoords, shopGroups) end
    local repackedShopItems = {}
    for _, v in pairs(inventory) do
        table.insert(repackedShopItems, {name = v.name, price = v.price, amount = v.count or v.amount or 1000})
    end
    Inventory.ShopData[shopTitle] = { inventory = repackedShopItems, coords = shopCoords, groups = shopGroups }
    qbInventory:CreateShop({ name = shopTitle, label = shopTitle, coords = shopCoords, items = repackedShopItems, })
end

---@description This will open a players inventory, used for admin purposes and stuff.
---@param src number
---@param target number
Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    assert(target, "OpenPlayerInventory: target is required")
    exports['qb-inventory']:OpenInventory(src, target)
end

Inventory.Old.OpenShop = function(src, shopTitle)
    local shopData = Inventory.ShopData[shopTitle]
    if not shopData then return false end
    TriggerClientEvent("inventory:client:OpenInventory", src, "shop", shopTitle, shopData)
end

Inventory.Old.RegisterShop = function(shopTitle, inventory, shopCoords, shopGroups)
    local shopData = { label = shopTitle, items = {}, slots = 0 }

    for _, v in pairs(inventory) do
        table.insert(shopData.items, { name = v.name, price = v.price, amount = v.count or v.amount or 1000, info = v.metadata or v.info or {}, type = 'item' })
    end

    shopData.slots = #shopData.items
    Inventory.ShopData[shopTitle] = shopData
    print("QB-INVENTORY: You are using an outdated version of qb-inventory, please update to the latest version. Stuff will still work but you are using litterally the most exploitable inventory in fivem.")
end

Inventory.Old.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE inventory_glovebox SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE inventory_trunk SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

Inventory.Old.OpenStash = function(src, _type, id)
    local tbl = Inventory.Stashes[id]
    TriggerClientEvent('community_bridge:client:qb-inventory:openStash', src, id, { weight = tbl.weight or 5000, slots = tbl.slots or 20})
end

Inventory.Old.AddTrunkItems = function(fullTrunkId, items)
    TriggerEvent("inventory:server:addTrunkItems", fullTrunkId, items)
    return true
end

Inventory.Old.AddStashItems = function(id, items)
    return false, print("AddStashItems is not supported with qb-inventory v1")
end

Inventory.Old.ClearStash = function(id, _type)
    return false, print("ClearStash is not supported with qb-inventory v1")
end

Inventory.Old.CanCarryItem = function(src, item, count)
    local oldQbInventoryConfig = Require('config.lua', 'qb-inventory')
    local maxInvWeight = oldQbInventoryConfig.MaxWeight or 100000
    local maxInvSlots = oldQbInventoryConfig.MaxSlots or 30
    local packedWeight = 0
    local addedSlots = 1
    local stackCheck = Inventory.GetItemInfo(item).stack
    local playerInv = Framework.GetPlayerInventory(src)
    if not playerInv then return false end
    for k, v in pairs(playerInv) do
        if v.name then
            local weight = Inventory.GetItemInfo(v.name).weight or 0
            count = count + v.count
            packedWeight = packedWeight + (weight * v.count)
        end
    end
    local slotsUsed = #playerInv
    if not stackCheck then addedSlots = count end
    if slotsUsed + addedSlots > maxInvSlots then return false end
    if packedWeight + (Inventory.GetItemInfo(item).weight or 0) * count > maxInvWeight then return false end
    return true
end

return Inventory