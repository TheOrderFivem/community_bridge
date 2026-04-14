---@diagnostic disable: duplicate-set-field
if GetResourceState('bp_inventory') == 'missing' then return end

Inventory = Inventory or {}

---@description This will get the name of the in use resource.
---@return string
Inventory.GetResourceName = function()
    return "bp_inventory"
end

-- Fallback to community_bridge's trigger to open a stash using bp_inventory method
RegisterNetEvent("community_bridge:client:bp_inventory:openStash", function(_type, id)
    TriggerServerEvent('inventory:server:OpenInventory', _type, id, false, {})
end)

return Inventory
