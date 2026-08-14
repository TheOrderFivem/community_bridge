--[[

    Get this inventory here https://onestudios.gg/

]]--

---@diagnostic disable: duplicate-set-field
if GetResourceState('one_inventory') == 'missing' then return end
local inv = exports['one_inventory']
Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}
Inventory.Version = nil
Inventory.ShopData = {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "one_inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    local success = inv:AddItem(src, item, count, metadata, slot)

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
    local success = inv:RemoveItem(src, item, count, metadata, slot)

    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return success or false
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = inv:GetItemDefinition(item)
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
    return inv:GetAllItemDefinitions()
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
---@param src number
---@param item string
---@param metadata table (optional)
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    return inv:GetItemCount(src, item, metadata)
end

---@description This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    return inv:GetInventoryItems(src)
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(src, slot)
    local slotData = inv:GetSlot(src, slot)
    if not slotData then return {} end
    return {
        name = slotData.name,
        label = slotData.name,
        weight = slotData.weight,
        slot = slotData.slot,
        count = slotData.amount or slotData.count,
        metadata = slotData.info or slotData.metadata,
        stack = slotData.unique,
        description = slotData.description
    }
end

---@description This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    inv:SetItemMetadata(src, slot, metadata)
end


---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string "stash", "trunk", "glovebox"
---@param id string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash:"
    if _type == "trunk" then
        _type = "vehicle:trunk:"
    elseif _type == "glovebox" then
        _type = "vehicle:glovebox:"
    elseif _type ~= "stash" then
        _type = "stash:"
    end

    return inv:OpenInventory(src, _type, {id = id})
end

---@description This will add items to a stash, and return true or false based on success
---@param id string
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(id, items)
    if type(items) ~= "table" then return false end
    local success = false
    for _, item in pairs(items) do
        success = inv:AddItem(id, item.item, item.amount or item.count, item.metadata or item.info or {}, nil)
    end
    return success
end

---@description This will add items to a trunk, and return true or false based on success
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    local fullTrunkId = "vehicle:trunk:"..identifier
    Wait(1000)
    for i = 1, #items do
        inv:AddItem(fullTrunkId, items[i].name, items[i].amount or items[i].count, items[i].metadata or items[i].info or {}, nil)
    end
    return true
end

---@description This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    if _type == "trunk" then
        id = "vehicle:trunk:"..id
    elseif _type == "glovebox" then
        id = "vehicle:glovebox:"..id
    elseif _type ~= "stash" then
        id = "stash:"..id
    end
    inv:ClearInventory(id, false, false)

    return true
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(src, item, requiredCount)
    return inv:HasItem(src, item, requiredCount or 1, nil)

end

---@description This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return inv:CanCarryItem(src, item, count)
end

---@description This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("one_inventory", string.format("web/images/%s.png", item))
    local imagePath = file and string.format("nui://one_inventory/web/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    inv:UpdateVehiclePlate(oldplate, newplate)
    if GetResourceState('jg-mechanic') == 'missing' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---@description This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    return inv:OpenInventory(src, "shop", shopTitle)
end

---@description This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param inventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, inventory, shopCoords, shopGroups)
    return false, print(shopTitle.." is not a valid shop type for one_inventory, please use the shop types defined in the documentation.")
end

---@description This will open a players inventory, used for admin purposes and stuff.
---@param src number
---@param target number
Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    assert(target, "OpenPlayerInventory: target is required")
    inv:OpenInventory(src, "player:", target)
end

return Inventory
