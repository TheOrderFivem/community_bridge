Batch = Batch or {}
Batch.Event = Batch.Event or {}
Batch.Event.Queued = Batch.Event.Queued or {}
Batch.Event.IsQueued = Batch.Event.IsQueued or false

local SERVER = IsDuplicityVersion()

-- could do a callback from client to server back to client with a time stamp. Use that timestamp to generate some random string/number and use that fo
-- this event name. Would help by masking from exploits. Thinking about making a module out of it

--- This is used to batch single events together to reduce network strain
--- 
if SERVER then
    function Batch.Event.Queue(src, event, ...)
        if src == -1 then
            src = GetPlayers()
            for k, v in pairs(src) do
                local strSrc = tostring(v)   
                Batch.Event.Queued[strSrc] = Batch.Event.Queued[strSrc] or {}
                table.insert(Batch.Event.Queued[strSrc], {
                    src = v,
                    event = event,
                    args = {...}
                })
            end
        else
            local strSrc = tostring(src)   
            Batch.Event.Queued[strSrc] = Batch.Event.Queued[strSrc] or {}
            table.insert(Batch.Event.Queued[strSrc], {
                src = src,
                event = event,
                args = {...}
            })
        end

        if Batch.Event.IsQueued then return end
        Batch.Event.IsQueued = true
        SetTimeout(100, function()
            for k, v in pairs(Batch.Event.Queued) do
                TriggerClientEvent('community_bridge:client:BatchEvents', v.src, v)
            end  
            Batch.Event.IsQueued = false
            Batch.Event.Queued = {}
        end)
    end
    return Batch
else

    Batch.Event.Fire = function(array)
        local playerSrc = PlayerId()
        for k, v in pairs(array) do
            if v.src == playerSrc then
                local event = v.event
                local args = v.args
                TriggerEvent(event, table.unpack(args))
            end
        end
    end

    RegisterNetEvent('community_bridge:client:BatchEvents', function(array)
        Batch.Event.Fire(array)
    end)

    return Batch
end