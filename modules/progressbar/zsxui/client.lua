---@diagnostic disable: duplicate-set-field
local resourceName = "ZSX_UIV2"
local configValue = BridgeClientConfig.ProgressBarSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

ProgressBar = ProgressBar or {}

ProgressBar.GetResourceName = function()
    return "ZSX_UIV2"
end

---This function converts an Ox progress bar options table to ZSX_UIV2 format.
---@param options table
---@return table
local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop?[1] or options.prop or {}
    local prop2 = options.prop?[2] or {}

    return {
        label = options.label,
        duration = options.duration,
        canCancel = options.canCancel,
        disableControls = {
            disable_mouse = options.disable?.mouse,
            disable_walk = options.disable?.move,
            disable_driving = options.disable?.car,
            disable_combat = options.disable?.combat
        },
        anim = options.anim and {
            dict = options.anim.dict,
            clip = options.anim.clip,
            flag = options.anim.flag or 49
        } or nil,
        prop1 = prop1.model and {
            model = prop1.model,
            bone = prop1.bone,
            pos = prop1.pos,
            rot = prop1.rot
        } or nil,
        prop2 = prop2.model and {
            model = prop2.model,
            bone = prop2.bone,
            pos = prop2.pos,
            rot = prop2.rot
        } or nil
    }
end

---This function converts a QB progress bar options table to ZSX_UIV2 format.
---@param options table
---@return table
local function convertFromQB(options)
    if not options then return options end

    return {
        label = options.label,
        duration = options.duration,
        canCancel = options.canCancel,
        disableControls = {
            disable_mouse = options.controlDisables?.disableMouse,
            disable_walk = options.controlDisables?.disableMovement,
            disable_driving = options.controlDisables?.disableCarMovement,
            disable_combat = options.controlDisables?.disableCombat
        },
        anim = options.animation and {
            dict = options.animation.animDict,
            clip = options.animation.anim,
            flag = options.animation.flags or 49
        } or nil,
        prop1 = options.prop and options.prop.model and {
            model = options.prop.model,
            bone = options.prop.bone,
            pos = options.prop.coords,
            rot = options.prop.rotation
        } or nil,
        prop2 = options.propTwo and options.propTwo.model and {
            model = options.propTwo.model,
            bone = options.propTwo.bone,
            pos = options.propTwo.coords,
            rot = options.propTwo.rotation
        } or nil
    }
end

---This function opens a progress bar.
---@param options table
---@param cb any
---@param qbFormat boolean
---@return boolean boolean
function ProgressBar.Open(options, cb, qbFormat)
    if not exports['ZSX_UIV2'] then return false end

    if qbFormat then
        options = convertFromQB(options)
    else
        options = convertFromOx(options)
    end
    local prom = promise.new()
    exports['ZSX_UIV2']:ProgressBar(
        'fas fa-circle-notch',
        options.label,
        options.duration or 5000,
        function()
            if cb then cb(true) end
            prom:resolve(true)
        end,
        function()
            if cb then cb(false) end
            prom:resolve(false)
        end,
        options.canCancel,
        options.disableControls,
        options.anim,
        options.prop1,
        options.prop2
    )
    return Citizen.Await(prom)
end

return ProgressBar