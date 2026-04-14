---@diagnostic disable: duplicate-set-field
if GetResourceState('0r-vehiclekeys') == 'missing' then return end

VehicleKey = VehicleKey or {}

---Gives the player (self) the keys of the specified vehicle.
---@param vehicle number The vehicle entity handle.
---@param plate? string The plate of the vehicle.
---@return nil
VehicleKey.GiveKeys = function(vehicle, plate)
    if not plate and vehicle then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    if plate then
        exports['0r-vehiclekeys']:GiveKeys(plate)
    end
end

---Removes the keys of the specified vehicle from the player (self).
---@param vehicle number The vehicle entity handle.
---@param plate? string The plate of the vehicle.
---@return nil
VehicleKey.RemoveKeys = function(vehicle, plate)
    if not plate and vehicle then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    if plate then
        exports['0r-vehiclekeys']:RemoveKeys(plate)
    end
end

---Checks whether the key for the vehicle is in the player's inventory or metadata.
---@param vehicle number
---@param plate? string
---@return boolean
VehicleKey.HasKeys = function(vehicle, plate)
    if not plate and vehicle then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    if plate then
        return exports['0r-vehiclekeys']:HasKeys(plate)
    end
    return false
end

VehicleKey.GetResourceName = function()
    return "0r-vehiclekeys"
end

return VehicleKey
