---@diagnostic disable: duplicate-set-field

Particles = {}
Particle = Particles or {}

function Particle.New(data)
    assert(data, "Particle data is nil")
    assert(data.dict, "Invalid particle data. Must contain string dict.")
    assert(data.ptfx, "Invalid particle data. Must contain string ptfx.")

    local _id = data.id or id.CreateUniqueId(Particles)
    data = {
        id = _id,
        dict = data.dict,
        ptfx = data.ptfx,
        position = data.position or vector3(0.0, 0.0, 0.0),
        rotation = data.rotation or vector3(0, 0, 0),
        size = data.size or 1.0,
        color = data.color or vector3(255, 255, 255),
        looped = data.looped or false,
        loopLength = data.loopLength or nil,
    }
    Particles[_id] = data 
    return data
end

function Particle.Destroy(id)
    if not id or not Particles[id] then return end
    Particles[id] = nil
    return true
end

function Particle.Create(data)
    local particleData = Particle.New(data)
    if not particleData then return end
    TriggerClientEvent("community_bridge:Client:Particle", -1, particleData)
    return
end

    
function Particle.Remove(id)
    if not Particle.Destroy(id) then return end    
    TriggerClientEvent("community_bridge:Client:ParticleRemove", -1, id)
end
   
function Particle.CreateBulk(datas)
    if not datas then return end
    local toClient = {}
    for k, v in pairs(datas) do
        local data = Particle.New(v)
        table.insert(toClient, data)
    end
    TriggerClientEvent("community_bridge:Client:ParticleBulk", -1, toClient)
    return toClient
end

function Particle.RemoveBulk(ids)
    if not ids then return end
    local toClient = {}
    for k, v in pairs(ids) do
        local id = v
        if type(v) == "table" then
            id = v.id
        end
        Particle.Destroy(id)
        table.insert(toClient, id)
    end
    TriggerClientEvent("community_bridge:Client:ParticleRemoveBulk", -1, toClient)
    return ids
end

return Particle