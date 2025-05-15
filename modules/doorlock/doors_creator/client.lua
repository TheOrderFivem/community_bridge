---@diagnostic disable: duplicate-set-field
if GetResourceState('doors_creator') ~= 'started' then return end

Doorlock = Doorlock or {}

---This will get the closest door to the ped
---@return string | nil
Doorlock.GetClosestDoor = function()
    return exports["doors_creator"]:getClosestActiveDoor()
end

return Doorlock