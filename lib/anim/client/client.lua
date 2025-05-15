Anim = Anim or {}
Ids = Ids or Require("lib/utility/shared/ids.lua")
Anim.Active = Anim.Active or {}
Anim.isUpdateLoopRunning = Anim.isUpdateLoopRunning or false

--- This will request the animation dictionary.
--- @param animDict string
--- @return boolean
function Anim.RequestDict(animDict)
    if not animDict or type(animDict) ~= "string" then
        return false
    end

    if HasAnimDictLoaded(animDict) then
        return true
    end

    RequestAnimDict(animDict)
    local timeout = GetGameTimer() + 2000
    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(50)
    end

    return HasAnimDictLoaded(animDict)
end

--- This will start the animation update loop.
--- @return void
function Anim.Start()
    if Anim.isUpdateLoopRunning then return end
    Anim.isUpdateLoopRunning = true
    CreateThread(function()
        while Anim.isUpdateLoopRunning do
            local idsToProcess = {}
            for idKey, _ in pairs(Anim.Active) do
                table.insert(idsToProcess, idKey)
            end

            if #idsToProcess == 0 then
                Wait(750) 
            else
                for _, id in ipairs(idsToProcess) do
                    local animData = Anim.Active[id] 

                    if animData then 
                        local entity = animData.entity
                        local onComplete = animData.onComplete 

                        if not DoesEntityExist(entity) then
                            if onComplete then onComplete(false, "despawned") end
                            Anim.Active[id] = nil
                        elseif animData.status == "pending_task" then
                            TaskPlayAnim(entity, animData.animDict, animData.animName, animData.blendIn, animData.blendOut, animData.duration, animData.flag, animData.playbackRate, false, false, false)
                            animData.startTime = GetGameTimer()
                            animData.animEndTime = animData.duration > 0 and (animData.startTime + animData.duration) or -1
                            animData.status = "playing"

                        elseif animData.status == "playing" then
                            local animationCompletedNaturally = false
                            
                            if animData.duration == -1 then
                                if not IsEntityPlayingAnim(entity, animData.animDict, animData.animName, 3) and GetEntityAnimCurrentTime(entity, animData.animDict, animData.animName) > 0.8 then
                                    animationCompletedNaturally = true
                                end
                            elseif animData.animEndTime ~= -1 and GetGameTimer() >= animData.animEndTime then
                                animationCompletedNaturally = true
                            end

                            if animationCompletedNaturally then
                                if onComplete then onComplete(true, "completed") end
                                Anim.Active[id] = nil
                            end
                        end
                    end 
                end 
                Wait(100) 
            end 
        end 
    end)
end

--- This will play an animation on the specified ped.
--- @param id string | nil
--- @param entity number
--- @param animDict string
--- @param animName string
--- @param blendIn number | nil
--- @param blendOut number | nil
--- @param duration number | nil
--- @param flag number | nil
--- @param playbackRate number | nil
--- @param onComplete function | nil
--- @return string | nil
function Anim.Play(id, entity, animDict, animName, blendIn, blendOut, duration, flag, playbackRate, onComplete)
    local newId = id or Ids.CreateUniqueId(Anim.Active) 
    if Anim.Active[newId] then
        if onComplete then
            onComplete(false, "id_in_use")
        end
        return newId
    end

    if not entity or not DoesEntityExist(entity) or not IsEntityAPed(entity) then
        if onComplete then
            onComplete(false, "invalid_entity")
        end
        return nil
    end

    if not Anim.RequestDict(animDict) then
        if onComplete then
            onComplete(false, "dict_load_failed")
        end
        return nil 
    end

    Anim.Active[newId] = {
        entity = entity,
        animDict = animDict,
        animName = animName,
        blendIn = blendIn or 8.0,
        blendOut = blendOut or -8.0,
        duration = duration or -1,
        flag = flag or 1,
        playbackRate = playbackRate or 0.0,
        onComplete = onComplete,
        status = "pending_task", 
        startTime = 0,
        animEndTime = 0
    }

    Anim.Start()
    return newId
end

function Anim.Stop(id)
    if not id or not Anim.Active or not Anim.Active[id] then
        return false
    end

    local animData = Anim.Active[id]
    
    if animData.entity and DoesEntityExist(animData.entity) and IsEntityAPed(animData.entity) then
        if animData.status == "playing" or animData.status == "pending_task" then
             StopAnimTask(animData.entity, animData.animDict, animData.animName, 1.0)
        end
    end

    if animData.onComplete then
        animData.onComplete(false, "stopped_by_id")
    end

    Anim.Active[id] = nil 
    local anyLeft = Anim.Active and next(Anim.Active) ~= nil
    if not anyLeft then
        Anim.isUpdateLoopRunning = false
    end
    return true
end

return Anim