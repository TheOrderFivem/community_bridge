---@diagnostic disable: duplicate-set-field
if GetResourceState('rcore_doorlock') ~= 'started' then return end

Doorlock = Doorlock or {}

---This will toggle the lock status of the door.
---@param doorID string
---@param toggle boolean
---@return boolean
Doorlock.ToggleDoorLock = function(doorID, toggle)
    local state = toggle
    if state then
        exports.rcore_doorlock:changeDoorState(doorID, 0)
    else
        exports.rcore_doorlock:changeDoorState(doorID, 1)
    end
    return true
end
return Doorlock