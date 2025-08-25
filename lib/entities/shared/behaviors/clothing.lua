local Clothing = {
    property = "clothing",
    default = {
        components = {},
        props = {}
    }
}

function Clothing.ChangeClothes(entityData)
    if entityData.entityType ~= "ped" then return end
    local entity = entityData.spawned
    if not entity or not DoesEntityExist(entity) then return end
    if entityData.clothing?.components then
        for componentId, component in pairs(entityData.clothing.components) do
            SetPedComponentVariation(entity, component.component_id, component.drawable or 0, component.texture or 0, 0)
        end
    end
    if entityData.clothing?.props then
        for propId, prop in pairs(entityData.clothing.props) do
            SetPedPropIndex(entity, prop.prop_id, prop.drawable or 0, prop.texture or 0, true)
        end
    end
    entityData.oldClothing = entityData.clothing
end


function Clothing.OnSpawn(entityData)
    if not entityData.spawned or not entityData.clothing then return end
    Clothing.ChangeClothes(entityData)
    entityData.clothing.updating = false
end

function Clothing.OnRemove(entityData)
    if not entityData.spawned or not entityData.clothing then return end
    entityData.oldClothing = nil
    entityData.clothing.updating = true
end

function Clothing.OnUpdate(entityData)
    if not entityData.spawned or not entityData.clothing then return end
    if entityData.clothing.updating then return end
    entityData.clothing.updating = true
    if not entityData.oldClothing then
        Clothing.ChangeClothes(entityData)
        return
    end
    for componentId, component in pairs(entityData.clothing.components or {}) do
        local oldComponent = entityData.oldClothing.components and entityData.oldClothing.components[componentId]
        if not oldComponent or oldComponent.drawable ~= component.drawable or oldComponent.texture ~= component.texture then
            Clothing.ChangeClothes(entityData)
            return
        end
    end
    for propId, prop in pairs(entityData.clothing.props or {}) do
        local oldProp = entityData.oldClothing.props and entityData.oldClothing.props[propId]
        if not oldProp or oldProp.drawable ~= prop.drawable or oldProp.texture ~= prop.texture then
            Clothing.ChangeClothes(entityData)
            return
        end
    end
    SetTimeout(1000, function()
        if entityData.clothing then
            entityData.clothing.updating = false
        end
    end)
end

return Clothing