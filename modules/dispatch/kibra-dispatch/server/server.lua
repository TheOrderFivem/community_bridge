---@diagnostic disable: duplicate-set-field
if GetResourceState('kibra-dispatch') == 'missing' then return end

Dispatch = Dispatch or {}

---Helper server wrapper just in case a server event directly calls Bridge.Dispatch.SendAlert
---@param source number
---@param data table
---@return nil
Dispatch.SendAlert = function(source, data)
    local label = data.message or "Dispatch Alert"
    local code = data.code or "10-80"
    local icon = data.icon or "fa-bell"
    
    local receivers = data.jobs or {"police"}
    if type(receivers) == "string" then receivers = {receivers} end
    
    local blipId = (data.blipData and data.blipData.sprite) or 161
    
    exports["kibra-dispatch"]:SendAlert(source, label, code, icon, receivers, blipId)
end


---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'kibra-dispatch'
end

return Dispatch
