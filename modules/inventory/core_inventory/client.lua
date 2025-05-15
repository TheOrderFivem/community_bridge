---@diagnostic disable: duplicate-set-field
if GetResourceState('core_inventory') ~= 'started' then return end
local core = exports.core_inventory

Inventory = Inventory or {}

---Return the item info in oxs format, {name, label, stack, weight, description, image}
---@param item string
---@return table
Inventory.GetItemInfo = function(item)
    local frameworkName = Framework.GetFrameworkName()
    if not frameworkName then return {} end
    local dataRepack = {}
    if frameworkName == 'es_extended' then
        --<-- TODO swap to internal callback system
        local callbackData = lib.callback.await('community_bridge:Callback:core_inventory', false)
        -- really really wish this inventory allowed me to pull the item list client side....
        dataRepack = callbackData[item]
        if not dataRepack then return {} end
    elseif frameworkName == 'qb-core' then
        dataRepack = Framework.Shared.Items[item]
        if not dataRepack then return {} end
    end
    return {name = dataRepack.name, label = dataRepack.label, stack = dataRepack.stack, weight = dataRepack.weight, description = dataRepack.description, image = Inventory.GetImagePath(dataRepack.name) }
end

---Will return boolean if the player has the item.
---@param item string
---@return boolean
Inventory.HasItem = function(item)
    return core:hasItem(item, 1)
end

---This will return th count of the item in the players inventory, if not found will return 0.
---@param item string
---@return number
Inventory.GetItemCount = function(item)
    return core:getItemCount(item)
end

---This will get the image path for this item, if not found will return placeholder.
---@param item string
---@return string
Inventory.GetImagePath = function(item)
    item = Inventory.StripPNG(item)
    local file = LoadResourceFile("core_inventory", string.format("html/img/%s.png", item))
    local imagePath = file and string.format("nui://core_inventory/html/img/%s.png", item)
    return imagePath or "https://avatars.githubusercontent.com/u/47620135"
end

---This will return the players inventory in the format of {name, label, count, slot, metadata}
---@return table
Inventory.GetPlayerInventory = function()
    local playerItems = core:getInventory()
    local repackedTable = {}
    for _, v in pairs(playerItems) do
        table.insert(repackedTable, {
            name = v.name,
            count = v.count,
            metadata = v.metadata,
            slot = v.id,
        })
    end
    return repackedTable
end

return Inventory