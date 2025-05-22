Dispatch = Dispatch or {}

RegisterNetEvent("community_bridge:Server:DispatchAlert", function(data)
    local jobs = data.jobs
    for _, name in pairs(jobs) do
        local activeJobPlayers = Framework.GetPlayersByJob(name)
        print("Active Job Players: ", json.encode(activeJobPlayers, {indent = true}))
        for _, src in pairs(activeJobPlayers) do
            TriggerClientEvent('community_bridge:Client:DispatchAlert', src, data)
        end
    end
end)

return Dispatch
