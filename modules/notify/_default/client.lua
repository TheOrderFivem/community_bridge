Notify = Notify or {}

---@diagnostic disable-next-line: duplicate-set-field
Notify.GetResourceName = function()
    return "none"
end

---This will send a notify message of the type and time passed
---@param message string
---@param _type string
---@param time number
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    return Framework.Notify(message, nil, time)
end

RegisterNetEvent('community_bridge:Client:Notify', function(message, _type, time)
    Notify.SendNotify(message, _type, time)
end)

---------[[Depricated Stuff Below, please adjust to the HelpText module instead]]--------

---Depricated: This will hide the help text message on the screen
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
Notify.HideHelpText = function()
    return HelpText.HideHelpText()
end

---Depricated: This will show a help text message at the screen position passed
---@param message string
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
Notify.ShowHelpText = function(message, position)
    return HelpText.ShowHelpText(message, position)
end

return Notify