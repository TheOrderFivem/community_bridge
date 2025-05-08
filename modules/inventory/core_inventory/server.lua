if GetResourceState('core_inventory') ~= 'started' then return end

Inventory = Inventory or {}

local core = exports.core_inventory

---comment
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("core_inventory", string.format("html/img/%s.png", item))
    local imagePath = file and string.format("nui://core_inventory/html/img/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    local itemsAdd = core:addItem(src, item, count, metadata)
    return itemsAdd
end

Inventory.GetPlayerInventory = function(src)
    local playerItems = core:getInventory(src)
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.count,
            metadata = v.metadata,
            slot = v.id,
        })
    end
    return repackedTable
end

Inventory.RemoveItem = function(src, item, count, slot, metadata)
    if not slot and metadata then
        local inv = Inventory.GetPlayerInventory(src)
        if not inv then return false end
        for _, v in pairs(inv) do
            if v.name == item and v.metadata == metadata then
                slot = v.slot
                break
            end
        end
    end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    if slot then
        local identifier = Framework.GetPlayerIdentifier(src)
        if not identifier then return false end
        local framework = Bridge.Framework.GetFrameworkName()
        if framework == 'es_extended' then
            identifier = string.gsub(identifier, ":", "")
        end
        local weirdInventoryName = 'content-' .. identifier
        return core:removeItemExact(weirdInventoryName, slot, count)
    end
    core:removeItem(src, item, count)
    return true
    -- I hate this inventory so much, I am so sorry for this.
end

---This will get the item from the specified slot.
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local inv = Inventory.GetPlayerInventory(src)
    if not inv then return {} end
    for _, v in pairs(inv) do
        print(v.slot, slot)
        if v.slot == slot then
            return {
                name = v.name,
                count = v.count,
                metadata = v.metadata,
                slot = v.slot,
            }
        end
    end
    return {}
end

---Returns the total count of an item in the inventory.
---@param src number
---@param item string
---@param metadata table
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    if metadata then
        local inv = Inventory.GetPlayerInventory(src)
        local deepCount = 0
        if not inv then return 0 end
        for _, v in pairs(inv) do
            if v.name == item and v.metadata == metadata then
                deepCount = deepCount + v.count
            end
        end
        return deepCount
    end
    local count = core:getItemCount(src, item)
    return count or 0
end

---Returns boolean if the player has the item in their inventory.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    local count = core:getItemCount(src, item)
    return count > 0
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    core:setMetadata(src, slot, metadata)
end

---comment
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    -- have no clue if this will work but fingers crossed
    local queries = {
        'UPDATE coreinventories SET name = @newplate WHERE name = @oldplate',
        'UPDATE coreinventories SET name = @newplate WHERE name = @glovebox_oldplate',
        'UPDATE coreinventories SET name = @newplate WHERE name = @trunk_oldplate',
    }
    local values = {
        newplate = newplate,
        oldplate = oldplate,
        glovebox_oldplate = 'glovebox-' .. oldplate,
        trunk_oldplate = 'trunk-' .. oldplate
    }
    MySQL.transaction.await(queries, values)
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
    return true
end

lib.callback.register('community_bridge:Callback:core_inventory', function(source)
    local items = core:getItemsList()
	return items or {}
end)