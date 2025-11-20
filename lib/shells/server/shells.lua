Ids = Ids or Require("lib/utility/shared/ids.lua")
Shells = Shells or {}
Shells.All = Shells.All or {}
Shells.ActivePlayers = Shells.ActivePlayers or {} -- Track players in shells

Shells.Interactable = Shells.Interactable or {}
Shells.BucketsInUse = Shells.BucketsInUse or {} -- Track buckets in use

function Shells.Interactable.New(_type, id, model, coords, rotation, entityType, distance, meta)
    assert(_type, "Shells.Interactable.Create: 'type' is required")
    assert(id, "Shells.Interactable.Create: 'name' is required")
    assert(coords, "Shells.Interactable.Create: 'coords' is required")
    return {
        type = _type,
        id = id,
        model = model,
        coords = coords,
        rotation = rotation or vector3(0.0, 0.0, 0.0),
        distance = distance or 2.0,
        entityType = entityType or "object", -- Default entity type
        meta = meta or {},
    }
end

function Shells.New(data)
    local id = data.id or Ids.CreateUniqueId(Shells.All)
    local model = data.model
    local size = data.size or vector3(10.0, 10.0, 10.0) -- Default size if not provided
    local coords = data.coords or vector3(0.0, 0.0, 0.0) -- Default coordinates if not provided
    local rotation = data.rotation or vector3(0.0, 0.0, 0.0) -- Default rotation if not provided
    local interior = data.interior or {}
    local exterior = data.exterior or {}
    local bucket = data.bucket or Ids.RandomNumber(Shells.BucketsInUse, 4)
    assert(id, "Shells.Create: 'id' is required")
    assert(model, "Shells.Create: 'shellModel' is required")
    assert(coords, "Shells.Create: 'coords' is required")

    local interiorInteractions = {}
    for k, v in pairs(interior or {}) do
        local interiorCoords = coords + (v.offset or vector3(0.0, 0.0, 0.0))
        local interaction = Shells.Interactable.New(
            v.type or "none",
            v.id or Ids.CreateUniqueId(interiorInteractions),
            v.model,
            interiorCoords,
            v.rotation or vector3(0.0, 0.0, 0.0),
            v.entityType or "object", -- Default entity type for interior interactions
            v.distance or 2.0,
            v.meta
        )
        interiorInteractions[interaction.id] = interaction
    end

    local exteriorInteractions = {}
    for k, v in pairs(exterior or {}) do
        local interaction = Shells.Interactable.New(
            v.type or "none",
            v.id or Ids.CreateUniqueId(exteriorInteractions),
            v.model,
            v.coords,
            v.rotation or vector3(0.0, 0.0, 0.0),
            v.entityType or "object", -- Default entity type for exterior interactions
            v.distance or 2.0,
            v.meta
        )
        exteriorInteractions[interaction.id] = interaction
    end

    local shellData = {
        id = id,
        type = _type,
        entityType = "object", -- Default entity type for shells
        model = model,
        coords = coords,
        size = size or vector3(10.0, 10.0, 10.0), -- Default size if not provided
        rotation = rotation or vector3(0.0, 0.0, 0.0),
        interior = interiorInteractions,
        exterior = exteriorInteractions,
    }

    Shells.All[id] = shellData
    return shellData
end

function Shells.Create(data)
    local shell = Shells.New(data)
    assert(shell, "Shells.Create: 'shell' is required")
    TriggerClientEvent('community_bridge:client:CreateShell', -1, shell)
    return shell
end

function Shells.CreateBulk(shells)
    assert(shells, "Shells.CreateBulk: 'shells' is required")
    assert(type(shells) == "table", "Shells.CreateBulk: 'shells' must be a table")
    local toClient = {}
    for _, shellData in pairs(shells) do
        local shell = Shells.New(shellData)
        toClient[shell.id] = shell
    end
    TriggerClientEvent('community_bridge:client:CreateShells', -1, toClient)
end

function Shells.Enter(src, shellId, entranceId)
    src = tonumber(src)
    assert(src, "Shells.EnterShell: 'src' is required")
    assert(shellId, "Shells.EnterShell: 'shellId' is required")
    print(shellId)
    local shell = Shells.All[shellId]
    assert(shell, "Shell not found: " .. tostring(shellId))
    if shell.onEnter then
        local canEnter = shell.onEnter(src, shellId)
        if not canEnter then return false end
    end
    if not shell.bucket then
        local randNum = Ids.RandomNumber(Shells.BucketsInUse, 4)
        shell.bucket = tonumber(randNum)
        Shells.BucketsInUse[tostring(randNum)] = true
    end
    print(shell.bucket)
    SetPlayerRoutingBucket(src, shell.bucket)
    local exit = shell.exterior[entranceId]?.meta?.link
    TriggerClientEvent('community_bridge:client:EnterShell', src, shellId, exit, Shells.ActivePlayers[tostring(src)])
    Shells.ActivePlayers[tostring(src)] = shellId
    return true
end


function Shells.Exit(src, shellId, oldId)

    print(oldId)
    src = tonumber(src)
    assert(src, "Shells.ExitShell: 'src' is required")
    assert(shellId, "Player is not in a shell")

    local shell = Shells.All[shellId]
    assert(shell, "Shell not found: " .. tostring(shellId))

    -- Restore original routing bucket
    SetPlayerRoutingBucket(src, 0)
    local exit = shell.interior[oldId]?.meta?.link
    -- Clear player's shell data
    Shells.ActivePlayers[tostring(src)] = nil
    if shell.onExit then
        shell.onExit(src, shellId)
    end
    TriggerClientEvent('community_bridge:client:ExitShell', src, shellId, exit)
    return true
end


function Shells.Get(shellId)
    assert(shellId, "Shells.GetShellById: 'shellId' is required")
    return Shells.All[shellId]
end

function Shells.Inside(src)
    src = tonumber(src)
    assert(src, "Shells.IsInside: 'src' is required")

    local shellId = Shells.ActivePlayers[tostring(src)]
    if not shellId then
        return false
    end

    local shell = Shells.All[shellId]
    if not shell then
        return false
    end

    return shell
end

function Shells.AddObjects(shellId, objects)
    assert(shellId, "Shells.AddObjects: 'shellId' is required")
    assert(objects, "Shells.AddObjects: 'objects' is required")
    assert(type(objects) == "table", "Shells.AddObjects: 'objects' must be a table")

    local shell = Shells.All[shellId]
    assert(shell, "Shell not found: " .. tostring(shellId))

    local interiors = objects.interior or {}
    local exteriors = objects.exterior or {}
    for _, objData in pairs(interiors) do
        local obj = Shells.Interactable.New(
            objData.type,
            objData.id,
            objData.model,
            objData.coords,
            objData.rotation,
            objData.entityType,
            objData.distance,
            objData.meta
        )
        shell.interior[obj.id] = obj -- Update the shell's interior with the new object
    end
    for _, objData in pairs(exteriors) do
        local obj = Shells.Interactable.New(
            objData.type,
            objData.id,
            objData.model,
            objData.coords,
            objData.rotation,
            objData.entityType,
            objData.distance,
            objData.meta
        )
        shell.exterior[obj.id] = obj -- Update the shell's exterior with the new object
    end

    TriggerClientEvent('community_bridge:client:AddObjectsToShell', -1, shellId, shell.interior, shell.exterior)
    return shell
end

function Shells.RemoveObjects(shellId, objectIds)
    assert(shellId, "Shells.RemoveObjects: 'shellId' is required")
    assert(objectIds, "Shells.RemoveObjects: 'objects' is required")
    if type(objectIds) ~= "table" then
        objectIds = {objectIds} -- Ensure it's a table
    end

    local shell = Shells.All[shellId]
    assert(shell, "Shell not found: " .. tostring(shellId))

    for _, objId in pairs(objectIds) do
        shell.interior[objId] = nil
        shell.exterior[objId] = nil
    end

    TriggerClientEvent('community_bridge:client:RemoveObjectsFromShell', -1, shellId, objectIds)
    return shell
end

RegisterNetEvent('community_bridge:server:EnterShell', function(shellId, entranceId)
    local src = source
    Shells.Enter(src, shellId, entranceId)
end)

RegisterNetEvent('community_bridge:server:ExitShell', function(shellId, oldId)
    local src = source
    Shells.Exit(src, shellId, oldId)
end)

AddEventHandler('onPlayerJoining', function(playerId)
    local src = source
    TriggerClientEvent('community_bridge:client:CreateShells', src, Shells.All)
end)

function Shells.GetInteractable(shellId, id)
    assert(shellId, "Shells.GetInteractable: 'shellId' is required")
    assert(id, "Shells.GetInteractable: 'id' is required")

    local shell = Shells.All[shellId]
    if not shell then
        return nil, "Shell not found: " .. tostring(shellId)
    end

    local interactable = shell.interior[id] or shell.exterior[id]
    if not interactable then
        return nil, "Interactable not found: " .. tostring(id)
    end

    return interactable
end

function Shells.GetClosestInteractable(shellId, coords, exterior)
    assert(shellId, "Shells.GetClosestInteriorInteractable: 'shellId' is required")
    assert(coords, "Shells.GetClosestInteriorInteractable: 'coords' is required")

    local shell = Shells.All[shellId]
    if not shell then
        return nil, "Shell not found: " .. tostring(shellId)
    end

    local closest = nil
    local closestDistance = math.huge
    if exterior then
        for _, interactable in pairs(shell.exterior) do
            local distance = #(coords - interactable.coords)
            if distance < closestDistance then
                closestDistance = distance
                closest = interactable
            end
        end
        return closest, closestDistance
    end

    for _, interactable in pairs(shell.interior) do
        local distance = #(coords - interactable.coords)
        if distance < closestDistance then
            closestDistance = distance
            closest = interactable
        end
    end
    return closest, closestDistance
end

local testShell = nil
RegisterCommand('shells:create', function(source, args, rawCommand)
    local coords = GetEntityCoords(GetPlayerPed(source))
    if testShell then
        Shells.Exit(source, testShell.id, 'exit1') -- Exit previous shell if it exists
    end
    testShell = Shells.Create({
        id = Ids.CreateUniqueId(Shells.All),
        model = "shell_garagem",
        coords = coords + vector3(0.0, 0.0, 100.0), -- Adjusted to place shell slightly below player
        rotation = vector3(0.0, 0.0, 0.0),
        size = vector3(10.0, 10.0, 10.0),
        interior = {
            {
                id = 'exit1',
                type = 'exit',
                coords = coords + vector3(0.0, 0.0, 1.0),
                rotation = vector3(0.0, 0.0, 0.0),
                distance = 2.0,
                meta = {
                    link = 'entrance1',
                }
            }
        },
        exterior = {
            {
                id = 'entrance1',
                type = 'entrance',
                -- entityType = "object",
                -- model = "xm_int_lev_sub_chair_02",
                coords = coords - vector3(0.0, 0.0, 0.5),
                rotation = vector3(0.0, 0.0, 0.0),
                distance = 2.0,
                meta = {
                    link = 'exit1',
                }
            }
        },
    })
end, true)

RegisterCommand('shells:addobject', function(source, args, rawCommand)
    if not testShell then
        print("No shell created. Use /shells:create first.")
        return
    end
    local model = args[1]
    if not model then
        print("Usage: /shells:addobject <shellId> <model>")
        return
    end

    local shellId = testShell.id
    local coords = GetEntityCoords(GetPlayerPed(source))
    local objectData = {
        type = "none",
        entityType = "ped",
        id = Ids.CreateUniqueId(Shells.All[shellId].interior),
        model = model,
        coords = coords - vector3(0.0, 0.0, 0.5), -- Adjusted to place object slightly above player
        rotation = vector3(0.0, 0.0, 0.0),
        distance = 2.0,
        meta = {}
    }
    Shells.AddObjects(shellId, {interior = {objectData}})
end, true)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for src, shellId in pairs(Shells.ActivePlayers) do
            SetPlayerRoutingBucket(tonumber(src), 0) -- Reset routing bucket for all players
        end
    end
end)

AddEventHandler('community_bridge:Server:OnPlayerUnload', function(src)
    if not Shells.ActivePlayers[tostring(src)] then return end
    print(string.format("Player %d is exiting shell %s", src, Shells.ActivePlayers[tostring(src)]))
    Shells.Exit(src, Shells.ActivePlayers[tostring(src)])
    Shells.ActivePlayers[tostring(src)] = nil
end)