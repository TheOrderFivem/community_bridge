local Animation = {
    property = "anim",
    default = {
        flags = 49,
        duration = -1
    }
}
-- Anim.Play(id, entity, animDict, animName, blendIn, blendOut, duration, flag, playbackRate, onComplete)
function Animation.Play(entityData)
    if entityData.entityType ~= "ped" then return end
    local entity = entityData.spawned
    if not entity then return end
    local dict = entityData.anim?.dict
    local name = entityData.anim?.name
    local onComplete = entityData.anim?.onComplete and function() entityData.anim.onComplete(entityData) end
    if not dict or not name then return end
    local flags = entityData.anim.flags or Animation.default.flags
    local duration = entityData.anim.duration or Animation.default.duration
    entityData.anim.id = Anim.Play(nil, entity, dict, name, 8.0, -8.0, duration, flags, 0.0, onComplete)
    entityData.oldAnim = entityData.anim
end

function Animation.OnSpawn(entityData)
    if not entityData.spawned or not entityData.anim then return end
    Animation.Play(entityData)
    entityData.anim.updating = false
end

function Animation.OnRemove(entityData)
    if not entityData.spawned or not entityData.anim then return end
    entityData.oldanim = nil
    entityData.anim.updating = true
end

function Animation.OnUpdate(entityData)
    if not entityData.spawned or not entityData.anim then return end
    if entityData.anim.updating then return end
    entityData.anim.updating = true
    if not entityData.oldAnim or entityData.oldAnim.name ~= entityData.anim.name then
        Anim.Stop(entityData.oldAnim?.id)
        Animation.Play(entityData)
    end
    SetTimeout(1000, function()
        if entityData.anim then
            entityData.anim.updating = false
        end
    end)
end

return Animation