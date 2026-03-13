---@diagnostic disable: duplicate-set-field
if GetResourceState('ox_inventory') == 'missing' then return end
if GetResourceState('tgiann-inventory') ~= 'missing' then return end
if GetResourceState('qs-inventory') ~= 'missing' then return end
if GetResourceState('origen_inventory') ~= 'missing' then return end
--check for providers =/

local ox_inventory = exports.ox_inventory
Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "ox_inventory"
end

---@description This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    if not ox_inventory:CanCarryItem(src, item, count, metadata) then return false end
    local success = ox_inventory:AddItem(src, item, count, metadata)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return success
end

---@description This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number (optional)
---@param metadata table (optional)
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    local success = ox_inventory:RemoveItem(src, item, count, metadata, slot)
    if not success then return false end
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return success
end

---@description This will return a table with the item info, {name, label, stack, weight, description, image}
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

---@description This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return ox_inventory:Items()
end

---@description This will return the count of the item in the players inventory, if not found will return 0.
---@param src number
---@param item string
---@param metadata table (optional)
---@return number
Inventory.GetItemCount = function(src, item, metadata)
    return ox_inventory:GetItemCount(src, item, metadata, false)
end

---@description This wil return the players inventory.
---@param src number
---@return table
Inventory.GetPlayerInventory = function(src)
    return ox_inventory:GetInventoryItems(src, false)
end

---@description Returns the specified slot data as a table.
---@param src number
---@param slot number
---@return table {weight, name, metadata, slot, label, count}
Inventory.GetItemBySlot = function(src, slot)
    return ox_inventory:GetSlot(src, slot)
end

---@description This will set the metadata of an item in the inventory.
---@param src number
---@param item string
---@param slot number
---@param metadata table
---@return nil
Inventory.SetMetadata = function(src, item, slot, metadata)
    ox_inventory:SetMetadata(src, slot, metadata)
end

---@description This will register a stash
---@param id number|string
---@param label string
---@param slots number
---@param weight number
---@param owner string (optional)
---@param groups table (optional)
---@param coords table (optional)
---@return boolean
---@return string|number
Inventory.RegisterStash = function(id, label, slots, weight, owner, groups, coords)
    id = tostring(id)
    -- ox standard doesnt return anything so probably shouldnt return so everything else has the same standard. Id is pointless if its a param already. Yeaaaa probably should change this.
    if Inventory.Stashes[id] then return true, id end
    Inventory.Stashes[id] = {id = id, label = label, slots = slots, weight = weight, owner = owner, groups = groups, coords = coords}
    ox_inventory:RegisterStash(id, label, slots, weight, owner, groups, coords)
    return true, id
end

---@description This will open the specified stash for the src passed.
---@param src number
---@param _type string "stash", "trunk", "glovebox"
---@param id string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    ox_inventory:forceOpenInventory(src, _type, id)
end

---@description This will add items to a stash, and return true or false based on success
---@param id string
---@param items table {item, count, metadata}
---@return boolean
Inventory.AddStashItems = function(id, items)
    if type(items) ~= "table" then return false end
    local success = false
    for _, v in pairs(items) do
        success = ox_inventory:AddItem(id, v.item, v.count or v.amount, v.metadata or v.info or {})
    end
    return success
end

---@description This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@param _type string unused with ox_inventory
---@return boolean
Inventory.ClearStash = function(id, _type)
    id = tostring(id)
    ox_inventory:ClearInventory(id)
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    -- ox standard doesnt return anything so probably shouldnt return so everything else has the same standard. Yeaaaa probably should change this.
    return true
end

---@description This will return a boolean if the player has the item.
---@param src number
---@param item string
---@param requiredCount number (optional)
---@return boolean
Inventory.HasItem = function(src, item, requiredCount)
    return ox_inventory:GetItemCount(src, item, nil, false) >= (requiredCount or 1)
end

---@description This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return ox_inventory:CanCarryItem(src, item, count)
end

---@description This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    ox_inventory:UpdateVehicle(oldplate, newplate)
    -- ox standard doesnt return anything so probably shouldnt return so everything else has the same standard. Yeaaaa probably should change this.
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
    Inventory.RegisterStash(id, identifier, 20, 10000, nil, nil, nil)
    Wait(100)
    local success = false
    for _, v in pairs(items) do
        success = ox_inventory:AddItem(id, v.item, v.count or v.amount, v.metadata or v.info or {})
    end
    return success
end

---@description This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("ox_inventory", string.format("web/images/%s.png", item))
    local imagePath = file and string.format("nui://ox_inventory/web/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---@description This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    TriggerClientEvent('ox_inventory:openInventory', src, 'shop', {type = shopTitle})
end

---@description This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param inventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, inventory, shopCoords, shopGroups)
    ox_inventory:RegisterShop(shopTitle, { name = shopTitle, inventory = inventory, groups = shopGroups, })
    -- ox standard doesnt return anything so probably shouldnt return so everything else has the same standard. Yeaaaa probably should change this.
    return true
end

---@description This will open a players inventory, used for admin purposes and stuff.
---@param src number
---@param target number
Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    assert(target, "OpenPlayerInventory: target is required")
    ox_inventory:forceOpenInventory(src, 'player', target)
end

return Inventory