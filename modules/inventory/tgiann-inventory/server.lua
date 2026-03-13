---@diagnostic disable: duplicate-set-field
if GetResourceState('tgiann-inventory') == 'missing' then return end

local tgiann = exports["tgiann-inventory"]

Inventory = Inventory or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "tgiann-inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    if not tgiann:CanCarryItem(src, item, count) then return false end
    local success = tgiann:AddItem(src, item, count, slot, metadata, false)
    if not success then return false end
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
    local success = tgiann:RemoveItem(src, item, count, slot, metadata)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = tgiann:GetItemList()
    if not itemData[item] then return {} end
    return {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
    }
end

---@description This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return tgiann:GetItemList()
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
---@param src number
---@param item string
---@param metadata table (optional)
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    local _item = tgiann:GetItemByName(src, item, metadata)
    return _item.amount or 0
end

---@description This will return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    local inventory = tgiann:GetPlayerItems(src)
    local items = {}
    for _, v in pairs(inventory) do
        if tonumber(_) then
            table.insert(items, {name = v.name, label = v.name, weight = 0, description = v.description, slot = v.slot, count = v.amount, metadata = v.info})
        end
    end
    return items
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(src, slot)
    local item = tgiann:GetItemBySlot(src, slot)
    if not item then return {} end
    return {
        name = item.name,
        label = item.label,
        weight = item.weight,
        slot = slot,
        count = item.amount or item.count,
        metadata = item.info or item.metadata or {},
        stack = item.unique or item.stack or false,
        description = item.description
    }
end

---@description This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    tgiann:UpdateItemMetadata(src, item, slot, metadata)
end

---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id] or {weight = 1000000, slot = 50, label = "Stash"}
    return tgiann:ForceOpenInventory(src, _type, id, tbl and { maxWeight = tbl.weight , slots = tbl.slot, label = tbl.label})
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@return boolean
Inventory.HasItem = function(src, item)
    return tgiann:HasItem(src, item, 1)
end

---@description This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return tgiann:CanCarryItem(src, item, count)
end

---@description This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local queries = {
        'UPDATE tgiann_inventory_trunkitems SET plate = @newplate WHERE plate = @oldplate',
        'UPDATE tgiann_inventory_gloveboxitems SET plate = @newplate WHERE plate = @oldplate',
    }
    local values = { newplate = newplate, oldplate = oldplate }
    MySQL.transaction.await(queries, values)
    tgiann:UpdateVehicle(oldplate, newplate)
    if GetResourceState('jg-mechanic') == 'missing' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---@description This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    local id = "trunk"..identifier
    if type(items) ~= "table" then return false end
    for _, v in pairs(items) do
        tgiann:AddItemToSecondaryInventory("trunk", identifier, v.item, v.count, nil, v.metadata)
    end
    return true
end

---@description This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    tgiann:DeleteInventory(_type, id)
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return true
end

---@description This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    local pngItem = Inventory.StripPNG(item)
    local webpItem = Inventory.StripWebp(item)
    local pngPath = LoadResourceFile("inventory_images", string.format("/images/%s.png", pngItem))
    local webpPath = LoadResourceFile("inventory_images", string.format("/images/%s.webp", webpItem))
    local imagePath = pngPath and string.format("nui://inventory_images/images/%s.png", pngItem) or webpPath and string.format("nui://inventory_images/images/%s.webp", webpItem)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will open a players inventory, used for admin purposes and stuff.
---@param src number
---@param target number
Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    assert(target, "OpenPlayerInventory: target is required")
    tgiann:OpenInventoryById(src, target)
end

return Inventory