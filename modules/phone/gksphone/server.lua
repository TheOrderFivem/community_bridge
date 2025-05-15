local resourceName = "gksphone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Phone = Phone or {}

---comment
---@param src number
---@return number| boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.GetPlayerPhone = function(src)
    return exports["gksphone"]:GetPhoneBySource(src) or false
end

---comment
---@param src number
---@param email string
---@param title string
---@param message string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(src, email, title, message)
    local data = {}
    data.sender = email
    data.image = '/html/static/img/icons/mail.png'
    data.subject = title
    data.message = message
    exports["gksphone"]:SendNewMail(src, data)
    return true
end

return Phone