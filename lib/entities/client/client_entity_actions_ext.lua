DefaultActions = {}
ClientEntityActions = ClientEntityActions or Require("lib/entities/client/client_entity_actions.lua")
LA = LA or Require("lib/utility/shared/la.lua")

--- Internal implementation for walking. Registered via RegisterAction.
function DefaultActions.WalkTo(entityData, coords, speed, timeout)
    local entity = entityData.spawned
    local entityId = entityData.id -- Store ID locally for safety in thread

-- Helper Functions
local function validateEntity(entityData, requirePed)
    local entity, entityId = entityData.spawned, entityData.id
    local isValid = entity and DoesEntityExist(entity) and (not requirePed or IsEntityAPed(entity))

    if not isValid then
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId)
        return false
    end
    return true, entity, entityId
end

local function finishAction(entityId)
    if ClientEntityActions.IsActionRunning[entityId] then
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId)
    end
end

local function cleanupThread(entityId)
    ClientEntityActions.ActionThreads[entityId] = nil
end

-- Movement Actions
function DefaultActions.WalkTo(entityData, coords, speed, timeout)
    local isValid, entity, entityId = validateEntity(entityData, true)
    if not isValid then return end

    ClearPedTasks(entity)
    local thread = CreateThread(function()
        TaskGoToCoordAnyMeans(entity, coords.x, coords.y, coords.z, speed or 1.0, 0, false, 786603, timeout or -1)

        while ClientEntityActions.IsActionRunning[entityId]
            and entityData.spawned == entity
            and DoesEntityExist(entity)
            and #(GetEntityCoords(entity) - coords) > GROUND_CHECK_DISTANCE do
            Wait(0)
        end

        cleanupThread(entityId)
        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end
<<<<<<< HEAD

-- Animation Actions
=======
--- Internal implementation for playing an animation. Registered via RegisterAction.
--- @param entityData table
--- @param animDict string
--- @param animName string
--- @param blendIn number (Optional, default 8.0)
--- @param blendOut number (Optional, default -8.0)
--- @param duration number (Optional, default -1 for loop/until stopped)
--- @param flag number (Optional, default 0)
--- @param playbackRate number (Optional, default 0.0)
>>>>>>> aef40523bb62777acfff774230762518119d1c01
function DefaultActions.PlayAnim(entityData, animDict, animName, blendIn, blendOut, duration, flag, playbackRate)
    local isValid, entity, entityId = validateEntity(entityData, true)
    if not isValid then return end

    local params = {
        blendIn = blendIn or DEFAULT_BLEND_IN,
        blendOut = blendOut or DEFAULT_BLEND_OUT,
        duration = duration or DEFAULT_DURATION,
        flag = flag or DEFAULT_FLAG,
        playbackRate = playbackRate or DEFAULT_PLAYBACK_RATE
    }

    local thread = CreateThread(function()
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do Wait(0) end
        end

        if HasAnimDictLoaded(animDict) then
            TaskPlayAnim(entity, animDict, animName, params.blendIn, params.blendOut,
                params.duration, params.flag, params.playbackRate, false, false, false)

            local startTime = GetGameTimer()
            local animTime = params.duration > 0 and (startTime + params.duration) or -1

            while ClientEntityActions.IsActionRunning[entityId]
                and entityData.spawned == entity
                and DoesEntityExist(entity) do
                if not IsEntityPlayingAnim(entity, animDict, animName, 3)
                    and GetEntityAnimCurrentTime(entity, animDict, animName) > 0.1
                    and params.duration == -1 then
                    break
                end

                if animTime ~= -1 and GetGameTimer() >= animTime then break end
                Wait(100)
            end
        end

        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end

-- Movement with Physics Actions
function DefaultActions.LerpTo(entityData, targetCoords, duration, easingType, easingDirection)
    local isValid, entity, entityId = validateEntity(entityData, false)
    if not isValid then return end

    local startCoords = GetEntityCoords(entity)
    local startTime = GetGameTimer()
    local easing = {
        type = easingType or "linear",
        direction = easingDirection or "inout"
    }

    local thread = CreateThread(function()
        while GetGameTimer() < startTime + duration
            and ClientEntityActions.IsActionRunning[entityId]
            and entityData.spawned == entity
            and DoesEntityExist(entity) do
            local t = LA.Clamp((GetGameTimer() - startTime) / duration, 0.0, 1.0)
            local easedT = easing.direction == "in" and LA.EaseIn(t, easing.type)
                or easing.direction == "out" and LA.EaseOut(t, easing.type)
                or LA.EaseInOut(t, easing.type)

            local currentPos = LA.LerpVector(startCoords, targetCoords, easedT)
            SetEntityCoordsNoOffset(entity, currentPos.x, currentPos.y, currentPos.z, false, false, false)
            Wait(0)
        end

        if ClientEntityActions.IsActionRunning[entityId] and DoesEntityExist(entity) then
            SetEntityCoordsNoOffset(entity, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false)
        end

        cleanupThread(entityId)
        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end
<<<<<<< HEAD
=======
--- Internal implementation for attaching a prop. Registered via RegisterAction.
--- This action completes immediately after attaching. Use DetachProp to remove.
--- @param entityData table
--- @param propModel string|number
--- @param boneIndex number (Optional, default -1 for root)
--- @param offsetPos vector3 (Optional, default vector3(0,0,0))
--- @param offsetRot vector3 (Optional, default vector3(0,0,0))
--- @param useSoftPinning boolean (Optional, default false)
--- @param collision boolean (Optional, default false)
--- @param isPed boolean (Optional, default false) - Seems unused in native?
--- @param vertexIndex number (Optional, default 2) - Seems unused in native?
--- @param fixedRot boolean (Optional, default true)
function DefaultActions.AttachProp(entityData, propModel, boneName, offsetPos, offsetRot, useSoftPinning, collision, isPed, vertexIndex, fixedRot)
    local entity = entityData.spawned
    local entityId = entityData.id
>>>>>>> aef40523bb62777acfff774230762518119d1c01

-- Prop Management Actions
function DefaultActions.AttachProp(entityData, propModel, boneName, offsetPos, offsetRot, useSoftPinning, collision,
                                   isPed, vertexIndex, fixedRot)
    local isValid, entity, entityId = validateEntity(entityData, false)
    if not isValid then return end

    local modelHash = Utility.GetEntityHashFromModel(propModel)
    if not Utility.LoadModel(modelHash) then
<<<<<<< HEAD
        print(string.format("[ClientEntityActions] Failed to load prop model '%s' for entity %s", propModel, entityId))
        finishAction(entityId)
=======
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId)
>>>>>>> aef40523bb62777acfff774230762518119d1c01
        return
    end

    local params = {
        boneIndex = GetEntityBoneIndexByName(entity, boneName) or GetPedBoneIndex(entity, 60309),
        offsetPos = offsetPos or vector3(0.0, 0.0, 0.0),
        offsetRot = offsetRot or vector3(0.0, 0.0, 0.0),
        useSoftPinning = useSoftPinning or false,
        collision = collision or false,
        isPed = isPed or false,
        vertexIndex = vertexIndex or 2,
        fixedRot = fixedRot == nil and true or fixedRot
    }
    params.boneIndex = params.boneIndex == -1 and 0 or params.boneIndex

    local coords = GetEntityCoords(entity)
    local prop = CreateObject(modelHash, coords.x, coords.y, coords.z, false, false, false)
    SetModelAsNoLongerNeeded(modelHash)

<<<<<<< HEAD
    AttachEntityToEntity(prop, entity, params.boneIndex,
        params.offsetPos.x, params.offsetPos.y, params.offsetPos.z,
        params.offsetRot.x, params.offsetRot.y, params.offsetRot.z,
        false, params.useSoftPinning, params.collision,
        params.isPed, params.vertexIndex, params.fixedRot)
=======
    boneIndex = boneIndex or GetPedBoneIndex(entity, 60309) -- SKEL_R_Hand if not specified and is ped
    if boneIndex == -1 then boneIndex = 0 end -- Default to root if bone not found or not ped
    offsetPos = offsetPos or vector3(0.0, 0.0, 0.0)
    offsetRot = offsetRot or vector3(0.0, 0.0, 0.0)
    AttachEntityToEntity(prop, entity, boneIndex, offsetPos.x, offsetPos.y, offsetPos.z, offsetRot.x, offsetRot.y, offsetRot.z, false, useSoftPinning or false, collision or false, isPed or false, vertexIndex or 2, fixedRot == nil and true or fixedRot)
    entityData.props = entityData.props or {} -- Ensure props table exists
    table.insert(entityData.props, prop) -- Store the prop handle in the entity data
    -- Store the attached prop handle for later removal
    if not entityData.attachedProps then entityData.attachedProps = {} end
    entityData.attachedProps[propModel] = prop -- Store by model name/hash for easy lookup
>>>>>>> aef40523bb62777acfff774230762518119d1c01

    if not entityData.attachedProps then entityData.attachedProps = {} end
    entityData.attachedProps[propModel] = prop

    finishAction(entityId)
end
<<<<<<< HEAD

=======
--- Internal implementation for detaching a prop. Registered via RegisterAction.
--- @param entityData table
--- @param propModel string|number The model name/hash of the prop to detach.
>>>>>>> aef40523bb62777acfff774230762518119d1c01
function DefaultActions.DetachProp(entityData, propModel)
    local entityId = entityData.id

    if entityData.attachedProps and propModel then
        local propHandle = entityData.attachedProps[propModel]
        if propHandle and DoesEntityExist(propHandle) then
            DetachEntity(propHandle, true, true)
            DeleteEntity(propHandle)
            entityData.attachedProps[propModel] = nil
        end
    end

    finishAction(entityId)
end

-- Vehicle Actions
function DefaultActions.GetInCar(entityData, vehicleData, seatIndex, timeout)
    local isValid, entity, entityId = validateEntity(entityData, true)
    if not isValid then return end

    if not vehicleData.spawned or not DoesEntityExist(vehicleData.spawned) or not IsEntityAVehicle(vehicleData.spawned) then
        finishAction(entityId)
        return
    end
    ClearPedTasks(entity)
    local thread = CreateThread(function()
        TaskEnterVehicle(entity, vehicleData.spawned, timeout or 1000, seatIndex or -1, 1.0, 1, 0)
        Wait(timeout or 1000)

        cleanupThread(entityId)
        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end

<<<<<<< HEAD
-- Movement Effects
=======
function DefaultActions.Freeze(entityData, freeze)
    local entity = entityData.spawned
    local entityId = entityData.id

    if not entity or not DoesEntityExist(entity) then
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId) -- Try next action if this one failed immediately
        return
    end

    FreezeEntityPosition(entity, freeze or true)

    -- This action finishes immediately
    ClientEntityActions.IsActionRunning[entityId] = false
    ClientEntityActions.ProcessNextAction(entityId)
end

function DefaultActions.PlaceOnGround(entityData)
    local entity = entityData.spawned
    local entityId = entityData.id

    if not entity or not DoesEntityExist(entity) then
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId) -- Try next action if this one failed immediately
        return
    end
    PlaceObjectOnGroundProperly(entity)

    -- This action finishes immediately
    -- ClientEntityActions.IsActionRunning[entityId] = false
    -- ClientEntityActions.ProcessNextAction(entityId)
end

function DefaultActions.BobUpAndDown(entityData, speed, height)
    local entity = entityData.spawned
    local entityId = entityData.id
    if not entity or not DoesEntityExist(entity) then
        ClientEntityActions.IsActionRunning[entityId] = false
        ClientEntityActions.ProcessNextAction(entityId) -- Try next action if this one failed immediately
        return
    end
    CreateThread(function()
        local coords = GetEntityCoords(entity)
        local originalZ = coords.z
        while DoesEntityExist(entity) do
            -- Calculate the new Z coordinate
            local newZ = originalZ + math.sin(GetGameTimer() * (speed / 1000)) * height
            -- Set the new coordinates
            SetEntityCoords(entity, coords.x, coords.y, newZ)
            -- Wait for 10 milliseconds
            Wait(10)
        end
    end)
    -- ClientEntityActions.IsActionRunning[entityId] = false
    -- ClientEntityActions.ProcessNextAction(entityId) -- Try next action if this one failed immediately
end

>>>>>>> aef40523bb62777acfff774230762518119d1c01
function DefaultActions.Circle(entityData, radius, speed)
    local isValid, entity, entityId = validateEntity(entityData, false)
    if not isValid then return end

    local coords = GetEntityCoords(entity)
    local angle = 0.0

    CreateThread(function()
        while DoesEntityExist(entity) do
            FreezeEntityPosition(entity, false)
            local pos = LA.Circle(angle, radius, coords)
            SetEntityCoords(entity, pos.x, pos.y, pos.z, false, false, false, false)
            angle = angle + speed * GetFrameTime()
            FreezeEntityPosition(entity, true)
            Wait(0)
        end
    end)
end

<<<<<<< HEAD
function DefaultActions.BobUpAndDown(entityData, speed, height)
    local isValid, entity, entityId = validateEntity(entityData, false)
    if not isValid then return end

    local coords = GetEntityCoords(entity)
    CreateThread(function()
        while DoesEntityExist(entity) do
            local newZ = coords.z + math.sin(GetGameTimer() * (speed / 1000)) * height
            SetEntityCoords(entity, coords.x, coords.y, newZ)
            Wait(10)
        end
    end)
end

-- Register all actions
=======
function DefaultActions.Collisions(entityData, enable, keepPhysics)
    local entity = entityData.spawned
    SetEntityCollision(entity, enable, keepPhysics)
end

>>>>>>> aef40523bb62777acfff774230762518119d1c01
for name, func in pairs(DefaultActions) do
    ClientEntityActions.RegisterAction(name, func)
end

return ClientEntityActions
