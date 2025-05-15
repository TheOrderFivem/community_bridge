local colourblind = GetResourceKvpString('colourblind') or "default"
local QB = false
if (BridgeClientConfig.MenuSystem == "auto" and GetResourceState("qb-menu") ~= "started") or (BridgeClientConfig.MenuSystem ~= "auto" and BridgeClientConfig.MenuSystem == "qb-menu") then
    QB = true
end

Accessibility = Accessibility or {}

RegisterCommand(locale("accessibility.cb_command"), function()
    Accessibility.updatecolourblindness()
end, false)

Accessibility.updatecolourblindness = function()
    local currentCB = locale("accessibility.cb_"..colourblind.."_title")
    local cbIcon = "fas fa-eye-low-vision"
    Menu.Open({
    id = 'colourblind_update',
    title = locale("accessibility.cb_title"),
    options = {
        {
            title = locale("accessibility.cb_title"),
            description = locale("accessibility.cb_desc"):format(currentCB),
            disabled = true,
        },
        {
            title = locale("accessibility.cb_default_title"),
            description = locale("accessibility.cb_default_desc"),
            icon = "fas fa-eye",
            onSelect = function()
                colourblind = "default"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
        {
            title = locale("accessibility.cb_protanomaly_title"),
            description = locale("accessibility.cb_protanomaly_desc"),
            icon = cbIcon,
            onSelect = function()
                colourblind = "protanomaly"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
        {
            title = locale("accessibility.cb_deuteranomaly_title"),
            description = locale("accessibility.cb_deuteranomaly_desc"),
            icon = cbIcon,
            onSelect = function()
                colourblind = "deuteranomaly"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
        {
            title = locale('accessibility.cb_dual_title'),
            description = locale("accessibility.cb_dual_desc"),
            icon = cbIcon,
            onSelect = function()
                colourblind = "dual"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
        {
            title = locale("accessibility.cb_tritanopia_title"),
            description = locale("accessibility.cb_tritanopia_desc"),
            icon = cbIcon,
            onSelect = function()
                colourblind = "tritanopia"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
        {
            title = locale("accessibility.cb_tritanomaly_title"),
            description = locale("accessibility.cb_tritanomaly_desc"),
            icon = cbIcon,
            onSelect = function()
                colourblind = "tritanomaly"
                SetResourceKvp('colourblind', colourblind)
                Notify.SendNotify(locale("accessibility.cb_updated"):format(locale("accessibility.cb_"..colourblind.."_title")), 'success', 3000)
            end
        },
    }},QB)
end
Accessibility.hexToRgb = function(hex)
    hex = hex:gsub("#", "")
    local r,g,b = tonumber("0x" .. hex:sub(1, 2)),tonumber("0x" .. hex:sub(3, 4)),tonumber("0x" .. hex:sub(5, 6))
    return r, g, b
end

Accessibility.rgbToHex = function(r, g, b)
    return string.format("#%02x%02x%02x", r, g, b)
end

Accessibility.rgbToHsl = function(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2

    if max == min then
        h, s = 0, 0 -- achromatic
    else
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then
            h = (b - r) / d + 2
        elseif max == b then
            h = (r - g) / d + 4
        end
        h = h / 6
    end
	return h, s, l
end

Accessibility.hslToRgb = function(h, s, l)
    local r, g, b
    if s == 0 then
        r, g, b = l, l, l -- achromatic
    else
        local function hue2rgb(p, q, t)
            if t < 0 then t = t + 1 end
            if t > 1 then t = t - 1 end
            if t < 1 / 6 then return p + (q - p) * 6 * t end
            if t < 1 / 2 then return q end
            if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
            return p
        end

        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q
        r = hue2rgb(p, q, h + 1 / 3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1 / 3)
    end
    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end

Accessibility.adjustColourForColourblindness = function(num, returnAsRGB)
    local r, g, b
    if type(num) ~= "table" and num:match("^#%x%x%x%x%x%x$") then
        r, g, b = Accessibility.hexToRgb(num) -- Convert hex to RGB
    else
        r, g, b = num.r, num.g, num.b -- If it's already RGB, use it directly
    end
    local h, s, l = Accessibility.rgbToHsl(r, g, b) -- Convert RGB to HSL
    -- Adjust hue values based on colourblindness type
    if colourblind == "protanomaly" then -- Red-blind
        -- Shift towards blue/cyan
        h = (h + 0.5) % 1 -- Shift by 180 degrees
    elseif colourblind == "deuteranomaly" then -- Green-blind
        -- Shift towards blue/magenta
        h = (h + 0.33) % 1 -- Shift by 120 degrees
    elseif colourblind == "dual" then -- Protanopia and Deuteranopia (Red-Green blind)
        -- More significant shift towards blue/yellow
        -- This is a more drastic shift to maximize contrast
        if h < 0.166 then -- Reddish hues
            h = 0.66 -- Shift to blue
        elseif h < 0.5 then -- Greenish hues
            h = 0.166 -- Shift to yellow
        else
            h = h -- Leave blue/purple hues alone
        end
        -- Increase saturation and lightness to make colours more distinct
        s = math.min(s * 1.5, 1)
        l = math.min(l * 1.2, 1)
    elseif colourblind == "tritanopia" then -- Blue-blind
        -- Shift towards red/yellow
        h = (h + 0.16) % 1 -- Shift by 60 degrees
    elseif colourblind == "tritanomaly" then
        h = (h + 0.08) % 1
    end

    -- Convert back to RGB
    r, g, b = Accessibility.hslToRgb(h, s, l)
    if returnAsRGB then
        return {r = r, g = g, b = b}
    else
    -- Convert back to HEX 
    local newHex = Accessibility.rgbToHex(r, g, b)
    return newHex
    end
end

---@returns a colour adjusted for colourblindness in HEX if variable `returnAsRGB` is false
---@param colourName string Colour name in HEX format or RGB format
-- This is the trigger function for altering colours for colourblindness :D
Accessibility.getAdjustedColour = function(colourName, returnAsRGB)
    local originalHex = colourName
    if originalHex then
        if colourblind == "default" then
            if type(colourName) == "table" and not returnAsRGB then
                return Accessibility.rgbToHex(colourName.r, colourName.g, colourName.b)
            else
                return originalHex
            end
        else
            return Accessibility.adjustColourForColourblindness(originalHex, returnAsRGB)
        end
    else
        Prints.Error("Invalid Colour Name^0] [^3"..colourName.."^0")
        return "#FFFFFF" -- Default to white if the colour name is invalid
    end
end

return Accessibility