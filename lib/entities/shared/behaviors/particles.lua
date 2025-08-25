Utility = Utility or Require("lib/utility/client/utility.lua")
local ParticlesBehaviors = {
    property = "particles",
    default = {
        dict = "cut_exile3",
        ptfx = "cs_ex3_wheel_spin",
        offset = vector3(0, 0, 0),
        rotation = vector3(0, 0, 0),
        size = 1.0,
        color = vector3(255, 255, 255),
        loopLength = 5000,
    }

}

function ParticlesBehaviors.Start(entityData)
    for _, particleData in ipairs(entityData.particles) do
        local position = vector3(entityData.coords.x, entityData.coords.y, entityData.coords.z)
        local rotation = vector3(entityData.rotation.x, entityData.rotation.y, entityData.rotation.z)
        position = position + (particleData.offset?.xyz or vector3(0, 0, 0))
        rotation = rotation + (particleData.rotation?.xyz or vector3(0, 0, 0))
        particleData.playing = Particle.Play(
            particleData.dict or ParticlesBehaviors.default.dict,
            particleData.ptfx or ParticlesBehaviors.default.ptfx,
            position,
            rotation,
            particleData.size or ParticlesBehaviors.default.size,
            particleData.color or ParticlesBehaviors.default.color,
            particleData.looped,
            particleData.loopLength or ParticlesBehaviors.default.loopLength
        )
    end
end

function ParticlesBehaviors.OnSpawn(entityData)
    if not entityData.particles then return end
    if entityData.particles.dict then -- single particle
        entityData.particles = {entityData.particles}
    end
    ParticlesBehaviors.Start(entityData)    
end


function ParticlesBehaviors.OnRemove(entityData)
    if not entityData.particles then return end
    for _, particleData in ipairs(entityData.particles) do
        if particleData.playing then
            Particle.Stop(particleData.playing)
            particleData.playing = nil
        end
    end
end

function ParticlesBehaviors.OnMove(entityData)
    if not entityData.particles then return end
    for _, particleData in ipairs(entityData.particles) do
        if particleData.playing then
            Particle.Stop(particleData.playing)
            particleData.playing = nil
            local position = vector3(entityData.coords.x, entityData.coords.y, entityData.coords.z)
            local rotation = vector3(entityData.rotation.x, entityData.rotation.y, entityData.rotation.z)
            position = position + (particleData.offset?.xyz or vector3(0, 0, 0))
            rotation = rotation + (particleData.rotation?.xyz or vector3(0, 0, 0))
            particleData.playing = Particle.Play(
                particleData.dict or ParticlesBehaviors.default.dict,
                particleData.ptfx or ParticlesBehaviors.default.ptfx,
                position,
                rotation,
                particleData.size or ParticlesBehaviors.default.size,
                particleData.color or ParticlesBehaviors.default.color,
                particleData.looped,
                particleData.loopLength or ParticlesBehaviors.default.loopLength
            )
        end
    end
end


return ParticlesBehaviors