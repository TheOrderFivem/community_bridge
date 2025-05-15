---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-doorlock') ~= 'started' then return end

Doorlock = Doorlock or {}

---This will get the closest door to the ped
---@return string | nil
Doorlock.GetClosestDoor = function()
    local closestDoor = exports["qb-doorlock"]:GetClosestDoor()
    if Table.CheckPopulated(closestDoor) then return closestDoor end
    local allDoors = exports["qb-doorlock"]:GetDoorList()
    local pedCoords = GetEntityCoords(cache.ped)
    local door = 0
    local doorDist = 1000.0
    for doorID, data in pairs(allDoors) do
        local dist = #(pedCoords - data.objCoords)
        if dist < doorDist then
            door = doorID
            doorDist = dist
        end
    end
    return door
end

return Doorlock