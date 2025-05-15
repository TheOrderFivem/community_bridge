Bridge = {}

function Bridge.RegisterModule(moduleName, moduleTable)
    if not moduleTable then
        if BridgeSharedConfig.DebugLevel ~= 0 then
            print("^6 No moduleTable provided for module: ", moduleName, "^0")
        end
        return
    end

    local wrappedModule = Bridge[moduleName] or {}
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
    _ENV[moduleName] = wrappedModule -- Add to the ENV table the modules so is more easy and safe to call from inside
    _ENV.Bridge = Bridge -- Add the bridge too to the _ENV

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
Bridge.RegisterModule("HelpText", HelpText)
Bridge.RegisterModule("Clothing", Clothing)
Bridge.RegisterModule("Language", Language)
Bridge.RegisterModule("Doorlock", Doorlock)
Bridge.RegisterModule("Phone", Phone)
Bridge.RegisterModule("Dispatch", Dispatch)
Bridge.RegisterModule("Shops", Shops)
Bridge.RegisterModule("Housing", Housing)
Bridge.RegisterModule("Version", Version)

--lib
-- Bridge.RegisterModule("Tables", cLib.Tables)
-- Bridge.RegisterModule("Math", cLib.Math)
-- Bridge.RegisterModule("Prints", cLib.Prints)
-- Bridge.RegisterModule("Callback", cLib.Callback)

-- --new
Bridge.RegisterModule("Require", Require)
-- Bridge.RegisterModule("Ids", cLib.Ids)
-- Bridge.RegisterModule("ReboundEntities", cLib.ReboundEntities)
-- Bridge.RegisterModule("LA", cLib.LA)
-- Bridge.RegisterModule("Perlin", cLib.Perlin)
-- Bridge.RegisterModule("Actions", cLib.Actions)
-- Bridge.RegisterModule("Cache", cLib.Cache)
-- Bridge.RegisterModule("Skills", Skills)


for k, v in pairs(cLib) do
    if v then
        Bridge.RegisterModule(k, v)
    end
end

exports('Bridge', function()
    return Bridge
end)

-- ▄▀▀ ██▀ █▀▄ █ █ ██▀ █▀▄ 
-- ▄█▀ █▄▄ █▀▄ ▀▄▀ █▄▄ █▀▄ 
if not IsDuplicityVersion() then goto client end
Bridge.RegisterModule('Version', Version)

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