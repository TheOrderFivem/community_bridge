---@class Utility
UtilityShared = {}
local Ids = Ids or Require("lib/utility/shared/ids.lua")
--- Waits for a condition to be met and then executes a callback
---@param condition function Function that returns boolean - the condition to wait for
---@param callback function Function to execute when condition is met
---@param timeout? number Optional timeout in milliseconds (default: 5000)
---@param interval? number Optional check interval in milliseconds (default: 100)
---@return boolean success Returns true if condition was met before timeout
local waitfors = {} -- now i can make a function to cancel these waitfors
function UtilityShared.WaitFor(condition, callback, timeout, interval)
    local id = Ids.Random(3)
    if waitfors[id] then
        print(string.format("WaitFor with ID %s is already running", id))
        return false
    end
   
    timeout = timeout or 5000 -- saving a very small amount of memory by not using another variable
    interval = interval or 100    
    waitfors[id] = true
    CreateThread(function()
        local startTime = GetGameTimer()
        while waitfors[id] do
            if condition() then
                callback()                
                break -- break so it triggers a post event
            elseif GetGameTimer() - startTime >= timeout then
                print(string.format("WaitFor timed out after %d ms", timeout))
                break
            end

            Wait(interval)
        end
        waitfors[id] = nil -- this is technically our post even and could be expanded to do more things
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
