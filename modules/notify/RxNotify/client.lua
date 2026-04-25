---@diagnostic disable: duplicate-set-field
if GetResourceState('RxNotify') == 'missing' then return end

Notify = Notify or {}

Notify.GetResourceName = function()
    return "RxNotify"
end

---DEPRICATED: PLEASE SWITCH TO Notify.SendNotification
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    Notify.SendNotification(nil, message, _type, time)
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type string
---@param time number
---@param props table optional
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    -- Map to the RxNotify format: title, text, type, length, options
    exports['RxNotify']:Notify(title, message, _type, time, props)
end

RegisterNetEvent('community_bridge:Client:Notify', function(title, message, _type, time, props)
    Notify.SendNotification(title, message, _type, time, props)
end)

return Notify
