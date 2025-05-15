---@diagnostic disable: duplicate-set-field
if GetResourceState('qs-inventory') ~= 'started' then return end

local quasar = exports['qs-inventory']

Inventory = Inventory or {}

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    if not quasar:CanCarryItem(src, item, count) then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return quasar:AddItem(src, item, count, slot, metadata)
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
    return quasar:RemoveItem(src, item, count, slot, metadata)
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemsData = quasar:GetItemList()
    if not itemsData then return {} end
    local itemData = itemsData[item]
    if not itemData then return {} end
    return {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
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
    return quasar:GetItemTotalAmount(src, item)
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local playerItems = quasar:GetInventory(src)
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.amount,
            metadata = v.info,
            slot = v.slot,
        })
    end
    return repackedTable
end

---Returns the specified slot data as a table.
---
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local playerItems = quasar:GetInventory(src)
    for _, item in pairs(playerItems) do
        if item.slot == slot then
            return {
                name = item.name,
                label = item.label,
                weight = item.weight,
                slot = slot,
                count = item.amount,
                metadata = item.info,
                stack = item.unique or false,
                description = item.description
            }
        end
    end
    return {}
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    return quasar:SetItemMetadata(src, slot, metadata)
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
    TriggerEvent("inventory:server:OpenInventory", "stash", id, { maxweight = weight, slots = slots })
    TriggerClientEvent("inventory:client:SetCurrentStash",src, id)
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
    --exports['qs-inventory']:RegisterStash(src, id, stashSlots, stashWeight) -- this needs to pass source to register, need to plan around this.
    return true
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    local count = quasar:GetItemTotalAmount(src, item)
    if not count then return false end
    return count > 0
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return quasar:CanCarryItem(src, item, count)
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE inventory_trunk SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE inventory_glovebox SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qs-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qs-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

-- This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    print("Currently qs shop is not bridged")
end

-- This will register a shop, if it already exists it will return true.
-- @param shopTitle string
-- @param shopInventory table
-- @param shopCoords table
-- @param shopGroups table
Inventory.CreateShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
    return false, print("Currently qs shop is not bridged")
end

return Inventory