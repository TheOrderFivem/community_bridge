---@diagnostic disable: duplicate-set-field
if GetResourceState('0r-clothing') == 'missing' and GetResourceState('0r-clothingv2') == 'missing' then return end

Clothing = Clothing or {}

---This will open the clothing menu for a player
function Clothing.OpenMenu()
    if GetResourceState('0r-clothingv2') ~= 'missing' then
        exports["0r-clothingv2"]:openClothStore("clothing")
    else
        TriggerEvent('0r-clothing:openCharacterCreationMenuWithoutReset')
    end
end


---This will get the name of the in use resource.
---@return string
function Clothing.GetResourceName()
    return '0r-clothing'
end

return Clothing
