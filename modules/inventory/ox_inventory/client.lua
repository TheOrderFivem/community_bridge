---@diagnostic disable: duplicate-set-field
if GetResourceState('ox_inventory') ~= 'started' then return end
local ox_inventory = exports.ox_inventory

Inventory = Inventory or {}

---Return the item info in oxs format, {name, label, stack, weight, description, image}
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
        image = (itemData.client and itemData.client.image) or Inventory.GetImagePath(item),
    }
end

---Will return boolean if the player has the item.
---@param item string
---@return boolean
Inventory.HasItem = function(item)
    return ox_inventory:Search('count', item) > 0
end

---This will return th count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    return ox_inventory:GetItemCount(item, nil, false)
end

---This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("ox_inventory", string.format("web/images/%s.png", item))
    local imagePath = file and string.format("nui://ox_inventory/web/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    return ox_inventory:GetPlayerItems()
end

Inventory.OpenShop = function(shopTitle, shopInventory)
    ox_inventory:openInventory("shop", { type = shopTitle, id = 1 })
end

return Inventory