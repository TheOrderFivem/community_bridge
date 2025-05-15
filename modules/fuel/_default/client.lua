Fuel = Fuel or {}


---This will get the name of the Fuel being used (if a supported Fuel).
---@return string
Fuel.GetResourceName = function()
    return 'default'
end
---This will get the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@return number fuel The fuel level of the vehicle.
Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return GetVehicleFuelLevel(vehicle)
end

---This will set the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@param fuel number The fuel level to set.
---@return nil
Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    return SetVehicleFuelLevel(vehicle, fuel)
end

return Fuel