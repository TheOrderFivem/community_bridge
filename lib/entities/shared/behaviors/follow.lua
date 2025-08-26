local Follow = {
    All = {},
    property = "follow",
    default = {
        speed = 1.0,
        distance = 2.0
    }
}

function Follow.PedWalkToPos(entityData)
    if not entityData?.follow?.target or entityData?.entityType ~= "ped" then return end
    local entity = entityData.spawned
    local targetCoords = entityData.follow.target
    if type(targetCoords) == "number" then
        local player = GetPlayerFromServerId(targetCoords)
        if player and player ~= -1 then
            targetCoords = GetEntityCoords(GetPlayerPed(player))
        else
            targetCoords = GetEntityCoords(targetCoords)
        end
    end
    local entityPos = GetEntityCoords(entity)
    local distance = #(targetCoords - entityPos)
    if distance > (entityData.follow.distance or Follow.default.distance) then
        local speed = entityData.follow.speed or Follow.default.speed
        local heading = GetHeadingFromVector_2d(targetCoords.x - entityPos.x, targetCoords.y - entityPos.y)
        TaskGoStraightToCoord(entity, targetCoords.x, targetCoords.y, targetCoords.z, speed, -1, heading, 0.0)
        entityData.coords = GetEntityCoords(entity)
        return false
    end
    ClearPedTasks(entity)
    return true
end


function Follow.OnUpdate(entityData)
    assert(entityData?.id, "Entity ID is required")
    local entity = entityData.spawned
    if not entity or not DoesEntityExist(entity) then return end
    return Follow.PedWalkToPos(entityData)
end

return Follow