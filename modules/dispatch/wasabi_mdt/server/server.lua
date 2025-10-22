if GetResourceState('wasabi_mdt') == 'missing' then return end
Dispatch = Dispatch or {}

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'wasabi_mdt'
end

return Dispatch