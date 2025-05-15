local resourceName = "gksphone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Phone = Phone or {}

---comment
---@param email string
---@param title string
---@param message string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(email, title, message)
    return exports["gksphone"]:SendNewMail({ sender = email, image = '/html/static/img/icons/mail.png', subject = title, message = message })
end

return Phone