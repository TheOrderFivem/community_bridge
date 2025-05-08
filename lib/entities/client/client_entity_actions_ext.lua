DefaultActions = {}
ClientEntityActions = ClientEntityActions or Require("lib/entities/client/client_entity_actions.lua")

-- Helper Functions
local function validateEntity(entityData, requirePed)
    local entity = entityData.spawned
    local entityId = entityData.id

    if not entity or not DoesEntityExist(entity) or (requirePed and not IsEntityAPed(entity)) then
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

        local entityCoords = GetEntityCoords(entity)
        while ClientEntityActions.IsActionRunning[entityId]
            and entityData.spawned == entity
            and DoesEntityExist(entity)
            and #(entityCoords - coords) > 2.0 do
            entityCoords = GetEntityCoords(entity)
            Wait(0)
        end

        cleanupThread(entityId)
        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end

-- Animation Actions
function DefaultActions.PlayAnim(entityData, animDict, animName, blendIn, blendOut, duration, flag, playbackRate)
    local isValid, entity, entityId = validateEntity(entityData, true)
    if not isValid then return end

    local params = {
        blendIn = blendIn or 8.0,
        blendOut = blendOut or -8.0,
        duration = duration or -1,
        flag = flag or 0,
        playbackRate = playbackRate or 0.0
    }

    local thread = CreateThread(function()
        -- Load animation dictionary
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            local timeout = 100
            while not HasAnimDictLoaded(animDict) and timeout > 0 do
                Wait(10)
                timeout = timeout - 1
            end
        end

        if HasAnimDictLoaded(animDict) then
            TaskPlayAnim(entity, animDict, animName, params.blendIn, params.blendOut,
                params.duration, params.flag, params.playbackRate, false, false, false)

            local startTime = GetGameTimer()
            local animTime = params.duration > 0 and (startTime + params.duration) or -1

            -- Animation monitoring loop
            while ClientEntityActions.IsActionRunning[entityId]
                and entityData.spawned == entity
                and DoesEntityExist(entity) do
                local isPlaying = IsEntityPlayingAnim(entity, animDict, animName, 3)

                -- Check break conditions
                if not isPlaying and GetEntityAnimCurrentTime(entity, animDict, animName) > 0.1
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
    local params = {
        easingType = easingType or "linear",
        easingDirection = easingDirection or "inout"
    }

    local thread = CreateThread(function()
        while GetGameTimer() < startTime + duration do
            if not ClientEntityActions.IsActionRunning[entityId]
                or not entityData.spawned
                or entityData.spawned ~= entity
                or not DoesEntityExist(entity) then
                break
            end

            local elapsed = GetGameTimer() - startTime
            local t = LA.Clamp(elapsed / duration, 0.0, 1.0)
            local easedT = LA.EaseInOut(t, params.easingType)

            if params.easingDirection == "in" then
                easedT = LA.EaseIn(t, params.easingType)
            elseif params.easingDirection == "out" then
                easedT = LA.EaseOut(t, params.easingType)
            end

            local currentPos = LA.LerpVector(startCoords, targetCoords, easedT)
            SetEntityCoordsNoOffset(entity, currentPos.x, currentPos.y, currentPos.z, false, false, false)
            Wait(0)
        end

        if ClientEntityActions.IsActionRunning[entityId]
            and entityData.spawned == entity
            and DoesEntityExist(entity) then
            SetEntityCoordsNoOffset(entity, targetCoords.x, targetCoords.y, targetCoords.z, false, false, false)
        end

        cleanupThread(entityId)
        finishAction(entityId)
    end)
    ClientEntityActions.ActionThreads[entityId] = thread
end

-- Prop Management Actions
function DefaultActions.AttachProp(entityData, propModel, boneName, offsetPos, offsetRot, useSoftPinning, collision,
                                   isPed, vertexIndex, fixedRot)
    local isValid, entity, entityId = validateEntity(entityData, false)
    if not isValid then return end

    local modelHash = Utility.GetEntityHashFromModel(propModel)
    if not Utility.LoadModel(modelHash) then
        print(string.format("[ClientEntityActions] Failed to load prop model '%s' for entity %s", propModel, entityId))
        finishAction(entityId)
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

    AttachEntityToEntity(prop, entity, params.boneIndex,
        params.offsetPos.x, params.offsetPos.y, params.offsetPos.z,
        params.offsetRot.x, params.offsetRot.y, params.offsetRot.z,
        false, params.useSoftPinning, params.collision,
        params.isPed, params.vertexIndex, params.fixedRot)

    if not entityData.attachedProps then entityData.attachedProps = {} end
    entityData.attachedProps[propModel] = prop

    finishAction(entityId)
end

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

-- Register all actions
for name, func in pairs(DefaultActions) do
    ClientEntityActions.RegisterAction(name, func)
end

return ClientEntityActions
