Dispatch = Dispatch or {}

RegisterNetEvent("community_bridge:Server:DispatchAlert", function(data)
    local jobs = data.jobs
    for _, name in pairs(jobs) do
        local activeJobPlayers = Bridge.Framework.GetPlayersByJob(name)
        for src, _ in pairs(activeJobPlayers) do
            TriggerClientEvent('community_bridge:Client:DispatchAlert', src, data)
        end
    end
end)

return Dispatch