---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-inventory') ~= 'started' then return end
if GetResourceState('codem-inventory') ~= 'missing' then return end
if GetResourceState('origen_inventory') ~= 'missing' then return end
local qbInventory = exports['qb-inventory']

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

local registeredShops = {}
local v1ShopData = {}

local function getInventoryNewVersion()
    if tonumber(string.sub(GetResourceMetadata("qb-inventory", "version", 0), 1, 1)) >= 2 then return true end
    return false
end

---This will add an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.AddItem = function(src, item, count, slot, metadata)
    if getInventoryNewVersion() then if not qbInventory:CanAddItem(src, item, count) then return false end end
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "add", item = item, count = count, slot = slot, metadata = metadata})
    return qbInventory:AddItem(src, item, count, slot, metadata, 'community_bridge')
end

---This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "qb-inventory"
end

---This will remove an item, and return true or false based on success
---@param src number
---@param item string
---@param count number
---@param slot number
---@param metadata table
---@return boolean
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', count)
    TriggerClientEvent("community_bridge:client:inventory:updateInventory", src, {action = "remove", item = item, count = count, slot = slot, metadata = metadata})
    return qbInventory:RemoveItem(src, item, count, slot, 'community_bridge')
end

---This will add items to a trunk, and return true or false based on success
---If a trunk with the identifier does not exist, it will create one with default values.
---@param identifier string
---@param items table
---@return boolean
Inventory.AddTrunkItems = function(identifier, items)
    if type(items) ~= "table" then return false end
    local fullTrunkId = "trunk-"..identifier
    local repacked_items = {}
    local slot = 0
    for _, item in pairs(items) do
        slot = slot + 1
        repacked_items[slot] = {
            name = item.item,
            amount = item.count,
            info = item.metadata,
            type = item.type or "item",
            slot = slot,
        }
    end
    local newVersion = getInventoryNewVersion()
    if newVersion then
        qbInventory:CreateInventory(fullTrunkId, { label = fullTrunkId })
        Wait(1000)
        for i = 1, #repacked_items do
            local v = repacked_items[i]
            qbInventory:AddItem(fullTrunkId, v.name, v.amount, v.slot, v.info, "community_bridge, adding items to trunk")
        end
    else
        -- I dont have a copy of this version to test it, if you run into issues please let me know.
        TriggerEvent("inventory:server:addTrunkItems", fullTrunkId, repacked_items)
    end
    return true
end

---This will clear the specified inventory, will always return true unless a value isnt passed correctly.
---@param id string
---@return boolean
Inventory.ClearStash = function(id, _type)
    if type(id) ~= "string" then return false end
    if _type == "trunk" then
        id = "trunk-"..id
    elseif _type == "glovebox" then
        id = "glovebox-"..id
    end
    if qbInventory:GetInventory(id) then
        qbInventory:ClearStash(id)
    end
    if Inventory.Stashes[id] then Inventory.Stashes[id] = nil end
    return true
end

---This will return a table with the item info, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = Framework.Shared.Items[item]
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

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return Framework.Shared.Items
end

---Returns the specified slot data as a table.
---format {weight, name, metadata, slot, label, count}
---@param src number
---@param slot number
---@return table
Inventory.GetItemBySlot = function(src, slot)
    local slotData = qbInventory:GetItemBySlot(src, slot)
    if not slotData then return {} end
    return {
        name = slotData.name,
        label = slotData.name,
        weight = slotData.weight,
        slot = slotData.slot,
        count = slotData.amount,
        metadata = slotData.info,
        stack = slotData.unique,
        description = slotData.description
    }
end

---This will open the specified stash for the src passed.
---@param src number
---@param _type string
---@param id number||string
---@return nil
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    local tbl = Inventory.Stashes[id]

    if getInventoryNewVersion() then
        return qbInventory:OpenInventory(src, id)
    end

    TriggerClientEvent('community_bridge:client:qb-inventory:openStash', src, id, { weight = tbl.weight, slots = tbl.slots})
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
    return qbInventory:HasItem(src, item, 1)
end

---This is to get if there is available space in the inventory, will return boolean.
---@param src number
---@param item string
---@param count number
---@return boolean
Inventory.CanCarryItem = function(src, item, count)
    return true
end

---This will get the image path for an item, it is an alternate option to GetItemInfo. If a image isnt found will revert to community_bridge logo (useful for menus)
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qb-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qb-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will update the plate to the vehicle inside the inventory. (It will also update with jg-mechanic if using it)
---@param oldplate string
---@param newplate string
---@return boolean
Inventory.UpdatePlate = function(oldplate, newplate)
    local newVersion = getInventoryNewVersion()
    if newVersion then
        local gloveboxInv = qbInventory:GetInventory('glovebox-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
        local storedGloveBox = Bridge.Tables.DeepClone(gloveboxInv, nil, nil)
        local trunkInv = qbInventory:GetInventory('trunk-'..oldplate) or {slots = 5, maxweight = 10000, items = {}}
        local storedTrunk = Bridge.Tables.DeepClone(trunkInv, nil, nil)
        qbInventory:ClearStash('glovebox-'..oldplate)
        qbInventory:ClearStash('trunk-'..oldplate)
        qbInventory:CreateInventory('glovebox-'..newplate, {label = 'glovebox-'..newplate, slots = storedGloveBox.slots, maxweight = storedGloveBox.maxweight})
        qbInventory:SetInventory('glovebox-'..newplate, storedGloveBox.items, "Community Bridge Moving Items In GloveBox")
        qbInventory:CreateInventory('trunk-'..newplate, {label = 'trunk-'..newplate, slots = storedTrunk.slots, maxweight = storedTrunk.maxweight})
        qbInventory:SetInventory('trunk-'..newplate, storedTrunk.items, "Community Bridge Moving Items In Trunk")
        return true
    else
        local queries = {
            'UPDATE inventory_glovebox SET plate = @newplate WHERE plate = @oldplate',
            'UPDATE inventory_trunk SET plate = @newplate WHERE plate = @oldplate',
        }
        local values = { newplate = newplate, oldplate = oldplate }
        MySQL.transaction.await(queries, values)
    end
    if GetResourceState('jg-mechanic') ~= 'started' then return true end
    return true, exports["jg-mechanic"]:vehiclePlateUpdated(oldplate, newplate)
end

---This will open the specified shop for the src passed.
---@param src number
---@param shopTitle string
Inventory.OpenShop = function(src, shopTitle)
    local newVersion = getInventoryNewVersion()
    if newVersion then
        return qbInventory:OpenShop(src, shopTitle)
    else
        local shopData = v1ShopData[shopTitle]
        if not shopData then return false end
        TriggerClientEvent("inventory:client:OpenInventory", src, "shop", shopTitle, shopData)
    end
end

--This will register a shop, if it already exists it will return true.
---@param shopTitle string
---@param shopInventory table
---@param shopCoords table
---@param shopGroups table
Inventory.RegisterShop = function(shopTitle, shopInventory, shopCoords, shopGroups)
    if not shopTitle or not shopInventory then return end
    if registeredShops[shopTitle] then return true end
    registeredShops[shopTitle] = true
    local newVersion = getInventoryNewVersion()
    if newVersion then
        local repackedShopItems = {}
        for _, v in pairs(shopInventory) do
            table.insert(repackedShopItems, {name = v.name, price = v.price, amount = v.count or 1000})
        end
        qbInventory:CreateShop({ name = shopTitle, label = shopTitle, coords = shopCoords, items = repackedShopItems, })
        return true
    else
        local shopData = { label = shopTitle, items = {}, slots = 0 }

        for _, v in pairs(shopInventory) do
            table.insert(shopData.items, { name = v.name, price = v.price, amount = v.count or 1000, info = {}, type = 'item' })
        end

        shopData.slots = #shopData.items
        -- TriggerClientEvent("inventory:client:OpenInventory", src, "shop", shopTitle, shopData)
        v1ShopData[shopTitle] = shopData
        print("QB-INVENTORY: You are using an outdated version of qb-inventory, please update to the latest version. Stuff will still work but you are using litterally the most exploitable inventory in fivem.")
    end
end

Inventory.OpenPlayerInventory = function(src, target)
    assert(src, "OpenPlayerInventory: src is required")
    if not target then
        target = src
    end
    exports['qb-inventory']:OpenInventory(src, target)
end

return Inventory