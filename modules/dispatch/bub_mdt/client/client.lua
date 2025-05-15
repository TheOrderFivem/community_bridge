if GetResourceState('bub-mdt') ~= 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local alertData = {
        code = data.code or '10-80',
        offense = data.message,
        coords = data.coords or GetEntityCoords(cache.ped),
        info = { label = data.code or '10-80', icon = data.icon or 'fas fa-question' },
        blip = data.blipData.sprite or 1,
        isEmergency = data.priority == 1 and true or false,
        blipCoords = data.coords or cache.ped and GetEntityCoords(cache.ped) or { x = 0, y = 0},
    }
    exports["bub-mdt"]:CustomAlert(alertData)
end

return Dispatch