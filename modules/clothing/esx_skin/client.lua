---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_skin') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end
if GetResourceState('17mov_CharacterSystem') ~= 'missing' then return end
Clothing = Clothing or {}

function Clothing.OpenMenu()
    TriggerEvent('esx_skin:openMenu', function() end, function() end, true)
end

---This will get the name of the in use resource.
---@return string
Clothing.GetResourceName = function()
    return 'esx_skin'
end