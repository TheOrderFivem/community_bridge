---@diagnostic disable: duplicate-set-field
if GetResourceState('0r-dispatch') == 'missing' then return end

Dispatch = Dispatch or {}

---This will send an alert to currently supported dispatch systems.
---@param data table The data to send to the dispatch system.
---@return nil
Dispatch.SendAlert = function(data)
    local ped = PlayerPedId()
    
    -- Defining the alert data using 0r-dispatch structure
    -- Using the message as the alertLabel (used for config matching in 0r-dispatch)
    local alertLabel = data.message or "custom_alert"
    local code = data.code or "10-80"
    local icon = data.icon or "fa-bell"
    local coords = data.coords or GetEntityCoords(ped)
    local jobs = data.jobs or {"police"}
    
    local blipData = {
        blipId = (data.blipData and data.blipData.sprite) or 161,
        blipColor = (data.blipData and data.blipData.color) or 1,
        blipScale = (data.blipData and data.blipData.scale) or 1.0,
        jobs = jobs -- Serves as fallback in 0r-dispatch
    }
    
    local takePhoto = false
    
    -- Tries to call the export
    pcall(function()
        exports['0r-dispatch']:SendAlert(
            alertLabel,
            code,
            icon,
            blipData,
            takePhoto,
            jobs,
            coords
        )
    end)
end


---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return '0r-dispatch'
end

return Dispatch
