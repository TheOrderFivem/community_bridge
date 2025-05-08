if GetResourceState('qs-inventory') ~= 'started' then return end

local quasar = exports['qs-inventory']

Inventory = Inventory or {}

---This will add the item if found and return a boolean on success
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

---This will remove the item if found and return a boolean on success
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

---This will return a number of the items count in the inventory
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    return quasar:GetItemTotalAmount(src, item)
end

---This will return the player inventory in a table following ox_inventory format
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

---This will return a boolean of if the player has the item in the inventory
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    local count = quasar:GetItemTotalAmount(src, item)
    if not count then return false end
    return count > 0
end

---This will return the item data in the inventory based on the slot if not found will return nil
---@param src number
---@param slot number
---@return table | nil
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
    return nil
end

---This will return a boolean if the player can carry the item
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return quasar:CanCarryItem(src, item, count)
end

---@param id string
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

---@param src number
---@param id string
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

---This will return the data to an item
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemsData = quasar:GetItemList()
    if not itemsData then return {} end
    local itemData = itemsData[item]
    if not itemData then return {} end
    local repackedTable = {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
    }
    return repackedTable
end


---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return boolean
Inventory.SetMetadata = function(src, item, slot, metadata)
    return quasar:SetItemMetadata(src, slot, metadata)
end

---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qs-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qs-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

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
    exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
    return true
end