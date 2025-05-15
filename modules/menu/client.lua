Menus = Menus or {}
Menu = {}

--- Opens a menu based on the configuration.
---@param data table The menu data.
---@param useQb boolean Whether to use QB menu syntax.
---@return id string The menu ID.
function Menu.Open(data, useQb)
    local id = data.id or Ids.CreateUniqueId(Menus, nil, nil)
    Menus[id] = OpenMenu(id, data, useQb)
    data.id = id
    return id
end

--- Event to handle callback from menu selection.
--- @param _args table The arguments passed to the callback.
--- @return nil
RegisterNetEvent('community_bridge:client:MenuCallback', function(_args)
    local id = _args.id
    local onSelect = _args.onSelect
    local args = _args.args
    Menus[id] = nil
    onSelect(args)
end)

return Menu

--[[

--Unit Tests
local qbMenu = {
    {
        header = 'QBCore Test Menu',
        icon = 'fas fa-code',
        isMenuHeader = true, -- Set to true to make a nonclickable title
    },
    {
        header = 'First Button',
        txt = 'Open a secondary menu!',
        icon = 'fas fa-code-pull-request',
        -- disabled = false, -- optional, non-clickable and grey scale
        -- hidden = true, -- optional, hides the button completely
        params = {
            -- isServer = false, -- optional, specify event type
            event = 'community_bridge:client:TestEvent',
            args = {
                number = 1,
            }
        }
    },
    {
        header = 'Second Button',
        txt = 'Open a secondary menu!',
        icon = 'fas fa-code-pull-request',
        params = {
            event = 'community_bridge:client:TestEvent',
            args = {
                number = 2,
            }
        }
    }
}

local oxMenu = {
    id = "test",
    title = "Test Menu",
    options = {
        {
            title = "First Button",
            description = "Open a secondary menu!",
            icon = "fas fa-code-pull-request",
            args = {
                number = 1,
            },
            onSelect = function(selected, secondary, args)
                print("Selected", json.encode(selected))
            end
        },
        {
            title = "Second Button",
            description = "Open a secondary menu!",
            icon = "fas fa-code-pull-request",
            args = {
                number = 2,
            },
            onSelect = function(selected, secondary, args)
                print("Selected", json.encode(selected))
            end
        }
    }
}

RegisterCommand("testmenu-qbtoox", function()
    Menu.Open(qbMenu, true)
end)

RegisterCommand("testmenu-oxtoqb", function()
    Menu.Open(oxMenu, false)
end)

RegisterCommand("testmenu-oxtoox", function()
    Menu.Open(oxMenu, false)
end)

RegisterCommand("testmenu-qbtoqb", function()
    Menu.Open(qbMenu, true)
end)

RegisterNetEvent('community_bridge:client:TestEvent', function(args)
    print("Test Event", json.encode(args))
end)

--]]