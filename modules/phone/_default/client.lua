Phone = Phone or {}

---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(email, title, message)
    return false, Print.Error('There Is No Phone Bridged.')
end

return Phone