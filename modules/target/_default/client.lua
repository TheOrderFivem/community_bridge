Target = Target or {}

local function warnUser()
    print("Currently Only Targeting Is Supported By Community Bridge, You Are Using A Resource That Requires The Target Module To Be Used.")
end

Target.FixOptions = function(options)
    for k, v in pairs(options) do
        local action = v.onSelect or v.action
        local select = function(entityOrData)
            if type(entityOrData) == 'table' then
                return action(entityOrData.entity)
            end
            return action(entityOrData)
        end
        options[k].onSelect = select
    end
    return options
end

Target.AddGlobalPlayer = function(options)
    warnUser()
end

Target.AddGlobalVehicle = function(options)
    warnUser()
end

Target.RemoveGlobalVehicle = function(options)
    warnUser()
end

Target.AddLocalEntity = function(entities, _options)
    local fixedOptions = Target.FixOptions(_options)
    if type(entities) == "string" or type(entities) == "number" then
        entities = { entities }
    end
    for _, entity in pairs(entities) do
        local id = Ids.RandomString()
        local menuData = { id = id, title = "Options", options = {} }
        for k, v in pairs(fixedOptions) do
            table.insert(menuData.options, {
                title = ("Option " .. k),
                description = "No Description",
                icon = v.icon or "fas fa-code-pull-request",
                args = {},
                onSelect = function(selected, secondary, args)
                    if v.onSelect then
                        v.onSelect(selected, secondary, args)
                    end
                end
            })
        end
        Point.Register(id, entity, 5, args,
        function()
            local coords = GetEntityCoords(entity)
            local sleep = 3000
            while DoesEntityExist(entity) do
                Wait(sleep)
                local distance = #(coords - GetEntityCoords(PlayerPedId()))
                if distance < 10 then
                    sleep = 0
                    Utility.Draw3DHelpText(coords, "Press [E] To Interact", 0.35)
                    if IsControlJustPressed(0, 38) then
                        Menu.Open(menuData, false)
                    end
                else
                    sleep = 3000
                end
            end
        end,
        function()
            Point.Remove(id)
        end, function()
            --No need for this in this one
        end)
    end
end


Target.AddModel = function(models, options)
    warnUser()
end

Target.AddBoxZone = function(name, coords, size, heading, options)
    local fixedOptions = Target.FixOptions(_options)
    local id = Ids.RandomString()
    local menuData = { id = id, title = "Options", options = {} }
    for k, v in pairs(fixedOptions) do
        table.insert(menuData.options, {
            title = ("Option " .. k),
            description = "No Description",
            onSelect = function(selected, secondary, args)
                if v.onSelect then
                    v.onSelect(selected, secondary, args)
                end
            end
        })
    end
    Point.Register(id, coords, 5, args,
    function()
        local sleep = 3000
        while true do
            Wait(sleep)
            local distance = #(coords - GetEntityCoords(PlayerPedId()))
            if distance < 10 then
                sleep = 0
                Utility.Draw3DHelpText(coords, "Press [E] To Interact", 0.35)
                if IsControlJustPressed(0, 38) then
                    Menu.Open(menuData, false)
                end
            else
                sleep = 3000
            end
        end
    end,
    function()
        Point.Remove(id)
    end, function()
        --No need for this in this one
    end)
end

Target.RemoveGlobalPlayer = function()
    warnUser()
end

Target.RemoveLocalEntity = function(entity)
    warnUser()
end

Target.RemoveModel = function(model)
    warnUser()
end

Target.RemoveZone = function(name)
    warnUser()
end

return Target