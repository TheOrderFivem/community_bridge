local Shop = {
    property = "stash",
    default = {
        flags = 49,
        duration = -1
    }
}

function Shop.OnCreate(entityData)
    if not entityData.stash then return end
    if IsDuplicityVersion() then 
        local label = entityData.stash.label or "default_stash_label"
        local slots = entityData.stash.slots or 20
        local weight = entityData.stash.maxWeight or 100000
        local owner = entityData.stash.owner
        local groups = entityData.stash.groups
        Bridge.Inventory.RegisterShop(entityData.id, label, slots, weight, owner, groups)
    else
        entityData.targets = entityData.targets or {}        
        table.insert(entityData.targets,
            {
                label = entityData.stash.target.label or "Shop",
                icon = entityData.stash.target.icon or "fa-solid fa-box",
                onSelect = function()                    
                    TriggerServerEvent("community_bridge:server:OpenShop", entityData.id)
                end
            }
        )
    end    
end

if not IsDuplicityVersion() then return Shop end

RegisterNetEvent("community_bridge:server:OpenShop", function(id)
    local src = source
    if not src then return end
    local entityData = Bridge.ServerEntity.Get(id)
    if not entityData or not entityData.stash then 
        return print(string.format("[Shop] OpenShop: Entity %s does not exist or has no stash", id)) 
    end
    local coords = entityData.coords
    if not coords then return end
    local distance = #(GetEntityCoords(GetPlayerPed(src)) - coords)
    if distance > 3.0 then 
        return print(string.format("[Shop] OpenShop: Player %s is too far from entity %s", src, id)) 
    end
    Bridge.Inventory.OpenShop(src, "stash", id)
end)

return Shop