---@diagnostic disable: duplicate-set-field
if GetResourceState('plt_departments') == 'missing' then return end

Dispatch = Dispatch or {}

RegisterNetEvent('community_bridge:Server:plt_departments:SendAlert', function(alertData)
    local src = source
    -- Sending the call to the export
    pcall(function()
        exports['plt_departments']:CreateDispatchCall({
            code = alertData.code or '10-90',
            title = alertData.title or 'Unknown Call',
            location = alertData.location or 'Unknown',
            coords = alertData.coords or vector3(0.0, 0.0, 0.0),
            info = alertData.info or ''
        })
    end)
end)



---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'plt_departments'
end

return Dispatch
