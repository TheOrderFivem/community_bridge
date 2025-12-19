Particles = {}
Particle = {}

---@diagnostic disable: duplicate-set-field
Ids = Ids or Require("lib/utility/shared/ids.lua")
---Loads a ptfx asset into memory.
---@param dict string
---@return boolean
function LoadPtfxAsset(dict)
    local failed = 100
    while not HasNamedPtfxAssetLoaded(dict) and failed >= 0 do
        RequestNamedPtfxAsset(dict)
        failed = failed - 1
        Wait(100)
    end
    assert(failed > 0, "Failed to load dict asset: " .. dict)
    return HasNamedPtfxAssetLoaded(dict)
end

--- Check Ownership of entity
--- This is not a security measure, just prevent spam.
---@param entity string|number Entity
---@return boolean
local function IsNetworkOwner(entity)
    if not DoesEntityExist(entity) then return false end
    if not NetworkGetEntityIsNetworked(entity) then return false end
    local ownerPlayer = NetworkGetEntityOwner(entity)
    return ownerPlayer == PlayerId()
end


--- Create a particle effect at the specified position and rotation.
--- @param dict string
--- @param ptfx string
--- @param pos vector3
--- @param rot vector3
--- @param scale number
--- @param color vector3
--- @param looped boolean
--- @param removeAfter number|nil
--- @return number|nil ptfxHandle -- The handle of the particle effect, or nil if it failed to create.
function Particle.Play(dict, ptfx, pos, rot, scale, color, looped, removeAfter)
    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    removeAfter = removeAfter or 5000
    if looped then
        particle = StartParticleFxLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
        local strParticle = tostring(particle)
        Particles[strParticle] = particle
        Wait(10)
        if particle == 0 or not DoesParticleFxLoopedExist(particle) then            
            particle = StartParticleFxNonLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
            if not particle and particle == 0 then
                print(string.format("[Particle] Failed to start particle fx: %s from dict: %s", ptfx, dict))
                return nil
            end
            local strParticle = tostring(particle)
            Particles[strParticle] = particle
            CreateThread(function()
                while Particles[strParticle] do
                    Wait(removeAfter)
                    if not Particles[strParticle] then break end
                    RemoveParticleFx(particle, false)                
                    particle = StartParticleFxNonLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
                    Particles[strParticle] = particle
                end
            end)
            return strParticle
        else
            if not removeAfter or removeAfter <= 0 then return particle end
            CreateThread(function()
                while Particles[strParticle] do
                    Wait(removeAfter)
                    if not Particles[strParticle] then break end
                    StopParticleFxLooped(particle, false)
                    UseParticleFxAssetNextCall(dict)
                    LoadPtfxAsset(dict)
                    particle = StartParticleFxLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
                    Particles[strParticle] = particle
                end
            end)     
            return strParticle
        end
    else 
        particle = StartParticleFxLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
        Wait(10)
        if not DoesParticleFxLoopedExist(particle) then            
            particle = StartParticleFxNonLoopedAtCoord(ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, scale, false, false, false, false)
        end
        Wait(removeAfter)
        Particle.Stop(particle)
    end

    return particle
end

function Particle.Stop(particle)
    if not particle then return end
    StopParticleFxLooped(particle, false)
    RemoveParticleFx(particle, false)
    RemoveNamedPtfxAsset(particle)
    Particles[tostring(particle)] = nil
end

RegisterNetEvent("community_bridge:Client:Particle", function(data)
    if not data then return end
    Particle.Create(data)
end)

RegisterNetEvent("community_bridge:Client:ParticleBulk", function(datas)
    if not datas then return end
    for _, data in pairs(datas) do
        Particle.Create(data)
    end
end)

RegisterNetEvent("community_bridge:Client:ParticleRemove", function(id)
    local particle = Particles[id]
    if not particle then return end
    Particle.Stop(id)
end)

RegisterNetEvent("community_bridge:Client:ParticleRemoveBulk", function(ids)
    for _, id in pairs(ids) do
        Particle.Stop(id)
    end
end)



function Particle.CreateOnEntity(dict, ptfx, entity, offset, rot, scale, color, looped, loopLength)
    if not IsNetworkOwner(entity) then
        print("[CreateOnEntity] Trying to play a particle on a non owned entity")
        return false
    end

    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    if looped then
        particle = StartNetworkedParticleFxLoopedOnEntity(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
        if loopLength then
            Wait(loopLength)
            RemoveParticleFxFromEntity(entity)
        end
    else
        particle = StartNetworkedParticleFxLoopedOnEntity(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, scale, false, false, false)
    end
    RemoveNamedPtfxAsset(ptfx)
    return particle
end

function Particle.CreateOnEntityBone(dict, ptfx, entity, bone,  offset, rot, scale, color, looped, loopLength)
    if not IsNetworkOwner(entity) then
        print("[CreateOnEntityBone] Trying to play a particle on a non owned entity")
        return false
    end

    LoadPtfxAsset(dict)
    UseParticleFxAssetNextCall(dict)
    SetParticleFxNonLoopedColour(color.x, color.y, color.z)
    local particle = nil
    if looped then
        particle = StartNetworkedParticleFxLoopedOnEntityBone(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, bone, scale, false, false, false)
        if loopLength then
            Wait(loopLength)
            RemoveParticleFxFromEntity(entity)
        end
    else
        particle = StartNetworkedParticleFxNonLoopedOnEntityBone(ptfx, entity, offset.x, offset.y, offset.z, rot.x, rot.y, rot.z, bone, scale, false, false, false)
    end
    RemoveNamedPtfxAsset(ptfx)
    return particle
end

return Particle