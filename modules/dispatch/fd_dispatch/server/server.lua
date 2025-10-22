if GetResourceState('fd_dispatch') == 'missing' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'fd_dispatch'
end

return Dispatch