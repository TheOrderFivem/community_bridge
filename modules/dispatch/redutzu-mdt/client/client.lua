if GetResourceState('redutzu-mdt') ~= 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local streetName, _ = Utility.GetStreetNameAtCoords(data.coords)
    local alertData = {
        code = data.code or '10-80',
        message = data.message or "Dispatch Alert",
        street = streetName,
        time = data.time or 10000,
        coords = data.coords,
    }
    TriggerServerEvent("community_bridge:server:dispatch:sendAlert", alertData)
end

return Dispatch