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
        Bridge[moduleName] = moduleTable
        exports(moduleName, moduleTable)
        return
    end
    for functionName, func in pairs(moduleTable) do
        wrappedModule[functionName] = func
    end
    if BridgeSharedConfig.DebugLevel ~= 0 then
        print("^2 Registering module:", moduleName, "^0")
    end
    -- remove __ENV as its not present in luajit at all from what ive read. Good find guys :P
    Bridge[moduleName] = wrappedModule

    exports(moduleName, function()
        return wrappedModule
    end)

    TriggerEvent("Bridge:Refresh", moduleName, wrappedModule)
end
exports("RegisterModule", Bridge.RegisterModule)

function Bridge.RegisterModuleFunction(moduleName, functionName, func)
    assert(moduleName and functionName and func, string.format("Bridge.RegisterModuleFunction(%s, %s, %s) - Invalid arguments", moduleName, functionName, func))
    Bridge[moduleName] = Bridge[moduleName] or {}
    Bridge[moduleName][functionName] = func
    TriggerEvent("Bridge:Refresh", moduleName, Bridge[moduleName])
end

Bridge.RegisterModule("Framework", Framework)
Bridge.RegisterModule("BossMenu", BossMenu)
Bridge.RegisterModule("Inventory", Inventory)
Bridge.RegisterModule("Notify", Notify)
Bridge.RegisterModule("HelpText", HelpText)
Bridge.RegisterModule("Clothing", Clothing)
Bridge.RegisterModule("Doorlock", Doorlock)
Bridge.RegisterModule("Phone", Phone)
Bridge.RegisterModule("Dispatch", Dispatch)
Bridge.RegisterModule("Shops", Shops)
Bridge.RegisterModule("Housing", Housing)
Bridge.RegisterModule("Version", Version)
Bridge.RegisterModule("Require", Require)
Bridge.RegisterModule("Skills", Skills)

for k, v in pairs(cLib) do
    if v then
        Bridge.RegisterModule(k, v)
    end
end

exports('Bridge', function()
    return Bridge
end)

if not IsDuplicityVersion() then goto client end
Bridge.RegisterModule('Version', Version)
Bridge.RegisterModule('Banking', Banking)

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