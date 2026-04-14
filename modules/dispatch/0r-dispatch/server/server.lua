---@diagnostic disable: duplicate-set-field
if GetResourceState('0r-dispatch') == 'missing' then return end

Dispatch = Dispatch or {}

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return '0r-dispatch'
end

return Dispatch
