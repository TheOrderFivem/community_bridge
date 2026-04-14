---@diagnostic disable: duplicate-set-field
if GetResourceState('frkn-uikit') == 'missing' then return end

Notify = Notify or {}

Notify.GetResourceName = function()
    return "frkn-uikit"
end

---DEPRICATED: PLEASE SWITCH TO Notify.SendNotification
Notify.SendNotify = function(message, _type, time)
    Notify.SendNotification(nil, message, _type, time)
end

---This will send a notify message of the type and time passed
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    
    local combinedMessage = message
    if title and title ~= "" and title ~= "Notify" then
        combinedMessage = "**" .. title .. "**\n" .. message
    end
    
    if not _type or _type == "" then
        _type = "info"
    end

    exports['frkn-uikit']:Notify(_type, time, combinedMessage)
end

RegisterNetEvent('community_bridge:Client:Notify', function(title, message, _type, time, props)
    Notify.SendNotification(title, message, _type, time, props)
end)

return Notify
