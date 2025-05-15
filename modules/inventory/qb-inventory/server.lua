---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-inventory') ~= 'started' then return end
local qbInventory = exports['qb-inventory']

Inventory = Inventory or {}

local registeredShops = {}
local v1ShopData = {}

local function getInventoryNewVersion()
    if tonumber(string.sub(GetResourceMetadata("qb-inventory", "version", 0), 1, 1)) >= 2 then return true end
    return false
end

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return exports['qb-inventory']:AddItem(src, item, count, slot, metadata, 'community_bridge')
end

---This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return exports['qb-inventory']:RemoveItem(src, item, count, slot, 'community_bridge')
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
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

---Returns the specified slot data as a table.
---
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
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

---This will open the specified stash for the src passed.
---@param src number
---@param id number||string
---@param label string
---@param slots number
---@param weight number
---@param owner string
---@param groups table
---@param coords table
---@return nil
Inventory.OpenStash = function(src, id, label, slots, weight, owner, groups, coords)
    TriggerClientEvent('community_bridge:client:qb-inventory:openStash', src, id, { weight = weight, slots = slots })
end

---This will register a stash
---@param id number||string
---@param label string
---@param slots number
---@param weight number
---@param owner string
---@param groups table
---@param coords table
---@return boolean
Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    return true
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return qbInventory:HasItem(src, item, 1)
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return true
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qb-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qb-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local newVersion = getInventoryNewVersion()
    if newVersion then
        local gloveboxInv = exports['qb-inventory']:GetInventory('glovebox-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
        local storedGloveBox = Bridge.Tables.DeepClone(gloveboxInv, nil, nil)
        local trunkInv = exports['qb-inventory']:GetInventory('trunk-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
        local storedTrunk = Bridge.Tables.DeepClone(trunkInv, nil, nil)
        exports['qb-inventory']:ClearStash('glovebox-'..oldplate)
        exports['qb-inventory']:ClearStash('trunk-'..oldplate)
        exports['qb-inventory']:CreateInventory('glovebox-'..newplate, {label = 'glovebox-'..newplate, slots = storedGloveBox.slots, maxweight = storedGloveBox.maxweight})
        exports['qb-inventory']:SetInventory('glovebox-'..newplate, storedGloveBox.items, "Community Bridge Moving Items In GloveBox")
        exports['qb-inventory']:CreateInventory('trunk-'..newplate, {label = 'trunk-'..newplate, slots = storedTrunk.slots, maxweight = storedTrunk.maxweight})
        exports['qb-inventory']:SetInventory('trunk-'..newplate, storedTrunk.items, "Community Bridge Moving Items In Trunk")
        return true
    else
        local queries = {
            'UPDATE inventory_glovebox SET plate = @newplate WHERE plate = @oldplate',
            'UPDATE inventory_trunk SET plate = @newplate WHERE plate = @oldplate',
        }
        local values = { newplate = newplate, oldplate = oldplate }
        MySQL.transaction.await(queries, values)
    end
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

-- This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    local newVersion = getInventoryNewVersion()
    if newVersion then
        return exports['qb-inventory']:OpenShop(src, shopTitle)
    else
        local shopData = v1ShopData[shopTitle]
        if not shopData then return false end
        TriggerClientEvent("inventory:client:OpenInventory", src, "shop", shopTitle, shopData)
    end
end

-- This will register a shop, if it already exists it will return true.
-- @param shopTitle string
-- @param shopInventory table
-- @param shopCoords table
-- @param shopGroups table
Inventory.CreateShop = function(src, shopTitle, shopInventory, shopCoords, shopGroups)
    if not shopTitle or not shopInventory or not shopCoords then return end
    if registeredShops[shopTitle] then return true end
    registeredShops[shopTitle] = true
    local newVersion = getInventoryNewVersion()
    if newVersion then
        local repackedShopItems = {}
        for _, v in pairs(shopInventory) do
            table.insert(repackedShopItems, {name = v.name, price = v.price, amount = v.count or 1000})
        end
        exports['qb-inventory']:CreateShop({ name = shopTitle, label = shopTitle, coords = shopCoords, items = repackedShopItems, })
        return true
    else
        local shopData = { label = shopTitle, items = {}, slots = 0 }

        for _, v in pairs(shopInventory) do
            table.insert(shopData.items, { name = v.name, price = v.price, amount = v.count or 1000, info = {}, type = 'item' })
        end

        shopData.slots = #shopData.items
        TriggerClientEvent("inventory:client:OpenInventory", src, "shop", shopTitle, shopData)
        v1ShopData[shopTitle] = shopData
        print("QB-INVENTORY: You are using an outdated version of qb-inventory, please update to the latest version. Stuff will still work but you are using litterally the most exploitable inventory in fivem.")
    end
end

return Inventory