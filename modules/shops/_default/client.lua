Shops = Shops or {}

RegisterNetEvent('community_bridge:openShop', function(_type, _title, shopData)
    if source ~= 65535 then return end
    if not _title and not _title and not shopData then return end
    if _type ~= 'shop' then return end
    Shops.OpenShop(_title, shopData.inventory)
end)

---This is an internal event that is used to complete a transaction and offer cash/card pay
Shops.FinalizeCheckOut = function(shopName, item, itemLabel, price, amount)
    if not shopName and not item and not itemLabel and not price then return end
    local mathStuff = tonumber(price) * tonumber(amount)
    local generatedID = Ids.CreateUniqueId()
    local buildMenu = {
        {
            title = locale('Shops.PayByCash').." "..tostring(mathStuff),
            description = locale('Shops.AreYouSure') .. itemLabel,
            icon = "fa-solid fa-money-bill-wave",
            onSelect = function(_, __, ___)
                TriggerServerEvent('community_bridge:completeCheckout', shopName, item, amount, "money")
            end
        },
        {
            title = locale('Shops.PayByCard').." "..tostring(mathStuff),
            description = locale('Shops.AreYouSure') .. itemLabel,
            icon = "fa-solid fa-building-columns",
            onSelect = function(_, __, ___)
                TriggerServerEvent('community_bridge:completeCheckout', shopName, item, amount, "bank")
            end
        }
    }
    Menu.Open({ id = generatedID, title = locale("Shops.Input"), options = buildMenu }, false)
end

---This is an internal event that is used to open the amount select menu
---@param shopName string
---@param item string
---@param itemLabel string
---@param price number
Shops.AmountSelect = function(shopName, item, itemLabel, price)
    if not shopName and not item and not itemLabel and not price then return end
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

---This will open a shop with the passed title and data. It will create a menu with the items in the shopData table. The items will be clickable and will open a checkout menu.
---This also verifies the shop exsists and was made first server side. This will not work when only used client side and the server side verifies the item exsists in the table as well as the shop id.
---@param title any
---@param shopData any
---@return nil
Shops.OpenShop = function(title, shopData)
    if not title and not shopData and not title then return Prints.Error("No Title Passed") end
    local generatedID = Ids.CreateUniqueId()
    local buildMenu = {}
    for _, v in pairs(shopData) do
        local getItemName = Inventory.GetItemInfo(v.name).label
        table.insert(buildMenu, {
            title = getItemName,
            description = locale('Shops.CurrencySymbol')..tostring(v.price),
            icon = "fa-solid fa-basket-shopping",
            onSelect = function(selected, secondary, args)
                Shops.AmountSelect(title, v.name, getItemName, v.price)
                --Shops.FinalizeCheckOut(title, v.name, getItemName, v.price)
            end
        })
    end
    Menu.Open({ id = generatedID,  title = title, options = buildMenu }, false)
end

return Shops