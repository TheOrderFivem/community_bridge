---@diagnostic disable: duplicate-set-field
if GetResourceState('0r-clothing') == 'missing' and GetResourceState('0r-clothingv2') == 'missing' then return end

Clothing = Clothing or {}

---This will get the name of the in use resource.
---@return string
function Clothing.GetResourceName()
    return '0r-clothing'
end

return Clothing
