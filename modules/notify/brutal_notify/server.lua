---@diagnostic disable: duplicate-set-field
Notify = Notify or {}

---This will send a notification to the specified player of the passed message and type
---@param src number
---@param message string
---@param _type string
---@param time number
Notify.SendNotify = function(src, message, _type, time)
    TriggerClientEvent('brutal_notify:SendAlert', src, 'Notification', message, time, _type, false)   
end

---------[[Depricated Stuff Below, please adjust to the HelpText module instead]]--------
---Depricated -- This will show a help text message to the specified player at the screen position passed
---@param src number
---@param message string
---@param position string
Notify.ShowHelpText = function(src, message, position)
    return HelpText.ShowHelpText(src, message, position)
end

---Depricated -- This will hide the help text message on the screen for the specified player
---@param src number
Notify.HideHelpText = function(src)
    return HelpText.HideHelpText(src)
end

return Notify