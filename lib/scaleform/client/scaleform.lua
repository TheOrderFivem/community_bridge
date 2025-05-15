---@class Scaleform
local Scaleform = {}

-- Constants
local SCALEFORM_TIMEOUT = 5000
local BACKGROUND_COLOR_VALUE = 80
local CONTROL_TYPE = 2
local RENDER_WAIT_TIME = 2

-- Local utility functions
local function setupButton(scaleform, button)
    PushScaleformMovieFunction(scaleform, button.type)

    if button.int then
        PushScaleformMovieFunctionParameterInt(button.int)
    end

    -- Handle key index setup
    if button.keyIndex then
        if type(button.keyIndex) == "table" then
            for _, keyCode in pairs(button.keyIndex) do
                N_0xe83a3e3557a56640(GetControlInstructionalButton(CONTROL_TYPE, keyCode, true))
            end
        else
            ScaleformMovieMethodAddParamPlayerNameString(GetControlInstructionalButton(CONTROL_TYPE, button.keyIndex[1],
                true))
        end
    end

    -- Handle button name setup
    if button.name then
        BeginTextCommandScaleformString("STRING")
        AddTextComponentScaleform(button.name)
        EndTextCommandScaleformString()
    end

    -- Handle background color
    if button.type == 'SET_BACKGROUND_COLOUR' then
        for _ = 1, 4 do
            PushScaleformMovieFunctionParameterInt(BACKGROUND_COLOR_VALUE)
        end
    end

    PopScaleformMovieFunctionVoid()
end

---Creates and sets up a scaleform movie
---@param scaleformName string The name of the scaleform to load
---@param buttons table Array of button configurations
---@return number scaleform The loaded scaleform handle
local function setupScaleform(scaleformName, buttons)
    local scaleform = RequestScaleformMovie(scaleformName)
    local timeout = SCALEFORM_TIMEOUT

    -- Wait for scaleform to load
    while not HasScaleformMovieLoaded(scaleform) and timeout > 0 do
        timeout = timeout - 1
        Wait(0)
    end

    if timeout <= 0 then
        error('Scaleform failed to load: ' .. scaleformName)
    end

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    -- Setup each button
    for _, button in ipairs(buttons) do
        setupButton(scaleform, button)
    end

    return scaleform
end

---Sets up instructional buttons with default configuration
---@param buttons table Optional custom button configuration
---@return number scaleform The configured instructional buttons scaleform
function Scaleform.SetupInstructionalButtons(buttons)
    buttons = buttons or {
        -- Default button configuration commented out
        -- Uncomment and modify as needed
        -- {type = "CLEAR_ALL"},
        -- {type = "SET_CLEAR_SPACE", int = 200},
        -- {type = "SET_DATA_SLOT", name = config?.place_object?.name or 'Place Object:', keyIndex = config?.place_object?.key or {223}, int = 5},
        -- {type = "SET_DATA_SLOT", name = config?.cancel_placement?.name or 'Cancel Placement:', keyIndex = config?.cancel_placement?.key or {222}, int = 4},
        -- {type = "SET_DATA_SLOT", name = config?.snap_to_ground?.name or 'Snap to Ground:', keyIndex = config?.snap_to_ground?.key or {19}, int = 1},
        -- {type = "SET_DATA_SLOT", name = config?.rotate?.name or 'Rotate:', keyIndex = config?.rotate?.key or {14, 15}, int = 2},
        -- {type = "SET_DATA_SLOT", name = config?.distance?.name or 'Distance:', keyIndex = config?.distance?.key or {14,15,36}, int = 3},
        -- {type = "SET_DATA_SLOT", name = config?.toggle_placement?.name or 'Toggle Placement:', keyIndex = config?.toggle_placement?.key or {199}, int = 0},
        -- {type = "DRAW_INSTRUCTIONAL_BUTTONS"},
        -- {type = "SET_BACKGROUND_COLOUR"},
    }

    return setupScaleform("instructional_buttons", buttons)
end

-- Active scaleform tracking
local activeScaleform = nil

---Runs a scaleform with optional update callback
---@param scaleform number The scaleform handle to run
---@param onUpdate function Optional callback for updates during runtime
function Scaleform.Run(scaleform, onUpdate)
    if activeScaleform then return end
    activeScaleform = scaleform

    CreateThread(function()
        while activeScaleform do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

            if onUpdate then
                local shouldStop = onUpdate()
                if shouldStop then
                    Scaleform.Stop()
                    break
                end
            end

            Wait(RENDER_WAIT_TIME)
        end
    end)
end

---Stops the currently running scaleform
function Scaleform.Stop()
    activeScaleform = nil
end

-- Export the Scaleform module
exports("Scaleform", Scaleform)
return Scaleform
