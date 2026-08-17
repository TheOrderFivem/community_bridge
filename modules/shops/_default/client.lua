---@diagnostic disable: duplicate-set-field
Shops = Shops or {}

---This is an internal event used to be hit from server for the shop context menus. Please do not use this event directly.
---@param shopType string
---@param shopLabel string
---@param shopData table
RegisterNetEvent('community_bridge:Client:openShop', function(shopType, shopLabel, shopData)
    if source ~= 65535 then return end
    if not shopType or not shopLabel or not shopData then return end
    if shopType ~= 'shop' then return end
    Shops.OpenShop(shopLabel, shopData.inventory)
end)

---This is an internal function that is used to complete a transaction and offer cash/card pay. Please do not use this function directly.
---@param shopName string
---@param item string
---@param itemLabel string
---@param price number
---@param amount number
Shops.FinalizeCheckOut = function(shopName, item, itemLabel, price, amount)
    if not shopName and not item and not itemLabel and not price then return end
    local mathStuff = (tonumber(price) * tonumber(amount))
    local generatedID = lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
    local buildMenu = {
        {
            title = locale('Shops.PayByCash', tostring(mathStuff)),
            description = locale('Shops.AreYouSure', itemLabel),
            icon = locale('Shops.CashIcon'),
            onSelect = function(_, __, ___)
                TriggerServerEvent('community_bridge:Server:completeCheckout', shopName, item, amount, "money")
            end
        },
        {
            title = locale('Shops.PayByCard', tostring(mathStuff)),
            description = locale('Shops.AreYouSure', itemLabel),
            icon = locale('Shops.CardIcon'),
            onSelect = function(_, __, ___)
                TriggerServerEvent('community_bridge:Server:completeCheckout', shopName, item, amount, "bank")
            end
        }
    }
    Menu.Open({ id = generatedID, title = locale("Shops.Input"), options = buildMenu }, false)
end

---This is an internal functions that is used to open the amount select menu. Please do not use this function directly.
---@param shopName string
---@param item string
---@param itemLabel string
---@param price number
Shops.AmountSelect = function(shopName, item, itemLabel, price)
    if not shopName and not item and not itemLabel and not price then return end
    if not tonumber(price) then return end
    if price <= 0 then return end
    local numberOptions = {}
    for i = 1, 100 do
        table.insert(numberOptions, {label = tostring(i), value = i})
    end
    local _input = Input.Open(shopName, {
        {type = 'select', label = locale("Shops.PurchaseAmount"), options = numberOptions},
    })

    if _input and _input[1] then
        Shops.FinalizeCheckOut(shopName, item, itemLabel, price, tostring(_input[1]))
    end
end

---This will open a shop with the passed shopName and data. It will create a menu with the items in the shopData table. The items will be clickable and will open a checkout menu.
---This also verifies the shop exsists and was made first server side. This will not work when only used client side and the server side verifies the item exsists in the table as well as the shop id.
---@param shopName string
---@param shopData table
---@return nil
Shops.OpenShop = function(shopName, shopData)
    if not shopName and not shopData then return print("^6 No Shop Name or Shop Data Passed ^0") end
    local generatedID = lib.string.random('Aa1A', 8) -- Generate a random ID if not provided
    local buildMenu = {}
    for _, v in pairs(shopData) do
        local getItemName = Inventory.GetItemInfo(v.name).label
        table.insert(buildMenu, {
            title = getItemName,
            description = locale('Shops.CurrencySymbol', tostring(v.price)),
            icon = locale('Shops.ShopIcon'),
            onSelect = function(selected, secondary, args)
                Shops.AmountSelect(shopName, v.name, getItemName, v.price)
            end
        })
    end
    Menu.Open({ id = generatedID,  title = shopName, options = buildMenu }, false)
end

return Shops