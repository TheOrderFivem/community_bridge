---@diagnostic disable: duplicate-set-field
if GetResourceState('frkn-uikit') == 'missing' then return end

Notify = Notify or {}

local Language = Language or Require("modules/locales/shared.lua")
local locale = Language.Locale
local placeHolderText = locale("Notifications.PlaceholderTitle")

Notify.GetResourceName = function()
    return "frkn-uikit"
end

---DEPRICATED: PLEASE SWITCH TO Notify.SendNotification
Notify.SendNotify = function(src, message, _type, time)
    Notify.SendNotification(src, nil, message, _type, time)
end

---This will send a notify message of the type and time passed
Notify.SendNotification = function(src, title, message, _type, time, props)
    time = time or 3000
    if not title then
        title = placeHolderText
    end
    TriggerClientEvent('community_bridge:Client:Notify', src, title, message, _type, time, props)
end

return Notify
