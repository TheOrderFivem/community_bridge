---@diagnostic disable: duplicate-set-field
---
---TODO: fix points
Target = Target or {}
Ids = Ids or Require("lib/utility/shared/ids.lua")

local InteractIds = {}

local function warnUser()
    print("Currently Only Targeting Is Supported By Community Bridge, You Are Using A Resource That Requires The Target Module To Be Used.")
end

function Target.GetResourceName()
    return "default"
end

function Target.GetCanInteract(id)
    return InteractIds[id]
end

function Target.CreateCanInteract(cb)
    if not cb then return end
    local id = lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
    InteractIds[id] = {
        id = id,
        ableToInteract = -1,
        onInteract = cb
    }
    return id
end

function Target.CanInteract(id, ...)
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

function Target.FixOptions(options)
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

function Target.AddGlobalPlayer(options)
    warnUser()
end

function Target.AddGlobalVehicle(options)
    warnUser()
end

function Target.RemoveGlobalVehicle(options)
    warnUser()
end

function Target.AddLocalEntity(entities, _options)
    local fixedOptions = Target.FixOptions(_options)
    if type(entities) == "string" or type(entities) == "number" then
        entities = { entities }
    end
    for _, entity in pairs(entities) do
        local id = lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
        local title =  lib.locale("target.title")
        local menuData = { id = id, title = title, options = {} }
        for k, v in pairs(fixedOptions) do
            table.insert(menuData.options, {
                title = title .. " " .. k,
                description = lib.locale("target.description"),
                onSelect = function(selected, secondary, args)
                    if v.onSelect then
                        v.onSelect(selected, secondary, args)
                    end
                end
            })
        end
        Point.Register(id, entity, 5, nil, function()
            local coords = GetEntityCoords(entity)
            local sleep = 3000
            local test = lib.locale("target.interact")
            CreateThread(function()
                while DoesEntityExist(entity) do
                    Wait(sleep)
                    local distance = #(coords - GetEntityCoords(PlayerPedId()))
                    if distance < 2 then
                        sleep = 0
                        Utility.Draw3DHelpText(coords, test, 0.35)
                        if IsControlJustPressed(0, 38) then
                            Menu.Open(menuData, false)
                        end
                    else
                        sleep = 1000
                    end
                end
            end)
        end,
        function()
            Point.Remove(id)
        end, function()
            --No need for this in this one
        end)
    end
end

function Target.AddModel(models, options)
    warnUser()
end

function Target.AddBoxZone(name, coords, size, heading, options)
    local fixedOptions = Target.FixOptions(options)
    local id = lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
    local title =  lib.locale("target.title")
    local menuData = { id = id, title = title, options = {} }
    for k, v in pairs(fixedOptions) do
        table.insert(menuData.options, {
            title = title .. " " .. k,
            description = lib.locale("target.description"),
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
                Utility.Draw3DHelpText(coords, lib.locale("target.interact"), 0.35)
                if IsControlJustPressed(0, 38) then
                    Menu.Open(menuData, false)
                end
            end
        end
    end,
    function()
        inZone = false
        Point.Remove(id)
    end, 
    function()
        --No need for this in this one
    end)
end

function Target.RemoveGlobalPlayer()
    warnUser()
end

function Target.RemoveLocalEntity(entity)
    warnUser()
end

function Target.RemoveModel(model)
    warnUser()
end

function Target.RemoveZone(name)
    warnUser()
end

return Target