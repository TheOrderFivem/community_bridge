---@diagnostic disable: duplicate-set-field
if GetResourceState('ox_inventory') ~= 'started' then return end

local ox_inventory = exports.ox_inventory
local registeredShops = {}

Inventory = Inventory or {}

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return ox_inventory:AddItem(src, item, count, metadata)
end

---This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return ox_inventory:RemoveItem(src, item, count, metadata, slot)
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = ox_inventory:Items(item)
    if not itemData then return {} end
    return {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.stack or "true",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = string.format("nui://ox_inventory/web/images/%s", itemData.client and itemData.client.image or string.format("%s.png", item)),
    }
end

---This will return the count of the item in the players inventory, if not found will return 0.
---
---if metadata is passed it will find the matching items count.
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    return ox_inventory:GetItemCount(src, item, metadata, false)
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    return ox_inventory:GetInventoryItems(src, false)
end

---Returns the specified slot data as a table.
---
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    return ox_inventory:GetSlot(src, slot)
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    ox_inventory:SetMetadata(src, slot, metadata)
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
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', 'stash_' .. id)
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
    return ox_inventory:RegisterStash(id, label, slots, weight, owner)
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return ox_inventory:GetItemCount(src, item, nil, false) > 0
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return ox_inventory:CanCarryItem(src, item, count)
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    ox_inventory:UpdateVehicle(oldplate, newplate)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("ox_inventory", string.format("web/images/%s.png", item))
    local imagePath = file and string.format("nui://ox_inventory/web/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

-- This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    TriggerClientEvent('ox_inventory:openInventory', src, 'shop', {type = shopTitle})
end

-- This will register a shop, if it already exists it will return true.
-- @param shopTitle string
-- @param shopInventory table
-- @param shopCoords table
-- @param shopGroups table
Inventory.CreateShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
    if registeredShops[shopTitle] then return true end
    registeredShops[shopTitle] = true
    ox_inventory:RegisterShop(shopTitle, { name = shopTitle, inventory = shopInventory, groups = shopGroups, })
    --return Inventory.OpenShop(src, shopTitle)
    return true
end



---UNUSED:
---This will return generic item data from the specified inventory, with the items total count.
---
---format without metadata { count, stack, name, weight, label }
---
---fortmat with metadata { count, stack, name, weight, label, metadata }
---@param src number
---@param item string
---@param metadata table
---@return table
Inventory.GetItem = function(src, item, metadata)
    return ox_inventory:GetItem(src, item, metadata, false)
end

return Inventory