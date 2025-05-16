---@class Utility
UtilityShared = {}

--- Waits for a condition to be met and then executes a callback
---@param condition function Function that returns boolean - the condition to wait for
---@param callback function Function to execute when condition is met
---@param timeout? number Optional timeout in milliseconds (default: 5000)
---@param interval? number Optional check interval in milliseconds (default: 100)
---@return boolean success Returns true if condition was met before timeout
function UtilityShared.WaitFor(condition, callback, timeout, interval)
    local timeoutVal = timeout or 5000
    local intervalVal = interval or 100
    local startTime = GetGameTimer()

    CreateThread(function()
        while true do
            if condition() then
                callback()
                return true
            end

            if GetGameTimer() - startTime >= timeoutVal then
                print(string.format("WaitFor timed out after %d ms", timeoutVal))
                return false
            end

            Wait(intervalVal)
        end
    end)
end

-- Example usage:
--[[
    Utility.WaitFor(
        function() -- condition
            return DoesEntityExist(vehicle)
        end,
        function() -- callback
            SetVehicleDoorsLocked(vehicle, 2)
        end,
        10000  -- 10 second timeout
    )
]]
exports("UtilityShared", UtilityShared)
return UtilityShared
