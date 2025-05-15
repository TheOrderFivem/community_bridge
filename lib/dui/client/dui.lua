-- DUI (Direct User Interface) Manager for FiveM
-- Basic table-based implementation with full mouse support

---@class DUI
DUI = {}

-- Constants
local DEFAULT_WIDTH <const> = 1280
local DEFAULT_HEIGHT <const> = 720

-- Store active DUI instances
local activeInstances = {}
local instanceCounter = 0

-- Mouse tracking state
local mouseState = {
    tracking = false,
    activeId = nil,
    lastX = 0,
    lastY = 0,
    isPressed = false,
    currentButton = nil
}

-- Mouse button constants
local MOUSE_BUTTONS <const> = {
    LEFT = "left",
    MIDDLE = "middle",
    RIGHT = "right"
}

---@class DUIInstance
---@field id number Unique identifier for this DUI instance
---@field url string URL loaded in the DUI
---@field width number Width of the DUI
---@field height number Height of the DUI
---@field handle number DUI browser handle
---@field txd string Texture dictionary name
---@field txn string Texture name
---@field active boolean Whether the DUI is active
---@field trackMouse boolean Whether mouse tracking is enabled for this instance
---@field mouseScale table<string, number> Scale factors for mouse coordinates

-- Create a new DUI instance
---@param url string URL to load
---@param width? number Width of the DUI (default: 1280)
---@param height? number Height of the DUI (default: 720)
---@return number|nil id The DUI instance ID if successful, nil if failed
function DUI.Create(url, width, height)
    if not url or type(url) ~= "string" then
        return print("DUI.Create: URL is required and must be a string")
    end

    width = width or DEFAULT_WIDTH
    height = height or DEFAULT_HEIGHT
    instanceCounter = instanceCounter + 1

    local id = instanceCounter
    local handle = CreateDui(url, width, height)

    if not handle then
        return print("DUI.Create: Failed to create DUI instance")
    end

    local instance = {
        id = id,
        url = url,
        width = width,
        height = height,
        handle = handle,
        txd = "dui_" .. id,
        txn = "texture_" .. id,
        active = true,
        trackMouse = false,
        mouseScale = {
            x = 1.0,
            y = 1.0
        }
    }

    -- Create runtime texture
    local duiHandle = GetDuiHandle(handle)
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(instance.txd), instance.txn, duiHandle)

    activeInstances[id] = instance
    return id
end

-- Destroy a DUI instance
---@param id number DUI instance ID
---@return boolean success Whether the operation was successful
function DUI.Destroy(id)
    local instance = activeInstances[id]
    if not instance then return false end

    if instance.handle then
        DestroyDui(instance.handle)
    end

    activeInstances[id] = nil
    return true
end

-- Set URL for a DUI instance
---@param id number DUI instance ID
---@param url string New URL to load
---@return boolean success Whether the operation was successful
function DUI.SetURL(id, url)
    local instance = activeInstances[id]
    if not instance then return false end

    SetDuiUrl(instance.handle, url)
    instance.url = url
    return true
end

-- Send a message to the DUI
---@param id number DUI instance ID
---@param message table Message to send (will be JSON encoded)
---@return boolean success Whether the operation was successful
function DUI.SendMessage(id, message)
    local instance = activeInstances[id]
    if not instance then return false end

    SendDuiMessage(instance.handle, json.encode(message))
    return true
end

-- Mouse interaction functions

-- Move mouse cursor on DUI
---@param id number DUI instance ID
---@param x number X coordinate
---@param y number Y coordinate
---@return boolean success Whether the operation was successful
function DUI.MoveMouse(id, x, y)
    local instance = activeInstances[id]
    if not instance then return false end

    SendDuiMouseMove(instance.handle, x, y)
    return true
end

-- Simulate mouse button press
---@param id number DUI instance ID
---@param button "left"|"middle"|"right" Mouse button to simulate
---@return boolean success Whether the operation was successful
function DUI.MouseDown(id, button)
    local instance = activeInstances[id]
    if not instance then return false end

    if not MOUSE_BUTTONS[button:upper()] then
        return print("DUI.MouseDown: Invalid button. Must be 'left', 'middle', or 'right'")
    end

    -- Update mouse state
    if instance.trackMouse then
        mouseState.isPressed = true
        mouseState.currentButton = button
    end

    SendDuiMouseDown(instance.handle, button)
    return true
end

-- Simulate mouse button release
---@param id number DUI instance ID
---@param button "left"|"middle"|"right" Mouse button to simulate
---@return boolean success Whether the operation was successful
function DUI.MouseUp(id, button)
    local instance = activeInstances[id]
    if not instance then return false end

    if not MOUSE_BUTTONS[button:upper()] then
        return print("DUI.MouseUp: Invalid button. Must be 'left', 'middle', or 'right'")
    end

    -- Update mouse state
    if instance.trackMouse then
        mouseState.isPressed = false
        mouseState.currentButton = nil
    end

    SendDuiMouseUp(instance.handle, button)
    return true
end

-- Simulate mouse wheel movement
---@param id number DUI instance ID
---@param deltaY number Vertical scroll amount
---@param deltaX number Horizontal scroll amount
---@return boolean success Whether the operation was successful
function DUI.MouseWheel(id, deltaY, deltaX)
    local instance = activeInstances[id]
    if not instance then return false end

    SendDuiMouseWheel(instance.handle, deltaY, deltaX)
    return true
end

-- Click helper function (combines MoveMouse, MouseDown, and MouseUp)
---@param id number DUI instance ID
---@param x number X coordinate
---@param y number Y coordinate
---@param button? "left"|"middle"|"right" Mouse button to click (default: "left")
---@return boolean success Whether the operation was successful
function DUI.Click(id, x, y, button)
    button = button or "left"

    if not DUI.MoveMouse(id, x, y) then return false end
    if not DUI.MouseDown(id, button) then return false end

    -- Small delay to simulate real click
    Citizen.Wait(50)

    return DUI.MouseUp(id, button)
end

-- Enable or disable mouse tracking for a DUI instance
---@param id number DUI instance ID
---@param enabled boolean Whether to enable mouse tracking
---@param scaleX? number Scale factor for X coordinates (default: 1.0)
---@param scaleY? number Scale factor for Y coordinates (default: 1.0)
---@return boolean success Whether the operation was successful
function DUI.TrackMouse(id, enabled, scaleX, scaleY)
    local instance = activeInstances[id]
    if not instance then return false end

    instance.trackMouse = enabled
    instance.mouseScale.x = scaleX or 1.0
    instance.mouseScale.y = scaleY or 1.0

    if enabled then
        mouseState.tracking = true
        mouseState.activeId = id
    elseif mouseState.activeId == id then
        mouseState.tracking = false
        mouseState.activeId = nil
    end

    return true
end

-- Update mouse coordinates from screen position
---@param screenX number Screen X coordinate
---@param screenY number Screen Y coordinate
---@return boolean updated Whether coordinates were updated
local function UpdateMousePosition(screenX, screenY)
    if not mouseState.tracking or not mouseState.activeId then return false end

    local instance = activeInstances[mouseState.activeId]
    if not instance or not instance.trackMouse then return false end

    -- Scale coordinates based on DUI dimensions and scale factors
    local scaledX = screenX * instance.mouseScale.x
    local scaledY = screenY * instance.mouseScale.y

    -- Only update if position changed
    if scaledX ~= mouseState.lastX or scaledY ~= mouseState.lastY then
        mouseState.lastX = scaledX
        mouseState.lastY = scaledY
        DUI.MoveMouse(mouseState.activeId, scaledX, scaledY)
        return true
    end

    return false
end

-- Mouse tracking thread
Citizen.CreateThread(function()
    while true do
        if mouseState.tracking and mouseState.activeId then
            local instance = activeInstances[mouseState.activeId]
            if instance and instance.trackMouse then
                -- Get current cursor position
                local screenX, screenY = GetNuiCursorPosition()
                UpdateMousePosition(screenX, screenY)

                -- Handle held mouse buttons
                if mouseState.isPressed and mouseState.currentButton then
                    -- Keep the button pressed state
                    SendDuiMouseDown(instance.handle, mouseState.currentButton)
                end
            end
        end
        Citizen.Wait(0)
    end
end)

-- Utility functions

-- Get textures for a DUI instance
---@param id number DUI instance ID
---@return string|nil txd, string|nil txn Texture dictionary and name, or nil if instance not found
function DUI.GetTextures(id)
    local instance = activeInstances[id]
    if not instance then return nil, nil end

    return instance.txd, instance.txn
end

-- Check if a DUI instance exists
---@param id number DUI instance ID
---@return boolean exists Whether the instance exists and is active
function DUI.Exists(id)
    local instance = activeInstances[id]
    return instance ~= nil and instance.active
end

-- Get all active DUI instances
---@return table<number, DUIInstance> instances Table of active DUI instances
function DUI.GetActiveInstances()
    return activeInstances
end

-- Cleanup all DUI instances
function DUI.CleanupAll()
    for id in pairs(activeInstances) do
        DUI.Destroy(id)
    end
end

-- Automatic cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    DUI.CleanupAll()
end)

return DUI
