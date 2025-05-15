Cache = Require("lib/cache/shared/cache.lua")
local PlayerPedId = PlayerPedId
local GetVehiclePedIsIn = GetVehiclePedIsIn
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local GetPedInVehicleSeat = GetPedInVehicleSeat
local GetPlayerServerId = GetPlayerServerId
local GetSelectedPedWeapon = GetSelectedPedWeapon
local PlayerId = PlayerId


-- Comparison functions for client-side state

--- Get the player's ped ID
---@return integer
function GetPed()
    return PlayerPedId()
end

--- Get the vehicle the player is in, if any
---@return integer | nil
function GetVehicle()
    local ped = Cache.Get("Ped") -- Use cached ped for efficiency
    if not ped then return end   -- Or handle error/default case
    return GetVehiclePedIsIn(ped, false)
end

--- Get the seat of the player in the vehicle if the vehicle is occupied
---@return integer | nil
function GetVehicleSeat()
    local vehicle = Cache.Get("Vehicle")
    if not vehicle then return end
    local ped = Cache.Get("Ped")
    if not ped then return end
    for i = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
        if ped == GetPedInVehicleSeat(vehicle, i) then
            return i
        end
    end
end

---Get The Server ID of the player
---@return integer | nil
function GetServerId()
    local ped <const> = PlayerId()
    if not ped then return end -- Return unarmed hash if no ped
    return GetPlayerServerId(ped)
end

--- Get the current weapon of the player
--- @return integer | nil
function GetWeapon()
    local ped = Cache.Get("Ped")
    if not ped then return end -- Return unarmed hash if no ped
    return GetSelectedPedWeapon(ped)
end


Cache.Create("Ped", GetPed, nil)           -- Check ped only once as param is nil
Cache.Create("Vehicle", GetVehicle, 500)   -- Check vehicle every 500ms
Cache.Create("Seat", GetVehicleSeat, 500)  -- Check if in vehicle every 500ms
Cache.Create("Weapon", GetWeapon, 250)     -- Check weapon every 250ms
Cache.Create("ServerId", GetServerId, nil) -- Check server ID only once as param is nil

return Cache
