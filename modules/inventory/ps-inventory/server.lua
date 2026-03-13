---@diagnostic disable: duplicate-set-field
if GetResourceState('ps-inventory') == 'missing' then return end
local sloth = exports['ps-inventory']

Inventory = Inventory or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "ps-inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    local success = sloth:AddItem(src, item, count, slot, metadata, 'community_bridge')
    if not success then return false end
    TriggerClientEvent('ps-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

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
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    if metadata then
        local found, itemSlot = runMetadataSearch(src, metadata)
        if found then
            slot = itemSlot
        end
    end
    local success = sloth:RemoveItem(src, item, count, slot, 'community_bridge')
    if not success then return false end
    TriggerClientEvent('ps-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = QBCore.Shared.Items[item]
    if not itemData then return {} end
    return {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.stack or "true",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = Inventory.GetImagePath(item),
    }
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(src, slot)
    local item = sloth:GetItemBySlot(src, slot)
    if not item then return {} end
    return {
        name = item.name,
        label = item.label or item.name,
        weight = item.weight,
        slot = slot,
        count = item.amount,
        metadata = item.info,
        stack = item.unique,
        description = item.description
    }
end

---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string "stash", "trunk", "glovebox"
---@param id string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    sloth:OpenInventory(_type, id, nil, src)
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(src, item, requiredCount)
    return sloth:HasItem(src, item, requiredCount or 1)
end

---@description This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE gloveboxitems SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE trunkitems SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    -- ox standard doesnt return anything so probably shouldnt return so everything else has the same standard. Yeaaaa probably should change this.
    if GetResourceState('jg-mechanic') == 'missing' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---@description This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("ps-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://ps-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    return sloth:OpenShop(src, shopTitle)
end

---@description This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param inventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, inventory, shopCoords, shopGroups)
    assert(shopTitle, "RegisterShop: shopTitle is required")
    assert(inventory, "RegisterShop: shopInventory is required")
    assert(shopCoords, "RegisterShop: shopCoords is required")
    assert(shopGroups, "RegisterShop: shopGroups is required")

    local repackItems = {}
    for k, v in pairs(inventory) do
        table.insert(repackItems, { name = v.name, price = v.price or 1000, amount = v.amount or v.count or 1, slot = k })
    end
    local repackedShopItems = {name = shopTitle, label = shopTitle, coords = shopCoords, items = repackItems, slots = #inventory, }

    sloth:CreateShop(repackedShopItems)
    return true
end

---@description This will open a players inventory, used for admin purposes and stuff.
---@param src number
---@param target number
Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    assert(target, "OpenPlayerInventory: target is required")
    sloth:OpenInventoryById(src, target)
end

return Inventory