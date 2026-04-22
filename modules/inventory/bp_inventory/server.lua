---@diagnostic disable: duplicate-set-field
if GetResourceState('bp_inventory') == 'missing' then return end

Inventory = Inventory or {}
Inventory.Stashes = Inventory.Stashes or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "bp_inventory"
end

---@description This will add an item, and return true or false based on success
Inventory.AddItem = function(src, item, count, slot, metadata)
    local success = exports['bp_inventory']:AddItem(src, item, count, metadata, slot)
    return success or false
end

---@description This will remove an item, and return true or false based on success
Inventory.RemoveItem = function(src, item, count, slot, metadata)
    item = type(item) == "table" and item.name or item
    local success = exports['bp_inventory']:RemoveItem(src, item, count, slot)
    return success or false
end

---@description This will return a boolean if the player has the item.
Inventory.HasItem = function(src, item, requiredCount)
    requiredCount = requiredCount or 1
    local hasIt = false
    local itemData = exports['bp_inventory']:hasItem(src, item)
    if type(itemData) == "table" and ((itemData.amount or itemData.count or 0) >= requiredCount) then
        hasIt = true
    elseif type(itemData) == "number" and itemData >= requiredCount then
        hasIt = true
    elseif itemData == true and requiredCount == 1 then
        hasIt = true
    end
    return hasIt
end

---@description This will open the specified stash for the src passed.
Inventory.OpenStash = function(src, _type, id)
    _type = _type or "stash"
    TriggerClientEvent("community_bridge:client:bp_inventory:openStash", src, _type, id)
end

return Inventory
