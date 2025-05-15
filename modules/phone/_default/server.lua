Phone = Phone or {}

---@diagnostic disable-next-line: duplicate-set-field
Phone.GetPlayerPhone = function(src)
    return false, Print.Error('There Is No Phone Bridged.')
end

---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(src, email, title, message)
    return false, Print.Error('There Is No Phone Bridged.')
end

return Phone