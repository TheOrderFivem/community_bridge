---@diagnostic disable: duplicate-set-field
if GetResourceState('codem-inventory') ~= 'started' then return end

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

local codem = exports['codem-inventory']

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return codem:AddItem(src, item, count, slot, metadata)
end

---This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "codem-inventory"
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
    return codem:RemoveItem(src, item, count, slot)
end

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return codem:GetItemList() or {}
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = Inventory.Items()
    if not itemData or not itemData[item] then return {} end
    return {
        name = itemData[item].name or "Missing Name",
        label = itemData[item].label or "Missing Label",
        stack = itemData[item].unique or "false",
        weight = itemData[item].weight or "0",
        description = itemData[item].description or "none",
        image = itemData[item].image or Inventory.GetImagePath(item),
    }
end

---This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local identifier = Framework.GetPlayerIdentifier(src)
    local playerItems = codem:GetInventory(identifier, src)
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
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local slotData = codem:GetItemBySlot(src, slot)
    if not slotData then return {} end
    return {
        name = slotData.name,
        label = slotData.label or slotData.name,
        weight = slotData.weight,
        slot = slotData.slot,
        count = slotData.amount or slotData.count,
        metadata = slotData.info or slotData.metadata,
        stack = slotData.unique,
        description = slotData.description
    }
end

---This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    return codem:SetItemMetadata(src, slot, metadata)
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]
    TriggerClientEvent('community_bridge:client:codem-inventory:openStash', src, id, { label = tbl.label, slots = tbl.slots, weight = tbl.weight })
end


---This will register a stash
---@param id number|string
---@param label string
---@param slots number
---@param weight number
---@param owner string
---@param groups table
---@param coords table
---@return boolean
---@return string|number
Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    if Inventory.Stashes[id] then return true, id end
    Inventory.Stashes[id] = {
        id = id,
        label = label,
        slots = slots,
        weight = weight,
        owner = owner,
        groups = groups,
        coords = coords
    }
    return true, id
end

---This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return codem:HasItem(src, item, 1)
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return true
end

---This will add items to a trunk, and return true or false based on success
---If a trunk with the identifier does not exist, it will create one with default values.
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    return false, print("AddItemsToTrunk is not implemented in codem-inventory, because of this we dont have a way to add items to a trunk.")
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return false, print("ClearInventory is not implemented in codem-inventory, because of this we dont have a way to clear a stash.")
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    return false, print("Unable to update plate for codem-inventory, I do not have access to a copy of this inventory to bridge the feature.")
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("codem-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://codem-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    if not target then
        target = src
    end
    exports['codem-inventory']:OpenInventory(src, target)
end


return Inventory