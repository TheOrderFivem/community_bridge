---@diagnostic disable: duplicate-set-field
Inventory = Inventory or {}

---Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    return Framework.GetItemInfo(item)
end

---Will return boolean if the player has the item.
---@param item string
---@return boolean
Inventory.HasItem = function(item)
    return Framework.HasItem(item)
end

---This will return th count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    return Framework.GetItemCount(item)
end

---This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    return Framework:GetPlayerInventory()
end

---This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    return "https://avatars.githubusercontent.com/u/47620135"
end

Inventory.StripPNG = function(item)
    if string.find(item, ".png") then
        item = string.gsub(item, ".png", "")
    end
    return item
end

return Inventory