---@diagnostic disable: duplicate-set-field
if GetResourceState('origen_inventory') ~= 'started' then return end
Inventory = Inventory or {}
local origin = exports.origen_inventory

---Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = origin:Items(item)
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

---Will return boolean if the player has the item.
---@param item string
---@return boolean
Inventory.HasItem = function(item)
    return origin:HasItem(item)
end

---This will return th count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    local inventory = origin:Search('count', item)
    if not inventory then return 0 end
    return inventory.count
end

---This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("origen_inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://origen_inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    local repack = {}
    local inventory = origin:GetInventory()
    if not inventory then return {} end
    for _, v in pairs(inventory) do
        table.insert(repack, {
            name = v.name,
            label = v.label,
            count = v.count,
            slot = v.slot,
            metadata = v.metadata,
            stack = v.unique,
            close = v.useable,
            weight = v.weight
        })
    end
    return repack
end

Inventory.OpenStash = function(id)
    origin:openInventory('stash', id, { label = id, weight = 400000, slots = 100, })
end

return Inventory