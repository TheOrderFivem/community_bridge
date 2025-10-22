---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_skin') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end
if GetResourceState('17mov_CharacterSystem') ~= 'missing' then return end

Clothing = Clothing or {}

Components = {}
Components.Map = {
    [1] = 'mask', -- componentId
    [2] = 'ears',
    [3] = 'arms',
    [4] = 'pants',
    [5] = 'bags',
    [6] = 'shoes',
    [7] = 'chain',
    [8] = 'tshirt',
    [9] = 'bproof',
    [10] = 'decals',
    [11] = 'torso'
}

Components.InverseMap = {
    mask = 1, -- componentId
    arms = 3,
    pants = 4,
    bags = 5,
    shoes = 6,
    chain = 7,
    tshirt = 8,
    bproof = 9,
    decals = 10,
    torso = 11,
}

Props = {}
Props.Map = {
    [0] = 'helmet', -- propId
    [1] = 'glasses',
    [2] = 'ears',
    [6] = 'watches',
    [7] = 'bracelets'
}

Props.InverseMap = {
    helmet_1 = 0,
    helmet_2 = 0,
    glasses_1 = 1,
    glasses_2 = 1,
    ears_1 = 2,
    ears_2 = 2,
    watches_1 = 6,
    watches_2 = 6,
    bracelets_1 = 7,
    bracelets_2 = 7,
}

-- Converts from illinium format to esx format
function Components.ConvertFromDefault(defaultComponents)
    local returnComponents = {}
    for index, componentData in pairs(defaultComponents or {}) do
        local componentId = Components.Map[componentData.component_id]
        if componentId then
            returnComponents[componentId .. '_1'] = componentData.drawable
            returnComponents[componentId .. '_2'] = componentData.texture
        end
    end
    return returnComponents
end

function Components.ConvertToDefault(esxComponents)
    local returnComponents = {}
    for componentIndex, componentData in pairs(esxComponents or {}) do
        local isTexture = componentIndex:find('_2')
        componentIndex = componentIndex:gsub('_1', ''):gsub('_2', '')
        local componentId = Components.InverseMap[componentIndex]
        if componentId then
            if isTexture then
                returnComponents[componentId] = returnComponents[componentId] or {}
                returnComponents[componentId].texture = componentData
            else
                returnComponents[componentId] = returnComponents[componentId] or {}
                returnComponents[componentId].component_id = componentId
                returnComponents[componentId].drawable = componentData
                returnComponents[componentId].texture = returnComponents[componentId].texture or 0
            end
        end
    end
    return returnComponents
end

function Props.ConvertFromDefault(defaultProps)
    local returnProps = {}
    for index, propData in pairs(defaultProps or {}) do
        local propId = Props.Map[propData.prop_id]
        if propId then
            returnProps[propId .. '_1'] = propData.drawable
            returnProps[propId .. '_2'] = propData.texture
        end
    end
    return returnProps
end

function Props.ConvertToDefault(esxProps)
    local returnProps = {}
    for propIndex, propData in pairs(esxProps or {}) do
        local isTexture = propIndex:find('_2')
        propIndex = propIndex:gsub('_1', ''):gsub('_2', '')
        local propId = Props.InverseMap[propIndex]
        if propId then
            if isTexture then
                returnProps[propId] = returnProps[propId] or {}
                returnProps[propId].texture = propData
            else
                returnProps[propId] = returnProps[propId] or {}
                returnProps[propId].prop_id = propId
                returnProps[propId].drawable = propData
                returnProps[propId].texture = returnProps[propId].texture or 0
            end
        end
        table.sort(returnProps, function(a, b)
            return a.prop_id < b.prop_id
        end)
    end
    return returnProps
end

function Clothing.ConvertFromDefault(defaultClothing)
    local components = Components.ConvertFromDefault(defaultClothing.components)
    local props = Props.ConvertFromDefault(defaultClothing.props)

    for propsIndex, propData in pairs(props) do
        components[propsIndex] = propData
    end

    return components --skin
end

function Clothing.ConvertToDefault(esxClothing)
    local components = Components.ConvertToDefault(esxClothing)
    local props = Props.ConvertToDefault(esxClothing)
    return { components = components, props = props }
end