---@diagnostic disable: duplicate-set-field
if GetResourceState('codem-inventory') ~= 'started' then return end
Inventory = Inventory or {}

local codem = exports['codem-inventory']

---This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "codem-inventory"
end

---This will return the entire items table from the inventory.
---@return table 
Inventory.Items = function()
    return codem:GetItemList() or {}
end

---Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local itemData = Inventory.Items()
    if not itemData or not itemData[item] then return {} end
    local image = Inventory.GetImagePath(itemData[item].image) or Inventory.GetImagePath(item)
    return {
        name = itemData[item].name or "Missing Name",
        label = itemData[item].label or "Missing Label",
        stack = itemData[item].unique or "false",
        weight = itemData[item].weight or "0",
        description = itemData[item].description or "none",
        image = image,
    }
end

---This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("codem-inventory", string.format("html/images/%s.png", item))
    local imagePath = file and string.format("nui://codem-inventory/html/images/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    local items = {}
    local inventory = codem:getUserInventory()
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

RegisterNetEvent('community_bridge:client:codem-inventory:openStash', function(id, data)
    if source ~= 65535 then return end
    TriggerServerEvent('codem-inventory:server:openstash', id, data.slots, data.weight, data.label)
end)

return Inventory