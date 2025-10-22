---@diagnostic disable: duplicate-set-field

if GetResourceState('qb-clothing') == 'missing' then return end
if GetResourceState('rcore_clothing') ~= 'missing' then return end
if GetResourceState('17mov_CharacterSystem') ~= 'missing' then return end

Clothing = Clothing or {}

Components = {}
Components.Map = {
    [1] = "mask",
    [2] = "hair",
    [3] = "arms",
    [4] = "pants",
    [5] = "bag",
    [6] = "shoes",
    [7] = "accessory",
    [8] = "t-shirt",
    [9] = "vest",
    [10] = "decals",
    [11] = "torso2"
}
Components.InverseMap = {
    mask = 1,
    hair = 2,
    arms = 3,
    pants = 4,
    bag = 5,
    shoes = 6,
    accessory = 7,
    ['t-shirt'] = 8, --<--I HATE THAT
    vest = 9,
    decals = 10,
    torso2 = 11
}

Props = {}
Props.Map = {
    [0] = "hat",
    [1] = "glass",
    [2] = "ear",
    [6] = "watch",
    [7] = "bracelet"
}
Props.InverseMap = {
    hat = 0,
    glass = 1,
    ear = 2,
    watch = 6,
    bracelet = 7
}

function Components.ConvertFromDefault(defaultComponents)
    local returnComponents = {}
    for index, componentData in pairs(defaultComponents or {}) do
        local componentId = Components.Map[componentData.component_id]
        if componentId then
            returnComponents[componentId] = {
                item = componentData.drawable,
                texture = componentData.texture
            }
        end
    end
    return returnComponents
end

function Components.ConvertToDefault(qbComponents)
    local returnComponents = {}
    for componentIndex, componentData in pairs(qbComponents or {}) do
        local componentId = Components.InverseMap[componentIndex]
        if componentId then
            returnComponents[componentId] = {
                component_id = componentId,
                drawable = componentData.item,
                texture = componentData.texture
            }
        end
    end
    return returnComponents
end

function Props.ConvertFromDefault(defaultProps)
    local returnProps = {}
    for index, propData in pairs(defaultProps or {}) do
        local propId = Props.Map[propData.prop_id]
        if propId then
            returnProps[propId] = {
                item = propData.drawable,
                texture = propData.texture
            }
        end
    end
    return returnProps
end

function Props.ConvertToDefault(qbProps)
    local returnProps = {}
    for propIndex, propData in pairs(qbProps or {}) do
        local propId = Props.InverseMap[propIndex]
        if propId then
            table.insert(returnProps, {
                prop_id = propId,
                drawable = propData.item,
                texture = propData.texture
            })
        end
    end
    table.sort(returnProps, function(a, b)
        return a.prop_id < b.prop_id
    end)
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

function Clothing.ConvertToDefault(qbClothing)
    local components = Components.ConvertToDefault(qbClothing)
    local props = Props.ConvertToDefault(qbClothing)
    return { components = components, props = props }
end