local Particle = {}

---Loads a ptfx asset into memory safely
---@param dict string
---@return boolean, string?
local function loadPtfxAssetSafe(dict)
    if not dict or type(dict) ~= "string" then
        return false, "Invalid particle dictionary"
    end

    local attempts = 10
    while not HasNamedPtfxAssetLoaded(dict) and attempts > 0 do
        local success = pcall(RequestNamedPtfxAsset, dict)
        if not success then
            return false, "Failed to request particle asset"
        end
        attempts = attempts - 1
        Wait(100)
    end

    return HasNamedPtfxAssetLoaded(dict), attempts <= 0 and "Timeout loading particle asset" or nil
end

---Validates vector3 parameters
---@param vec vector3
---@return boolean
local function isValidVector(vec)
    return vec and type(vec) == "table" and vec.x and vec.y and vec.z
end

---Create a particle effect at the specified position and rotation
---@param dict string
---@param ptfx string
---@param pos vector3
---@param rot vector3
---@param scale number
---@param color vector3
---@param looped boolean
---@param loopLength number|nil
---@return number|nil ptfxHandle, string? error
function Particle.Create(dict, ptfx, pos, rot, scale, color, looped, loopLength)
    if not (dict and ptfx) then return nil, "Missing required parameters" end
    if not (isValidVector(pos) and isValidVector(rot) and isValidVector(color)) then
        return nil, "Invalid vector parameters"
    end
    if type(scale) ~= "number" then return nil, "Invalid scale parameter" end

    local loaded, loadError = loadPtfxAssetSafe(dict)
    if not loaded then return nil, loadError end

    local success = pcall(UseParticleFxAssetNextCall, dict)
    if not success then return nil, "Failed to use particle asset" end

    pcall(SetParticleFxNonLoopedColour, color.x, color.y, color.z)

    local particle
    if looped then
        local ok, result = pcall(StartParticleFxLoopedAtCoord,
            ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z,
            scale, false, false, false, false)

        if not ok then return nil, "Failed to start looped particle" end
        particle = result

        if loopLength and type(loopLength) == "number" then
            CreateThread(function()
                Wait(loopLength)
                Particle.Remove(particle)
            end)
        end
    else
        local ok, result = pcall(StartParticleFxNonLoopedAtCoord,
            ptfx, pos.x, pos.y, pos.z, rot.x, rot.y, rot.z,
            scale, false, false, false, false)

        if not ok then return nil, "Failed to start non-looped particle" end
        particle = result
    end

    return particle
end

function Particle.Remove(particle)
    if not particle then return false, "Invalid particle handle" end

    pcall(StopParticleFxLooped, particle, false)
    pcall(RemoveParticleFx, particle, false)
    pcall(RemoveNamedPtfxAsset, particle)

    return true
end

function Particle.CreateOnEntity(dict, ptfx, entity, offset, rot, scale, color, looped, loopLength)
    if not entity or not DoesEntityExist(entity) then
        return nil, "Invalid entity"
    end
    if not (isValidVector(offset) and isValidVector(rot) and isValidVector(color)) then
        return nil, "Invalid vector parameters"
    end

    local loaded, loadError = loadPtfxAssetSafe(dict)
    if not loaded then return nil, loadError end

    local success = pcall(UseParticleFxAssetNextCall, dict)
    if not success then return nil, "Failed to use particle asset" end

    pcall(SetParticleFxNonLoopedColour, color.x, color.y, color.z)

    local particle
    if looped then
        local ok, result = pcall(StartNetworkedParticleFxLoopedOnEntity,
            ptfx, entity, offset.x, offset.y, offset.z,
            rot.x, rot.y, rot.z, scale, false, false, false)

        if not ok then return nil, "Failed to start looped particle on entity" end
        particle = result

        if loopLength and type(loopLength) == "number" then
            CreateThread(function()
                Wait(loopLength)
                if DoesEntityExist(entity) then
                    RemoveParticleFxFromEntity(entity)
                end
            end)
        end
    else
        local ok, result = pcall(StartNetworkedParticleFxNonLoopedOnEntity,
            ptfx, entity, offset.x, offset.y, offset.z,
            rot.x, rot.y, rot.z, scale, false, false, false)

        if not ok then return nil, "Failed to start non-looped particle on entity" end
        particle = result
    end

    pcall(RemoveNamedPtfxAsset, ptfx)
    return particle
end

function Particle.CreateOnEntityBone(dict, ptfx, entity, bone, offset, rot, scale, color, looped, loopLength)
    if not entity or not DoesEntityExist(entity) then
        return nil, "Invalid entity"
    end
    if not bone or type(bone) ~= "number" then
        return nil, "Invalid bone index"
    end
    if not (isValidVector(offset) and isValidVector(rot) and isValidVector(color)) then
        return nil, "Invalid vector parameters"
    end

    local loaded, loadError = loadPtfxAssetSafe(dict)
    if not loaded then return nil, loadError end

    local success = pcall(UseParticleFxAssetNextCall, dict)
    if not success then return nil, "Failed to use particle asset" end

    pcall(SetParticleFxNonLoopedColour, color.x, color.y, color.z)

    local particle
    if looped then
        local ok, result = pcall(StartNetworkedParticleFxLoopedOnEntityBone,
            ptfx, entity, offset.x, offset.y, offset.z,
            rot.x, rot.y, rot.z, bone, scale, false, false, false)

        if not ok then return nil, "Failed to start looped particle on entity bone" end
        particle = result

        if loopLength and type(loopLength) == "number" then
            CreateThread(function()
                Wait(loopLength)
                if DoesEntityExist(entity) then
                    RemoveParticleFxFromEntity(entity)
                end
            end)
        end
    else
        local ok, result = pcall(StartNetworkedParticleFxNonLoopedOnEntityBone,
            ptfx, entity, offset.x, offset.y, offset.z,
            rot.x, rot.y, rot.z, bone, scale, false, false, false)

        if not ok then return nil, "Failed to start non-looped particle on entity bone" end
        particle = result
    end

    pcall(RemoveNamedPtfxAsset, ptfx)
    return particle
end

return Particle
