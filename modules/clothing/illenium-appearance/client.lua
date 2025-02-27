if GetResourceState('illenium-appearance') ~= 'started' then return end
Clothing = Clothing or {}


function ConvertToIlleniumFormat(data)
    local illeniumData = {
        model = GetEntityModel(cache.ped) == `mp_m_freemode_01` and 'mp_m_freemode_01' or 'mp_f_freemode_01',
        components = {},
        props = {}
    }
    for i = 1, 11 do
        if data.components and data.components[i] then
            illeniumData.components[i] = data.components[i]
        elseif data[tostring(i)] then
            illeniumData.components[i] = {
                drawable = data[tostring(i)].drawable or data[tostring(i)][1],
                texture = data[tostring(i)].texture or data[tostring(i)][2],
            }
        end
    end
    for i = 1, 7 do
        if data.props and data.props[i] then
            illeniumData.props[i] = data.props[i]
        elseif data['p'..tostring(i)] then
            illeniumData.props[i] = {
                drawable = data['p'..tostring(i)].drawable or data['p'..tostring(i)][1],
                texture = data['p'..tostring(i)].texture or data['p'..tostring(i)][2],
            }
        end
    end

    return illeniumData
end


Clothing.SetAppearance = function(clothingData)
    local illeniumData = ConvertToIlleniumFormat(clothingData)
    ClothingBackup = Clothing.GetAppearance()
    exports['illenium-appearance']:setPedComponents(cache.ped, illeniumData.components)
    exports['illenium-appearance']:setPedProps(cache.ped, illeniumData.props)
    return true
end

Clothing.GetAppearance = function()
    local clothing = {
        components = exports['illenium-appearance']:getPedComponents(cache.ped),
        props = exports['illenium-appearance']:getPedProps(cache.ped)
    }
    return ConvertToIlleniumFormat(clothing)
end

Clothing.RestoreAppearance = function()
    if not next(ClothingBackup) then
        return false
    end
    return Clothing.SetAppearance(ClothingBackup)
end

Clothing.ReloadSkin = function()
    TriggerEvent("illenium-appearance:client:reloadSkin", true)
    return true
end

return {
    ConvertToIlleniumFormat = ConvertToIlleniumFormat
}