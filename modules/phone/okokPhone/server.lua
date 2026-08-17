---@diagnostic disable: duplicate-set-field
---@class NewEmail
---@field sender string
---@field recipients string[]
---@field subject string
---@field actions? EmailAction[]
---@field body string

---@class EmailAction
---@field id string
---@field label string
---@field event string?
---@field exports string?
---@field server boolean
---@field data any

local resourceName = "okokPhone"
if GetResourceState(resourceName) == 'missing' then return end
Phone = Phone or {}
Callback = Callback or Require("lib/callback/shared/callback.lua")

---This will get the name of the Phone system being being used.
---@return string
Phone.GetPhoneName = function()
    return resourceName
end

Phone.GetResourceName = function()
    return resourceName
end

---This will get the phone number of the passed source.
---@param src number
---@return number|boolean
Phone.GetPlayerPhone = function(src)
    return exports.okokPhone:getPhoneNumberFromSource(src) or false
end

---This will send an email to the passed source, email address, title and message.
---@param src number
---@param email string
---@param title string
---@param message string
---@return boolean
Phone.SendEmail = function(src, email, title, message)
    local senderAddress = exports.okokPhone:getEmailAddressFromSource(src) --[[ @as string? ]]
    if not senderAddress then return false end

    ---@type NewEmail
    local data = {
        sender = senderAddress,
        recipients = { email },
        subject = title,
        body = message,
    }

    local success = exports.okokPhone:sendEmail(data) --[[ @as boolean ]]
    return success
end

lib.callback.register('community_bridge:Callback:okokPhone:sendEmail', function(src, email, title, message)
    return Phone.SendEmail(src, email, title, message)
end)

return Phone