---@diagnostic disable: duplicate-set-field
if GetResourceState('kibra-dispatch') == 'missing' then return end

Dispatch = Dispatch or {}

---This will send an alert using kibra-dispatch
---@param data table The data to send to the dispatch system.
---@return nil
Dispatch.SendAlert = function(data)
    local label = data.message or "Dispatch Alert"
    local code = data.code or "10-80"
    local icon = data.icon or "fa-bell"
    
    -- Ensuring jobs matches {"police"} table array structure required by kibra-dispatch
    local receivers = data.jobs or {"police"}
    if type(receivers) == "string" then receivers = {receivers} end
    
    local blipId = (data.blipData and data.blipData.sprite) or 161
    
    exports["kibra-dispatch"]:SendAlert(label, code, icon, receivers, blipId)
end


---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'kibra-dispatch'
end

return Dispatch
