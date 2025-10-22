if GetResourceState('emergencydispatch') == 'missing' then return end
Dispatch = Dispatch or {}

RegisterNetEvent("community_bridge:server:dispatch:sendAlert", function(data)
    local job = data.job or data.jobs[1] or 'police'
    local message = data.message or "An Alert Has Been Made"
    local coords = data.coords or vector3(0, 0, 0)

    TriggerEvent('emergencydispatch:emergencycall:new', job, message, coords, true)
end)

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'emergencydispatch'
end

return Dispatch