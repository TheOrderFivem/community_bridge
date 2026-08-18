loadedModules = {}

function Require(modulePath, resourceName)
    if resourceName and type(resourceName) ~= "string" then
        resourceName = GetInvokingResource()
    end

    if not resourceName then
        resourceName = "community_bridge"
    end

    local id = resourceName .. ":" .. modulePath
    if loadedModules[id] then
        return loadedModules[id]
    end

    local file = LoadResourceFile(resourceName, modulePath)
    if not file then
        error("Error loading file [" .. id .. "]")
    end

    local chunk, loadErr = load(file, id)
    if not chunk then
        error("Error wrapping module [" .. id .. "] Message: " .. loadErr)
    end

    local success, result = pcall(chunk)
    if not success then
        error("Error executing module [" .. id .. "] Message: " .. result)
    end
    loadedModules[id] = result
    return result
end



cLib = {
    Require = Require,
}

exports('cLib', cLib)

if not IsDuplicityVersion() then goto client end

cLib.Logs = Logs or Require("lib/logs/server/logs.lua")
cLib.Entity = ServerEntity or Require("lib/entities/server/server_entity.lua")

-- Depricated 
cLib.ServerEntity = cLib.Entity

if IsDuplicityVersion() then return cLib end
::client::

cLib.Placeable = Placeable or Require("lib/placers/client/object_placer.lua")
cLib.Utility = Utility or Require("lib/utility/client/utility.lua")
cLib.PlaceableObject = ObjectPlacer or Require("lib/placers/client/placeable_object.lua")
cLib.Point = Point or Require("lib/points/client/points.lua")
cLib.Entity = ClientEntity or Require("lib/entities/client/client_entity.lua")

-- Deprecated
cLib.ClientEntity = cLib.Entity

return cLib