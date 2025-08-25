local Weapon = {
    property = "weapon",
    default = {
        name = "WEAPON_UNARMED",
        ammo = 0
    }
}

function Weapon.GiveWeapon(entityData)
    if entityData.entityType ~= "ped" then return end
    local entity = entityData.spawned

    if not entity or not DoesEntityExist(entity) then return end
    if entityData.weapon?.name then
        local ammo = entityData.weapon.ammo or 0
        local hash = GetHashKey(entityData.weapon.name)
        GiveWeaponToPed(entity, hash, ammo, false, true)
        TaskSwapWeapon(entity, true)
    end
    entityData.oldWeapon = entityData.weapon
end

function Weapon.OnSpawn(entityData)
    if not entityData.spawned or not entityData.weapon then return end
    Weapon.GiveWeapon(entityData)
    entityData.weapon.updating = false
end

function Weapon.OnRemove(entityData)
    if not entityData.spawned or not entityData.weapon then return end
    entityData.oldWeapon = nil
    entityData.weapon.updating = true
end

function Weapon.OnUpdate(entityData)
    if not entityData.spawned or not entityData.weapon then return end
    if entityData.weapon.updating then return end
    entityData.weapon.updating = true
    if not entityData.oldWeapon or entityData.oldWeapon.name ~= entityData.weapon.name then
        Weapon.GiveWeapon(entityData)
    end
    SetTimeout(1000, function()
        if entityData.weapon then
            entityData.weapon.updating = false
        end
    end)
end

return Weapon