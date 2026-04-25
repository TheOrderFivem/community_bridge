---@diagnostic disable: duplicate-set-field
if GetResourceState('plt_departments') == 'missing' then return end

Dispatch = Dispatch or {}

---This will send an alert to currently supported dispatch systems.
---@param data table The data to send to the dispatch system.
---@return nil
Dispatch.SendAlert = function(data)
    local ped = PlayerPedId()
    local coords = data.coords or GetEntityCoords(ped)
    local location = "Unknown"
    
    -- Getting the street or zone name
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    if zone then 
        location = GetLabelText(zone) 
    end

    TriggerServerEvent('community_bridge:Server:plt_departments:SendAlert', {
        code = data.code or '10-80',
        title = data.message or 'Unknown Alert',
        location = location,
        coords = coords,
        info = data.message or ''
    })
end

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'plt_departments'
end

return Dispatch
