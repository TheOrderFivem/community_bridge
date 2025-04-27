Bridge = {}

function Bridge.RegisterModule(moduleName, moduleTable)
    if not moduleTable then
        if BridgeSharedConfig.DebugLevel ~= 0 then
            print("^6 No moduleTable provided for module: ", moduleName, "^0")
        end
        return
    end

    local wrappedModule = {}
    if type(moduleTable) == 'function' then
        Bridge[moduleName] = wrappedModule
        exports(moduleName, moduleTable)
        return
    end
    for functionName, func in pairs(moduleTable) do
        wrappedModule[functionName] = func
    end
    if BridgeSharedConfig.DebugLevel ~= 0 then
        print("^2 Registering module:", moduleName, "^0")
    end
    Bridge[moduleName] = wrappedModule


    exports(moduleName, function()
        return wrappedModule
    end)

    --trigger update object event
    TriggerEvent("Bridge:Refresh", moduleName, wrappedModule)
end
exports("RegisterModule", Bridge.RegisterModule)

--TODO: Create a way to overide functions or create a new functions for module

function Bridge.RegisterModuleFunction(moduleName, functionName, func)
    assert(moduleName and functionName and func, string.format("Bridge.RegisterModuleFunction(%s, %s, %s) - Invalid arguments", moduleName, functionName, func))
    Bridge[moduleName] = Bridge[moduleName] or {}
    Bridge[moduleName][functionName] = func
    --trigger update object event
    TriggerEvent("Bridge:Refresh", moduleName, Bridge[moduleName])
end


--Bridge
Bridge.RegisterModule("Framework", Framework)
Bridge.RegisterModule("Inventory", Inventory)
Bridge.RegisterModule("Notify", Notify)
Bridge.RegisterModule("Clothing", Clothing)
Bridge.RegisterModule("Language", Language)
Bridge.RegisterModule("Doorlock", Doorlock)
Bridge.RegisterModule("Phone", Phone)
Bridge.RegisterModule("Dispatch", Dispatch)
Bridge.RegisterModule("Shops", Shops)
Bridge.RegisterModule("Housing", Housing)

--lib
Bridge.RegisterModule("Tables", cLib.Tables)
Bridge.RegisterModule("Math", cLib.Math)
Bridge.RegisterModule("Prints", cLib.Prints)
Bridge.RegisterModule("Callback", cLib.Callback)

--new
Bridge.RegisterModule("Require", Require)
Bridge.RegisterModule("Ids", cLib.Ids)
Bridge.RegisterModule("ReboundEntities", cLib.ReboundEntities)
Bridge.RegisterModule("LA", cLib.LA)
Bridge.RegisterModule("Perlin", cLib.Perlin)
Bridge.RegisterModule("Actions", cLib.Actions)
Bridge.RegisterModule("Cache", cLib.Cache)


exports('Bridge', function()
    return Bridge
end)

-- ▄▀▀ ██▀ █▀▄ █ █ ██▀ █▀▄ 
-- ▄█▀ █▄▄ █▀▄ ▀▄▀ █▄▄ █▀▄ 
if not IsDuplicityVersion() then goto client end

Bridge.RegisterModule("SQL", cLib.SQL)
Bridge.RegisterModule("Logs", cLib.Logs)
Bridge.RegisterModule("ItemsBuilder", cLib.ItemsBuilder)
Bridge.RegisterModule("LootTables", cLib.LootTables)
Bridge.RegisterModule("Version", Version)
Bridge.RegisterModule("ServerEntity", cLib.ServerEntity)


--    ▄▀▀ █   █ ██▀ █▄ █ ▀█▀ 
--    ▀▄▄ █▄▄ █ █▄▄ █ ▀█  █  
if IsDuplicityVersion() then return end
::client::


Bridge.RegisterModule("Fuel", Fuel)
Bridge.RegisterModule("Input", Input)
Bridge.RegisterModule("ProgressBar", ProgressBar)
Bridge.RegisterModule("VehicleKey", VehicleKey)
Bridge.RegisterModule("Weather", Weather)

Bridge.RegisterModule("Target", Target)
Bridge.RegisterModule("Menu", Menu)
Bridge.RegisterModule("Dialogue", Dialogue)
Bridge.RegisterModule("Accessibility", Accessibility) -- new

Bridge.RegisterModule("Utility", cLib.Utility)
Bridge.RegisterModule("Placeable", cLib.Placeable)--new
Bridge.RegisterModule("Gizmo", cLib.Gizmo)
Bridge.RegisterModule("Scaleform", cLib.Scaleform)
Bridge.RegisterModule("Raycast", cLib.Raycast)
Bridge.RegisterModule("PlaceableObject", cLib.PlaceableObject)
Bridge.RegisterModule("Point", cLib.Point)
Bridge.RegisterModule("Object", cLib.Object)
Bridge.RegisterModule("Particle", cLib.Particle)
Bridge.RegisterModule("ClientEntity", cLib.ClientEntity)
Bridge.RegisterModule("ClientEntityActions", cLib.ClientEntityActions)
Bridge.RegisterModule("Anim", cLib.Anim) -- new
Bridge.RegisterModule("Requests", cLib.Requests) -- new

-- Fill the bridge tables with player data.
function FillBridgeTables()
    PlayerLoaded = true
    PlayerIdentifier = Framework.GetPlayerIdentifier()
    PlayerJobName, PlayerJobLabel, PlayerJobGradeName, PlayerJobGradeLevel = Framework.GetPlayerJob()
end

-- Clean the bridge tables.
function ClearClientSideVariables()
    PlayerLoaded = false
    PlayerIdentifier = nil
    PlayerJobName = nil
    PlayerJobLabel = nil
    PlayerJobGradeName = nil
    PlayerJobGradeLevel = nil
    StoredOldClothing = {}
end
