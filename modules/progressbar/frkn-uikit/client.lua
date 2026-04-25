---@diagnostic disable: duplicate-set-field
local resourceName = "frkn-uikit"
local configValue = BridgeClientConfig.ProgressBarSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

ProgressBar = ProgressBar or {}

local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop and options.prop[1] or options.prop or {}
    local prop2 = options.prop and options.prop[2] or {}
    return {
        name = options.label,
        duration = options.duration,
        label = options.label,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disableControls = {
            disableMovement = options.disable and options.disable.move,
            disableCarMovement = options.disable and options.disable.car,
            disableMouse = options.disable and options.disable.mouse,
            disableCombat = options.disable and options.disable.combat
        },
        animation = {
            animDict = options.anim and options.anim.dict,
            anim = options.anim and options.anim.clip,
            flags = options.anim and options.anim.flag or 49
        },
        prop = {
            model = prop1.model,
            bone = prop1.bone,
            coords = prop1.pos,
            rotation = prop1.rot
        },
        propTwo = {
            model = prop2.model,
            bone = prop2.bone,
            coords = prop2.pos,
            rotation = prop2.rot
        }
    }
end

---This function opens a progress bar.
---@param options table
---@param cb any
---@param qbFormat boolean
---@return boolean boolean
function ProgressBar.Open(options, cb, qbFormat)
    if not exports['frkn-uikit'] then return false end

    if not qbFormat then
        options = convertFromOx(options)
    end
    
    local prom = promise.new()
    
    -- Ensuring fallback values so frkn-uikit doesn't break
    local pType = options.name or "progressbar-1"
    local pLabel = options.label or "Processing..."
    local pDuration = options.duration or 3000
    local pUseWhileDead = options.useWhileDead or false
    -- defaulting canCancel to true if nil
    local pCanCancel = options.canCancel
    if pCanCancel == nil then pCanCancel = true end
    
    local pControls = options.controlDisables or options.disableControls or {}
    local pAnim = options.animation or options.anim or {}
    local pProp = options.prop or {}
    local pPropTwo = options.propTwo or {}

    exports['frkn-uikit']:Progressbar(
        pType,
        pLabel,
        pDuration,
        pUseWhileDead,
        pCanCancel,
        pControls,
        pAnim,
        pProp,
        pPropTwo,
        function()
            if cb then cb(true) end
            prom:resolve(true)
        end,
        function()
            if cb then cb(false) end
            prom:resolve(false)
        end
    )
    
    return Citizen.Await(prom)
end

ProgressBar.GetResourceName = function()
    return resourceName
end

return ProgressBar
