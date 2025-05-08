if GetResourceState('qs-inventory') ~= 'started' then return end
local quasar = exports["qs-inventory"]
Inventory = Inventory or {}

---comment
---@param id any
---@return nil
Inventory.OpenStash = function(id)
    quasar:RegisterStash(id, 50, 50000)
end

---comment
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemsData = quasar:GetItemList()
    if not itemsData then return {} end
    local itemData = itemsData[item]
    if not itemData then return {} end
    local repackedTable = {
        name = itemData.name or "Missing Name",
        label = itemData.label or "Missing Label",
        stack = itemData.unique or "false",
        weight = itemData.weight or "0",
        description = itemData.description or "none",
        image = itemData.image or Inventory.GetImagePath(item),
    }
    return repackedTable
end

---comment
---@param item string
---@return boolean
Inventory.HasItem = function(item)
    local check = quasar:Search(item)
    return check and true or false
end

---comment
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("qs-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://qs-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---comment
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    local searchItem = quasar:Search(item)
    return searchItem or 0
end

---comment
---@return table
Inventory.GetPlayerInventory = function()
    local items = {}
    local inventory = quasar:getUserInventory()
    for _, v in pairs(inventory) do
        table.insert(items, {
            name = v.name,
            label = v.label,
            count = v.amount,
            slot = v.slot,
            metadata = v.info,
            stack = v.unique,
            close = v.useable,
            weight = v.weight
        })
    end
    return items
end

