---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-doorlock') ~= 'started' then return end

Doorlock = Doorlock or {}

---This will toggle the lock status of the door.
---@param doorID string
---@param toggle boolean
---@return boolean
Doorlock.ToggleDoorLock = function(doorID, toggle)
    TriggerClientEvent('qb-doorlock:client:setState', -1, 0, doorID, toggle, false, false, false)
    return true
end

return Doorlock