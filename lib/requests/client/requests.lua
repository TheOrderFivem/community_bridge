Requests = Requests or {}

---@async
---@generic T : string | number
---@param request function
---@param hasLoaded function
---@param assetType string
---@param asset T
---@param timeout? number
---@param ... any
---@return T
function Requests.Streaming(request, hasLoaded, assetType, asset, timeout, ...)
    if hasLoaded(asset) then return asset end

    request(asset, ...)

    return cLib.WaitFor(function()
        if hasLoaded(asset) then return asset end
    end, ("failed to load %s '%s' - this may be caused by\n- too many loaded assets\n- oversized, invalid, or corrupted assets"):format(assetType, asset),
    timeout or 30000)
end

---@param animDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 10000.
---@return string animDict
function Requests.AnimDict(animDict, timeout)
    if HasAnimDictLoaded(animDict) then return animDict end

    if type(animDict) ~= 'string' then
        error(("expected animDict to have type 'string' (received %s)"):format(type(animDict)))
    end

    if not DoesAnimDictExist(animDict) then
        error(("attempted to load invalid animDict '%s'"):format(animDict))
    end

    return Requests.Streaming(RequestAnimDict, HasAnimDictLoaded, 'animDict', animDict, timeout)
end

---@param audioBank string
---@param timeout number?
---@return string
function Requests.AudioBank(audioBank, timeout)
    return cLib.WaitFor(function()
        if RequestScriptAudioBank(audioBank, false) then return audioBank end
    end, ("failed to load audiobank '%s' - this may be caused by\n- too many loaded assets\n- oversized, invalid, or corrupted assets"):format(audioBank), timeout or 30000)
end

---@param animSet string
---@param timeout number? Approximate milliseconds to wait for the clipset to load. Default is 10000.
---@return string animSet
function Requests.AnimSet(animSet, timeout)
    if HasAnimSetLoaded(animSet) then return animSet end

    if type(animSet) ~= 'string' then
        error(("expected animSet to have type 'string' (received %s)"):format(type(animSet)))
    end

    return Requests.Streaming(RequestAnimSet, HasAnimSetLoaded, 'animSet', animSet, timeout)
end

---@param model number | string
---@param timeout number? Approximate milliseconds to wait for the model to load. Default is 10000.
---@return number model
function Requests.Model(model, timeout)
    if type(model) ~= 'number' then model = joaat(model) end
    if HasModelLoaded(model) then return model end

    if not IsModelValid(model) and not IsModelInCdimage(model) then
        error(("attempted to load invalid model '%s'"):format(model))
    end

    return Requests.Streaming(RequestModel, HasModelLoaded, 'model', model, timeout)
end

---@param ptFxName string
---@param timeout number? Approximate milliseconds to wait for the particle effect to load. Default is 10000.
---@return string ptFxName
function Requests.NamedPtfxAsset(ptFxName, timeout)
    if HasNamedPtfxAssetLoaded(ptFxName) then return ptFxName end

    if type(ptFxName) ~= 'string' then
        error(("expected ptFxName to have type 'string' (received %s)"):format(type(ptFxName)))
    end

    return Requests.Streaming(RequestNamedPtfxAsset, HasNamedPtfxAssetLoaded, 'ptFxName', ptFxName, timeout)
end

---@param scaleformName string
---@param timeout number? Approximate milliseconds to wait for the scaleform movie to load. Default is 1000.
---@return number? scaleform
function Requests.ScaleformMovie(scaleformName, timeout)
    if type(scaleformName) ~= 'string' then
        error(("expected scaleformName to have type 'string' (received %s)"):format(type(scaleformName)))
    end

    local scaleform = RequestScaleformMovie(scaleformName)

    return cLib.WaitFor(function()
        if HasScaleformMovieLoaded(scaleform) then return scaleform end
    end, ("failed to load scaleformMovie '%s'"):format(scaleformName), timeout)
end

---@param textureDict string
---@param timeout number? Approximate milliseconds to wait for the dictionary to load. Default is 10000.
---@return string textureDict
function Requests.StreamedTextureDict(textureDict, timeout)
    if HasStreamedTextureDictLoaded(textureDict) then return textureDict end

    if type(textureDict) ~= 'string' then
        error(("expected textureDict to have type 'string' (received %s)"):format(type(textureDict)))
    end

    return Requests.Streaming(RequestStreamedTextureDict, HasStreamedTextureDictLoaded, 'textureDict', textureDict, timeout)
end

---@alias WeaponResourceFlags
---| 1 WRF_REQUEST_BASE_ANIMS
---| 2 WRF_REQUEST_COVER_ANIMS
---| 4 WRF_REQUEST_MELEE_ANIMS
---| 8 WRF_REQUEST_MOTION_ANIMS
---| 16 WRF_REQUEST_STEALTH_ANIMS
---| 32 WRF_REQUEST_ALL_MOVEMENT_VARIATION_ANIMS
---| 31 WRF_REQUEST_ALL_ANIMS

---@alias ExtraWeaponComponentFlags
---| 0 WEAPON_COMPONENT_NONE
---| 1 WEAPON_COMPONENT_FLASH
---| 2 WEAPON_COMPONENT_SCOPE
---| 4 WEAPON_COMPONENT_SUPP
---| 8 WEAPON_COMPONENT_SCLIP2
---| 16 WEAPON_COMPONENT_GRIP

---@param weaponType string | number
---@param timeout number? Approximate milliseconds to wait for the asset to load. Default is 10000.
---@param weaponResourceFlags WeaponResourceFlags? Default is 31.
---@param extraWeaponComponentFlags ExtraWeaponComponentFlags? Default is 0.
---@return string | number weaponType
function Requests.WeaponAsset(weaponType, timeout, weaponResourceFlags, extraWeaponComponentFlags)
    if HasWeaponAssetLoaded(weaponType) then return weaponType end

    local weaponTypeType = type(weaponType) --kekw

    if weaponTypeType ~= 'string' and weaponTypeType ~= 'number' then
        error(("expected weaponType to have type 'string' or 'number' (received %s)"):format(weaponTypeType))
    end

    if weaponResourceFlags and type(weaponResourceFlags) ~= 'number' then
        error(("expected weaponResourceFlags to have type 'number' (received %s)"):format(type(weaponResourceFlags)))
    end

    if extraWeaponComponentFlags and type(extraWeaponComponentFlags) ~= 'number' then
        error(("expected extraWeaponComponentFlags to have type 'number' (received %s)"):format(type(extraWeaponComponentFlags)))
    end

    return Requests.Streaming(RequestWeaponAsset, HasWeaponAssetLoaded, 'weaponHash', weaponType, timeout, weaponResourceFlags or 31, extraWeaponComponentFlags or 0)
end

return Requests