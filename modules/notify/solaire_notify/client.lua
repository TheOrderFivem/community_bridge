---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "solaire_notify"
local configValue = BridgeSharedConfig.Notify

if (configValue == "auto" and GetResourceState(resourceName) ~= "started")
    or (configValue ~= "auto" and configValue ~= resourceName)
then
    return
end

Notify.GetResourceName = function()
    return resourceName
end

local Language = Language or Require("modules/locales/shared.lua")
local locale = Language.Locale
local placeHolderText = locale("Notifications.PlaceholderTitle")

Notify.SendNotify = function(message, _type, time)
    time = time or 3000

    return exports.solaire_notify:Notify({ type = _type or "info", message = message, duration = time })
        type = _type or "info",
        message = message,
        duration = time,
    })
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type string
---@param time number
---@param props table | nil
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    if not title or title == "" then title = placeHolderText end

    props = props or {}

    return exports.solaire_notify:Notify({
        type = _type or "info",
        title = title,
        message = message,
        duration = time,
        position = props.position or "top-right",
        sound = props.sound,
        item = props.item,
        volume = props.volume
    })
end

return Notify