---@diagnostic disable: duplicate-set-field
Notify = Notify or {}

Notify.GetResourceName = function()
    return "default"
end

---DEPRICATED: PLEASE SWITCH TO Notify.SendNotification
---12/13/25
---@param src number
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(src, message, _type, time)
    Notify.SendNotification(src, nil, message, _type, time)
end

---This will send a notify message of the type and time passed
---@param src number
---@param title string
---@param message string
---@param _type string
---@param time number
---@props table optional
---@return nil
Notify.SendNotification = function(src, title, message, _type, time, props)
    time = time or 3000
    if not title then
        title = lib.locale("Notifications.PlaceholderTitle")
    end
    TriggerClientEvent('community_bridge:Client:Notify', src, title, message, _type, time, props)
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