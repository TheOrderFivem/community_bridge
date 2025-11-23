Scaleform = Scaleform or Require("lib/scaleform/client/scaleform.lua")
Utility = Utility or Require("lib/utility/client/utility.lua")
Raycast = Raycast or Require("lib/raycast/client/raycast.lua")
Language = Language or Require("modules/locales/shared.lua")

PlaceableObject = PlaceableObject or {}

-- Register key mappings for placement controls
RegisterKeyMapping('+place_object', locale('placeable_object.object_place'), 'mouse_button', 'MOUSE_LEFT')
RegisterKeyMapping('+cancel_placement', locale('placeable_object.object_cancel'), 'mouse_button', 'MOUSE_RIGHT')
RegisterKeyMapping('+rotate_left', locale('placeable_object.rotate_left'), 'keyboard', 'LEFT')
RegisterKeyMapping('+rotate_right', locale('placeable_object.rotate_right'), 'keyboard', 'RIGHT')
RegisterKeyMapping('+scroll_up', locale('placeable_object.object_scroll_up'), 'mouse_wheel', 'IOM_WHEEL_UP')
RegisterKeyMapping('+scroll_down', locale('placeable_object.object_scroll_down'), 'mouse_wheel', 'IOM_WHEEL_DOWN')
RegisterKeyMapping('+depth_modifier', locale('placeable_object.depth_modifier'), 'keyboard', 'LCONTROL')
-- shift
RegisterKeyMapping('+toggle_vertical', "derp", 'keyboard', 'LSHIFT')

local state = {
    isPlacing = false,
    currentEntity = nil,
    mode = 'normal', -- 'normal' or 'movement'
    promise = nil,
    scaleform = nil,
    lastPos = nil,
    offset = vector3(0.0, 0.0, 0.0),

    -- Placement settings
    depth = 2.0,
    heading = 0.0,
    height = 0.0,
    snapToGround = true,
    paused = false,

    -- Current settings
    settings = {},
    boundaryCheck = nil,

    -- Key press states
    keys = {
        placeObject = false,
        cancelPlacement = false,
        rotateLeft = false,
        rotateRight = false,
        scrollUp = false,
        scrollDown = false,
        depthModifier = false
    }
}

local placementText = {
    string.format(locale('placeable_object.object_place'), Utility.GetCommandKey('+place_object')),
    string.format(locale('placeable_object.object_cancel'), Utility.GetCommandKey('+cancel_placement')),
    string.format(locale('placeable_object.rotate_clockwise'), Utility.GetCommandKey('+scroll_up')),
    string.format(locale('placeable_object.rotate_counter_clockwise'), Utility.GetCommandKey('+scroll_down')),
    string.format(locale('placeable_object.depth_modifier'), Utility.GetCommandKey('+depth_modifier')),
    string.format(locale('placeable_object.toggle_vertical'), Utility.GetCommandKey('+toggle_vertical'))
}

-- Command handlers for key mappings
RegisterCommand('+place_object', function()
    if state.isPlacing then
        state.keys.placeObject = true
    end
end, false)

RegisterCommand('-place_object', function()
    state.keys.placeObject = false
end, false)

RegisterCommand('+cancel_placement', function()
    if state.isPlacing then
        state.keys.cancelPlacement = true
    end
end, false)

RegisterCommand('-cancel_placement', function()
    state.keys.cancelPlacement = false
end, false)

RegisterCommand('+rotate_left', function()
    if state.isPlacing then
        state.keys.rotateLeft = true
    end
end, false)

RegisterCommand('-rotate_left', function()
    state.keys.rotateLeft = false
end, false)

RegisterCommand('+rotate_right', function()
    if state.isPlacing then
        state.keys.rotateRight = true
    end
end, false)

RegisterCommand('-rotate_right', function()
    state.keys.rotateRight = false
end, false)

RegisterCommand('+scroll_up', function()
    if state.isPlacing then
        state.keys.scrollUp = true
    end
end, false)

RegisterCommand('-scroll_up', function()
    state.keys.scrollUp = false
end, false)

RegisterCommand('+scroll_down', function()
    if state.isPlacing then
        state.keys.scrollDown = true
    end
end, false)

RegisterCommand('-scroll_down', function()
    state.keys.scrollDown = false
end, false)

RegisterCommand('+depth_modifier', function()
    if state.isPlacing then
        state.keys.depthModifier = true
    end
end, false)

RegisterCommand('-depth_modifier', function()
    state.keys.depthModifier = false
end, false)

RegisterCommand('+toggle_vertical', function()
    if not state.settings.allowVertical then return end
    if state.snapToGround then return end
    state.verticle = true
end, false)

RegisterCommand('-toggle_vertical', function()
    state.verticle = false
end, false)

-- Utility functions
local function getMouseWorldPos(depth)
    local screenX = GetDisabledControlNormal(0, 239)
    local screenY = GetDisabledControlNormal(0, 240)

    local world, normal = GetWorldCoordFromScreenCoord(screenX, screenY)
    local playerPos = GetEntityCoords(PlayerPedId())
    return playerPos + normal * depth
end

local function checkMaterialAndBoundary()
    if not state.currentEntity then return true end

    local pos = GetEntityCoords(state.currentEntity)
    local inBounds = Bridge.Math.InBoundary(pos, state.settings.boundary)

    -- Check built-in boundary first
    if state.settings.boundary and not inBounds then return false end

    -- Check custom boundary function if provided
    if state.settings.customCheck then
        local customResult = state.settings.customCheck(pos, state.currentEntity, state.settings)
        if not customResult then return false end
    end

    -- Check allowed materials
    if state.settings.allowedMats then
        local hit, _, _, _, materialHash = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z + 1.0, pos.x, pos.y, pos.z - 5.0, -1, 0, 7))
        if hit == 1 then
            for _, allowedMat in ipairs(state.settings.allowedMats) do
                if materialHash == GetHashKey(allowedMat) then
                    return inBounds
                end
            end
            return false
        end
    end

    return inBounds
end

local function checkMaterialAndBoundaryDetailed()
    if not state.currentEntity then return true, true, true end

    local pos = GetEntityCoords(state.currentEntity)
    local inBounds = Bridge.Math.InBoundary(pos, state.settings.boundary)
    local customCheckPassed = true
    local materialCheckPassed = true

    -- Check built-in boundary first
    if state.settings.boundary and not inBounds then
        return false, false, customCheckPassed
    end

    -- Check custom boundary function if provided
    if state.settings.customCheck then
        customCheckPassed = state.settings.customCheck(pos, state.currentEntity, state.settings)
        if not customCheckPassed then
            return false, inBounds, false
        end
    end

    -- Check allowed materials
    if state.settings.allowedMats then
        local hit, _, _, _, materialHash = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z + 1.0, pos.x, pos.y, pos.z - 5.0, -1, 0, 7))
        if hit == 1 then
            for _, allowedMat in ipairs(state.settings.allowedMats) do
                if materialHash == GetHashKey(allowedMat) then
                    return inBounds, inBounds, customCheckPassed
                end
            end
            materialCheckPassed = false
            return false, inBounds, customCheckPassed
        end
    end

    return inBounds, inBounds, customCheckPassed
end

local function drawBoundaryBox(boundary)
    if not boundary then return end

    -- Handle legacy min/max boundary format for backwards compatibility
    if boundary.min and boundary.max then
        local min = boundary.min
        local max = boundary.max

        -- Define the 8 corners of the box
        local corners = {
            vector3(min.x, min.y, min.z), -- 1
            vector3(max.x, min.y, min.z), -- 2
            vector3(max.x, max.y, min.z), -- 3
            vector3(min.x, max.y, min.z), -- 4
            vector3(min.x, min.y, max.z), -- 5
            vector3(max.x, min.y, max.z), -- 6
            vector3(max.x, max.y, max.z), -- 7
            vector3(min.x, max.y, max.z), -- 8
        }

        -- Draw wireframe box
        local r, g, b, a = 0, 255, 0, 100

        -- Bottom face
        DrawLine(corners[1].x, corners[1].y, corners[1].z, corners[2].x, corners[2].y, corners[2].z, r, g, b, a)
        DrawLine(corners[2].x, corners[2].y, corners[2].z, corners[3].x, corners[3].y, corners[3].z, r, g, b, a)
        DrawLine(corners[3].x, corners[3].y, corners[3].z, corners[4].x, corners[4].y, corners[4].z, r, g, b, a)
        DrawLine(corners[4].x, corners[4].y, corners[4].z, corners[1].x, corners[1].y, corners[1].z, r, g, b, a)

        -- Top face
        DrawLine(corners[5].x, corners[5].y, corners[5].z, corners[6].x, corners[6].y, corners[6].z, r, g, b, a)
        DrawLine(corners[6].x, corners[6].y, corners[6].z, corners[7].x, corners[7].y, corners[7].z, r, g, b, a)
        DrawLine(corners[7].x, corners[7].y, corners[7].z, corners[8].x, corners[8].y, corners[8].z, r, g, b, a)
        DrawLine(corners[8].x, corners[8].y, corners[8].z, corners[5].x, corners[5].y, corners[5].z, r, g, b, a)

        -- Vertical edges
        DrawLine(corners[1].x, corners[1].y, corners[1].z, corners[5].x, corners[5].y, corners[5].z, r, g, b, a)
        DrawLine(corners[2].x, corners[2].y, corners[2].z, corners[6].x, corners[6].y, corners[6].z, r, g, b, a)
        DrawLine(corners[3].x, corners[3].y, corners[3].z, corners[7].x, corners[7].y, corners[7].z, r, g, b, a)
        DrawLine(corners[4].x, corners[4].y, corners[4].z, corners[8].x, corners[8].y, corners[8].z, r, g, b, a)
        return
    end

    -- Handle list of points (polygon boundary)
    if boundary.points and #boundary.points > 0 then
        local points = boundary.points
        local minZ = boundary.minZ or 0
        local maxZ = boundary.maxZ or 50
        local r, g, b, a = 0, 255, 0, 100

        -- Draw bottom polygon outline
        for i = 1, #points do
            local currentPoint = points[i]
            local nextPoint = points[i % #points + 1] -- Wrap around to first point

            local x1, y1 = currentPoint.x or currentPoint[1], currentPoint.y or currentPoint[2]
            local x2, y2 = nextPoint.x or nextPoint[1], nextPoint.y or nextPoint[2]

            -- Bottom edge
            DrawLine(x1, y1, minZ, x2, y2, minZ, r, g, b, a)

            -- Top edge
            DrawLine(x1, y1, maxZ, x2, y2, maxZ, r, g, b, a)

            -- Vertical edge
            DrawLine(x1, y1, minZ, x1, y1, maxZ, r, g, b, a)
        end
        return
    end
end

local function drawEntityBoundingBox(entity, inBounds)
    if not entity or not DoesEntityExist(entity) then return end

    -- Enable entity outline
    SetEntityDrawOutlineShader(1)
    SetEntityDrawOutline(entity, true)
    -- Set color based on boundary status
    if inBounds then
        -- Green outline for valid placement
        SetEntityDrawOutlineColor(0, 255, 0, 255)
    else
        -- Red outline for invalid placement
        SetEntityDrawOutlineColor(255, 0, 0, 255)
    end
end

local function handleNormalMode()
    if not state.isPlacing or state.mode ~= 'normal' or state.paused then
        return
    end

    -- Disable conflicting controls
    DisableControlAction(0, 24, true) -- Attack
    DisableControlAction(0, 25, true) -- Aim
    DisableControlAction(0, 36, true) -- Duck

    local moveSpeed = state.keys.depthModifier and (state.settings.depthStep or 0.1) or (state.settings.rotationStep or 0.5)
    local lastPos = state.lastPos or GetEntityCoords(state.currentEntity)
    -- Scroll wheel controls using key mappings
    if state.keys.depthModifier then -- Depth modifier held - depth control
        if state.keys.scrollUp then
            state.keys.scrollUp = false -- Reset the key state
            state.depth = math.min(state.settings.maxDepth, state.depth + moveSpeed) -- Use maxDepth setting
        elseif state.keys.scrollDown then
            state.keys.scrollDown = false -- Reset the key state
            state.depth = math.max(1.0, state.depth - moveSpeed) -- Fixed: scroll down decreases distance
        end
    else -- Regular scroll - rotation
        if state.keys.scrollUp then
            state.keys.scrollUp = false -- Reset the key state
            state.heading = state.heading - 5.0 -- Fixed: scroll up = counterclockwise
        elseif state.keys.scrollDown then
            state.keys.scrollDown = false -- Reset the key state
            state.heading = state.heading + 5.0 -- Fixed: scroll down = clockwise
        end
    end

    -- Height controls (only if vertical movement allowed and not snapped to ground)
    -- if state.settings.allowVertical and not state.snapToGround then
    --     if IsControlPressed(0, 16) then -- Q
    --         state.height = state.height + (state.settings.heightStep or 0.5)
    --     elseif IsControlPressed(0, 17) then -- E
    --         state.height = state.height - (state.settings.heightStep or 0.5)
    --     end
    -- end
    -- Toggle ground snap
    if state.settings.allowVertical and IsControlJustPressed(0, 19) then -- Alt
        state.snapToGround = not state.snapToGround
        if state.snapToGround then
            state.height = 0.0
        end
    end

    -- Switch to movement mode
    if state.settings.allowMovement and IsControlJustPressed(0, 38) then -- E
        state.mode = 'movement'
        SetEntityCollision(state.currentEntity, false, false)
    end
    -- Update entity position
    local pos = getMouseWorldPos(state.depth)
    local groundZ, _z = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 50, false)

    if groundZ and state.currentEntity then
        if not state.snapToGround and state.verticle then
            print("verticle placement")
            state.offset = lastPos - pos
            pos = vector3(lastPos.x, lastPos.y, math.max(pos.z, _z))
            local temp = getMouseWorldPos(state.depth)
            state.height = temp.z - pos.z
        elseif not state.snapToGround and state.settings.allowVertical then
            pos = vector3(pos.x, pos.y, math.max(pos.z + state.height, _z)) -- Prevent going below ground
        elseif state.snapToGround then
            pos = vector3(pos.x, pos.y, _z)
        end
        SetEntityCoordsNoOffset(state.currentEntity, pos.x, pos.y, pos.z, false, false, false)
        SetEntityHeading(state.currentEntity, state.heading)
        state.lastPos = pos
    end

    -- Visual feedback
    if not state.settings.disableSphere then
        DrawSphere(pos.x, pos.y, pos.z, 0.5, 255, 0, 0, 50)
    end
end

local function handleMovementMode()
    if not state.isPlacing or state.mode ~= 'movement' or not DoesEntityExist(state.currentEntity) then
        return
    end

    -- Disable player movement
    DisableControlAction(0, 30, true) -- Move Left/Right
    DisableControlAction(0, 31, true) -- Move Forward/Back
    DisableControlAction(0, 36, true) -- Duck
    DisableControlAction(0, 21, true) -- Sprint
    DisableControlAction(0, 22, true) -- Jump

    local coords = GetEntityCoords(state.currentEntity)
    local heading = GetEntityHeading(state.currentEntity)
    local moveSpeed = IsControlPressed(0, 21) and (state.settings.movementStepFast or 0.5) or (state.settings.movementStep or 0.1) -- Faster with shift
    local moved = false

    -- Get camera direction for relative movement
    local camRot = GetGameplayCamRot(2)
    local camHeading = math.rad(camRot.z)
    local camForward = vector3(-math.sin(camHeading), math.cos(camHeading), 0)
    local camRight = vector3(math.cos(camHeading), math.sin(camHeading), 0)

    -- WASD movement
    if IsControlPressed(0, 32) then -- W
        coords = coords + camForward * moveSpeed
        moved = true
    elseif IsControlPressed(0, 33) then -- S
        coords = coords - camForward * moveSpeed
        moved = true
    end

    if IsControlPressed(0, 34) then -- A
        coords = coords - camRight * moveSpeed
        moved = true
    elseif IsControlPressed(0, 35) then -- D
        coords = coords + camRight * moveSpeed
        moved = true
    end

    -- Vertical movement
    if state.settings.allowVertical then
        if IsControlPressed(0, 85) then -- Q
            coords = coords + vector3(0, 0, moveSpeed)
            moved = true
        elseif IsControlPressed(0, 48) then -- Z
            coords = coords + vector3(0, 0, -moveSpeed)
            moved = true
        end
    end

    -- Rotation
    if IsControlPressed(0, 174) then -- Left arrow
        heading = heading + 2.0
        moved = true
    elseif IsControlPressed(0, 175) then -- Right arrow
        heading = heading - 2.0
        moved = true
    end

    -- Apply changes
    if moved then
        SetEntityCoordsNoOffset(state.currentEntity, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(state.currentEntity, heading)
    end

    -- Switch to normal mode
    if state.settings.allowNormal and IsControlJustPressed(0, 38) then -- E
        state.mode = 'normal'
        SetEntityCollision(state.currentEntity, true, true)
    end

    -- Snap to ground
    if IsControlJustPressed(0, 19) then -- Alt
        PlaceObjectOnGroundProperly(state.currentEntity)
    end
end

local function getEntityGroundOffset(entity)
    if not entity or not DoesEntityExist(entity) then return 0.0 end

    local min, max = GetModelDimensions(GetEntityModel(entity))
    return math.abs(min.z) -- Return the bottom offset of the model
end

local function placementLoop()
    CreateThread(function()
        while state.isPlacing do
            Wait(0)

            -- Handle input based on mode
            if state.mode == 'normal' then
                handleNormalMode()
            elseif state.mode == 'movement' then
                handleMovementMode()
            end

            -- Common controls using key mappings
            if state.keys.placeObject then
                state.keys.placeObject = false
                local canPlace = checkMaterialAndBoundary()
                if canPlace then
                    local coords = GetEntityCoords(state.currentEntity)
                    local rotation = GetEntityRotation(state.currentEntity)

                    -- Get the model's ground offset to adjust Z coordinate
                    local groundOffset = getEntityGroundOffset(state.currentEntity)
                    local adjustedCoords = vector3(coords.x, coords.y, coords.z - groundOffset)

                    if state.promise then
                        state.promise:resolve({
                            entity = state.currentEntity,
                            coords = adjustedCoords, -- Use adjusted coords
                            rotation = rotation,
                            placed = true
                        })
                    end

                    PlaceableObject.Stop()
                    break
                end
            end

            -- Cancel placement using key mapping
            if state.keys.cancelPlacement then
                state.keys.cancelPlacement = false -- Reset the key state
                if state.promise then
                    state.promise:resolve(false)
                end

                PlaceableObject.Stop()
                break
            end

            -- Check if entity is outside boundary and cancel if so
            if state.settings.boundary and state.currentEntity then
                local canPlace = checkMaterialAndBoundary()
                if not canPlace and state.settings.cancelOnOutOfBounds then
                    if state.promise then
                        state.promise:resolve(false)
                    end

                    PlaceableObject.Stop()
                    break
                end
            end

            -- Draw boundary if exists and enabled
            if state.settings.drawBoundary then
                drawBoundaryBox(state.settings.boundary)
            end

            -- Draw entity bounding box if enabled
            if state.settings.drawInBoundary and state.currentEntity then
                local overallResult, boundaryResult, customResult = checkMaterialAndBoundaryDetailed()
                -- Show red if any check fails, green if all pass
                local inBounds = overallResult
                drawEntityBoundingBox(state.currentEntity, inBounds)
            end
            Bridge.Notify.ShowHelpText(type(placementText) == 'table' and table.concat(placementText))
        end
    end)
end

-- Main functions


---@param model - Model name or hash
---@param settings - Configuration table:
--[[
    {
        depth = 3.0,                -- Starting distance from player
        allowVertical = false,      -- Enable height controls (Q/E, Alt to toggle ground snap)
        allowMovement = false,      -- Enable WASD movement mode
        allowNormal = false,        -- Allow switching back to normal mode from movement
        disableSphere = false,      -- Hide position indicator sphere
        cancelOnOutOfBounds = false,-- Cancel placement if moved outside boundary
        drawBoundary = false,       -- Draw boundary box/polygon
        drawInBoundary = false,     -- Draw entity outline (green/red) based on boundary/material
        boundary = nil,             -- Area restriction (box: {min=vector3(), max=vector3()}, polygon: {points={...}, minZ, maxZ})
        allowedMats = nil,          -- Allowed surface materials (e.g. {"concrete", "grass"})
        customCheck = nil,          -- Custom function(pos, entity, settings) -> bool
        depthStep = 0.1,            -- Step size for depth adjustment (scroll + modifier)
        rotationStep = 0.5,         -- Step size for rotation (scroll)
        heightStep = 0.5,           -- Step size for height adjustment (Q/E)
        movementStep = 0.1,         -- Step size for WASD movement
        movementStepFast = 0.5,     -- Step size for fast movement (WASD + Shift)
        maxDepth = 5.0,             -- Maximum distance from player
    }
--]]
---@returns Promise with: {entity, coords, heading, placed, cancelled}
--[[
    Example:
    local result = Citizen.Await(PlaceableObject.Create("prop_barrier_work05", {
        depth = 5.0,
        allowVertical = false
    }))
--]]

function PlaceableObject.Create(model, settings)
    if state.isPlacing then
        PlaceableObject.Stop()
    end

    -- Default settings
    settings = settings or {}
    settings.depth = settings.depth or 3.0  -- Start closer to player
    settings.allowVertical = settings.allowVertical or false
    settings.allowMovement = settings.allowMovement or false
    settings.allowNormal = settings.allowNormal or false
    settings.disableSphere = settings.disableSphere or false
    settings.drawBoundary = settings.drawBoundary or false
    settings.drawInBoundary = settings.drawInBoundary or false
    settings.cancelOnOutOfBounds = settings.cancelOnOutOfBounds or false

    -- Movement speed settings
    settings.depthStep = settings.depthStep or 0.1 -- Fine control for depth adjustment
    settings.rotationStep = settings.rotationStep or 0.5 -- Normal rotation speed
    settings.heightStep = settings.heightStep or 0.5 -- Height adjustment speed
    settings.movementStep = settings.movementStep or 0.1 -- Normal movement speed
    settings.movementStepFast = settings.movementStepFast or 0.5 -- Fast movement speed (with shift)
    settings.maxDepth = settings.maxDepth or 5.0 -- Maximum distance from player

    state.settings = settings
    state.depth = settings.depth  -- Use the settings depth
    state.heading = -GetEntityHeading(PlayerPedId())
    state.height = 0.0
    state.snapToGround = not settings.allowVertical
    state.mode = 'normal'

    local p = promise.new()
    state.promise = p

    local point = Bridge.Entity.Create({
        id = 'placeable_object',
        entityType = 'object',
        model = model,
        coords = GetEntityCoords(PlayerPedId()),
        rotation = vector3(0.0, 0.0, state.heading),
        OnSpawn= function(data)
            state.currentEntity = data.spawned
            SetEntityCollision(state.currentEntity, false, false)
            FreezeEntityPosition(state.currentEntity, false)

            -- Set initial position based on depth
            local playerPos = GetEntityCoords(PlayerPedId())
            local forward = GetEntityForwardVector(PlayerPedId())
            local spawnPos = playerPos + forward * state.depth
            SetEntityCoordsNoOffset(state.currentEntity, spawnPos.x, spawnPos.y, spawnPos.z, false, false, false)
        end,
    })
    -- Setup instructional buttons
    -- state.scaleform = setupInstructionalButtons()
    state.scaleform = nil

    state.isPlacing = true

    -- Show help text for placement controls
    Bridge.Notify.ShowHelpText(type(placementText) == 'table' and table.concat(placementText))

    placementLoop()


    return Citizen.Await(p)
end

function PlaceableObject.Stop()
    Bridge.Notify.HideHelpText()
    if state.currentEntity and DoesEntityExist(state.currentEntity) then
        -- Disable entity outline before deleting
        SetEntityDrawOutline(state.currentEntity, false)
        DeleteObject(state.currentEntity)
    end

    if state.scaleform then
        Scaleform.Unload(state.scaleform)
    end
    Bridge.Entity.Unregister('placeable_object')
    -- Reset state
    state.isPlacing = false
    state.currentEntity = nil
    state.mode = 'normal'
    state.promise = nil
    state.scaleform = nil
    state.settings = {}

    return true
end

-- Status functions
function PlaceableObject.IsPlacing()
    return state.isPlacing
end

function PlaceableObject.GetCurrentEntity()
    return state.currentEntity
end

function PlaceableObject.GetCurrentMode()
    return state.mode
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if state.isPlacing then
        PlaceableObject.Stop()
    end
end)

return PlaceableObject