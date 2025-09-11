---@diagnostic disable: duplicate-set-field
Target = Target or {}
Ids = Ids or Require("lib/utility/shared/ids.lua")

local function warnUser()
    print("Currently Only Targeting Is Supported By Community Bridge, You Are Using A Resource That Requires The Target Module To Be Used.")
end
local InteractIds = {}

Target.GetCanInteract = function(id)
    return InteractIds[id]
end

Target.CreateCanInteract = function(cb)
    if not cb then return end
    local id = Ids.CreateUniqueId(InteractIds)
    InteractIds[id] = {
        id = id,
        ableToInteract = -1,
        onInteract = cb
    }
    return id
end

Target.CanInteract = function(id, ...)
    local interactData = InteractIds[id]
    if not interactData then return true end
    if interactData.ableToInteract == -1 then
        local cb = interactData.onInteract
        local canInteractStatus = cb(...)
        interactData.ableToInteract = canInteractStatus and 1 or 0
        SetTimeout(1000, function()
            interactData.ableToInteract = -1
        end)
    end
    return interactData.ableToInteract > 0
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
        local optionsCanInteract = v.canInteract
        if optionsCanInteract then 
            local id = Target.CreateCanInteract(optionsCanInteract)
            v.canInteract = function(...)
                return Target.CanInteract(id, ...)
            end
        end
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
    local fixedOptions = Target.FixOptions(options)
    local id = Ids.RandomString()
    local title =  Bridge.Language.Locale("target.title")
    local menuData = { id = id, title = title, options = {} }
    for k, v in pairs(fixedOptions) do
        table.insert(menuData.options, {
            title = title .. " " .. k,
            description = Bridge.Language.Locale("target.description"),
            onSelect = function(selected, secondary, args)
                if v.onSelect then
                    v.onSelect(selected, secondary, args)
                end
            end
        })
    end
    local inZone = false
    Point.Register(id, coords, 5, nil,
    function()
        local sleep = 3000
        while inZone do
            Wait(sleep)
            local distance = #(coords - GetEntityCoords(PlayerPedId()))
            if distance < 10 then
                sleep = 0
                Utility.Draw3DHelpText(coords, Bridge.Language.Locale("target.interact"), 0.35)
                if IsControlJustPressed(0, 38) then
                    Menu.Open(menuData, false)
                end
            else
                sleep = 3000
            end
        end
    end,
    function()
        inZone = false
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

Target.GetResourceName = function()
    return "default"
end

return Target