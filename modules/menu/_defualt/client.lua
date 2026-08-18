Menus = Menus or {}
Menu = {}

---Opens a menu based on the configuration.
---@param data table The menu data.
---@param useQb boolean Whether to use QB menu syntax.
---@return id string The menu ID.
function Menu.Open(data, useQb)
    local id = data.id or lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
    Menus[id] = OpenMenu(id, data, useQb)
    data.id = id
    return id
end

function Menu.GetResourceName()
    return GetMenuResourceName()
end

---Event to handle callback from menu selection.
---@param _args table The arguments passed to the callback.
---@return nil
RegisterNetEvent('community_bridge:client:MenuCallback', function(_args)
    local id = _args.id
    local onSelect = _args.onSelect
    local args = _args.args
    Menus[id] = nil
    onSelect(args)
end)

return Menu