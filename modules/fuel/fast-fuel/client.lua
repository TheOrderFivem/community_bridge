local resourceName = "fast-fuel"
if GetResourceState(resourceName) == 'missing' then return end
Fuel = Fuel or {}

---This will get the name of the Fuel being used (if a supported Fuel).
---@return string
Fuel.GetResourceName = function()
    return resourceName
end

---This will get the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@return number fuel The fuel level of the vehicle.
Fuel.GetFuel = function(vehicle)
    if not DoesEntityExist(vehicle) then return 0.0 end
    return exports['fast-fuel']:GetFuel(vehicle)
end

---This will set the fuel level of the vehicle.
---@param vehicle number The vehicle entity ID.
---@param fuel number The fuel level to set.
---@return nil
Fuel.SetFuel = function(vehicle, fuel)
    if not DoesEntityExist(vehicle) then return end
    exports['fast-fuel']:SetFuel(vehicle, fuel)
end

return Fuel