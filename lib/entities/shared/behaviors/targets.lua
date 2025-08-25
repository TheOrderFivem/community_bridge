local Targets = {
    property = "targets",
    default = {
        label = "Default Target Label",
        distance = 2,
    }
}


function Targets.OnSpawn(entityData)
    if not entityData.spawned or not entityData.target then return end
    if entityData.targets?.label then
        entityData.newTargets = {entityData.targets}
    else
        entityData.newTargets = entityData.targets or {}
    end
    for k, v in pairs(entityData.newTargets) do
        local onSelect = v.onSelect
        if onSelect then
            v.onSelect = function(entity)
                onSelect(entityData, entity)
            end
        end
    end
    Target.AddLocalEntity(entityData.spawned, entityData.newTargets)
    entityData.oldTargets = entityData.newTargets
end

function Targets.OnRemove(entityData)
    if not entityData.spawned or not entityData.newTargets then return end
    Target.RemoveLocalEntity(entityData.spawned)
end

function Targets.OnUpdate(entityData)
    if not entityData.spawned or not entityData.newTargets then return end
    local doesntMatch = false
    for k, v in pairs(entityData.newTargets) do
        if not entityData.oldTargets or not entityData.oldTargets[k] then
            doesntMatch = true
            break
        end
        local old = entityData.oldTargets[k]
        if old.label ~= v.label
            or old.distance ~= v.distance
            or old.description ~= v.description
        then
            doesntMatch = true
            break
        end
    end
    if doesntMatch then
        Targets.OnRemove(entityData)
        Targets.OnSpawn(entityData)
    end
end

return Targets