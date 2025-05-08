---@class Scaleform
---@field private runningScaleform number|nil
local Scaleform = {}

---Constants
local TIMEOUT_DURATION = 5000
local BACKGROUND_COLOR = 80
local RENDER_INTERVAL = 2

---Sets up a scaleform movie with the given buttons configuration
---@param scaleformName string The name of the scaleform to load
---@param buttons table Array of button configurations
---@return number | string scaleform  The loaded scaleform handle
local function SetupScaleform(scaleformName, buttons)
    if type(scaleformName) ~= "string" or type(buttons) ~= "table" then
       return print("Invalid parameters provided to SetupScaleform")
    end

    local scaleform = RequestScaleformMovie(scaleformName)
    local timeout = TIMEOUT_DURATION

    -- Wait for scaleform to load
    while not HasScaleformMovieLoaded(scaleform) and timeout > 0 do
        timeout = timeout - 1
        Wait(0)
    end

    if timeout <= 0 then
        return print('Scaleform failed to load: timeout reached')
    end

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    -- Process button configurations
    for _, button in ipairs(buttons) do
        PushScaleformMovieFunction(scaleform, button.type)

        if button.int then
            PushScaleformMovieFunctionParameterInt(button.int)
        end

        -- Handle key index configuration
        if button.keyIndex then
            if type(button.keyIndex) == "table" then
                for _, keyCode in pairs(button.keyIndex) do
                    N_0xe83a3e3557a56640(GetControlInstructionalButton(2, keyCode, true))
                end
            else
                ScaleformMovieMethodAddParamPlayerNameString(
                    GetControlInstructionalButton(2, button.keyIndex[1], true)
                )
            end
        end

        -- Handle button name
        if button.name then
            BeginTextCommandScaleformString("STRING")
            AddTextComponentScaleform(button.name)
            EndTextCommandScaleformString()
        end

        -- Set background color if specified
        if button.type == 'SET_BACKGROUND_COLOUR' then
            for _ = 1, 4 do
                PushScaleformMovieFunctionParameterInt(BACKGROUND_COLOR)
            end
        end

        PopScaleformMovieFunctionVoid()
    end

    return scaleform
end

---Sets up instructional buttons with default or custom configuration
---@param buttons table|nil Optional custom button configuration
---@return number scaleform The configured instructional buttons scaleform
function Scaleform.SetupInstructionalButtons(buttons)
    buttons = buttons or {}
    return SetupScaleform("instructional_buttons", buttons)
end

---Runs the scaleform with optional update callback
---@param scaleform number The scaleform handle to run
---@param onUpdate function|nil Optional callback function for updates
function Scaleform.Run(scaleform, onUpdate)
    if Scaleform.runningScaleform then return end

    Scaleform.runningScaleform = scaleform
    CreateThread(function()
        while Scaleform.runningScaleform do
            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

            if onUpdate then
                local shouldQuit = onUpdate()
                if shouldQuit then
                    Scaleform.Stop()
                    break
                end
            end

            Wait(RENDER_INTERVAL)
        end
    end)
end

---Stops the currently running scaleform
function Scaleform.Stop()
    Scaleform.runningScaleform = nil
end

-- Export the Scaleform module
exports("Scaleform", Scaleform)
return Scaleform
