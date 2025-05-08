if GetResourceState('origen_inventory') ~= 'started' then return end

Inventory = Inventory or {}

local origen_inventory = exports.origen_inventory

Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return origen_inventory:AddItem(src, item, count, metadata, slot, true)
end

Inventory.RemoveItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return origen_inventory:removeItem(src, item, count, metadata, slot, true)
end

---comment
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    local count = origen_inventory:getItemCount(src , item)
    return count > 0
end

Inventory.GetItemInfo = function(item)
    local itemData = origen_inventory:Items(item)
    local repackedTable = {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
    }
    return repackedTable or {}
end

Inventory.GetItemCount = function(src, item, metadata)
    if not metadata then
        return origen_inventory:GetItemTotalAmount(src, item)
    else
        local items = origen_inventory:GetInventory(src)
        local count = 0
        for _, itemInfo in pairs(items) do
            if itemInfo.name == item and itemInfo.info == metadata or itemInfo.metadata == metadata then
                count = count + itemInfo.count
            end
        end
        return count
    end
end

Inventory.GetPlayerInventory = function(src)
    local playerItems = origen_inventory:GetInventory(src)
    local repackedTable = {}
    for _, v in pairs(playerItems.inventory) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.count,
            metadata = v.metadata,
            slot = v.slot,
        })
    end
    return repackedTable
end

Inventory.GetItemBySlot = function(src, slot)
    -- This inventory got rid of almost all the great exports they had =(
    local slotData = Inventory.GetInventoryItems(src)
    for _, item in pairs(slotData) do
        if item.slot == slot then
            return {
                name = item.name,
                label = item.name,
                weight = item.weight,
                slot = slot,
                count = item.amount,
                metadata = item.metadata,
                stack = item.unique or false,
                description = item.description
            }
        end
    end
    return {}
end

Inventory.CanCarryItem = function(src, item, count)
    return origen_inventory:CanCarryItems(src, item, count)
end

Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    return origen_inventory:RegisterStash(id, { label = label, slots = slots, weight = weight })
end

Inventory.OpenStash = function(src, id, label, slots, weight, owner, groups, coords)
    return origen_inventory:OpenInventory(src, 'stash', id)
end

Inventory.SetMetadata = function(src, item, slot, metadata)
    Inventory.RemoveItem (src, item, 1, slot, nil)
    Inventory.AddItem(src, item, 1, slot, metadata)
end

Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("origen_inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://origen_inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE gloveboxitems SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE trunkitems SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
    return true
end