---@diagnostic disable: duplicate-set-field
Shops = Shops or {}

local registeredShops = {}

---This can open a shop for the client
---@param src number
---@param shopName string
---@return boolean
Shops.OpenShop = function(src, shopName)
    if not shopName and not registeredShops[shopName] then return false, print("community_bridge PLAYERID "..src.." attempted to open invalid shop: "..shopName) end
    TriggerClientEvent('community_bridge:Client:openShop', src, 'shop', shopName, registeredShops[shopName])
    return true
end

---This will create a shop to use on the client side, shops must be registered server side and exsist in the shop inventory table to allow any purchases passed.
---@param shopName string
---@param shopInventory table
---@param shopCoords table
---@param shopGroups table
---@return boolean
Shops.CreateShop = function(shopName, shopInventory, shopCoords, shopGroups)
    if not shopName and not shopInventory and not shopCoords then return false end
    if registeredShops[shopName] then return true end
    registeredShops[shopName] = {name = shopName, inventory = shopInventory, shopCoords = shopCoords, groups = shopGroups}
    return true
end

---This is an internal event to complete a shop transaction, it will verify pass items and amounts are registered to the created shop. Please do not use this function directly.
---@param src number
---@param shopName string
---@param item string
---@param amount number
---@param account string
---@return nil
Shops.CompleteCheckout = function(src, shopName, item, amount, account)
    if not src or not shopName or not item or not amount or not account then return end
    if not amount or amount <= 0 then return end

    local shopData = registeredShops[shopName]
    if not shopData then return end

    local itemData = nil
    for _, data in pairs(shopData.inventory) do
        if data.name == item then
            itemData = data
            break
        end
    end
    if not itemData or not itemData.price then return print("community_bridge Player ID "..src.." attempted to purchase invalid item from shop: "..shopName) end
    if itemData.count and itemData.count <= 0 then return Notify.SendNotify(src, lib.locale('Shops.NotEnoughStock'), "error", 5000) end
    local totalCost = tonumber(itemData.price) * amount
    local balance = Framework.GetAccountBalance(src, account)
    if not balance then return end
    if balance <= 0 then return Notify.SendNotify(src, lib.locale('Shops.NotEnoughMoney'), "error", 5000) end
    if balance < totalCost then return Notify.SendNotify(src, lib.locale('Shops.NotEnoughMoney'), "error", 5000) end

    if not Framework.RemoveAccountBalance(src, account, totalCost) then return end

    local success = Inventory.AddItem(src, itemData.name, amount)
    if not success then
        Framework.AddAccountBalance(src, account, totalCost)
        return Notify.SendNotify(src, lib.locale('Shops.PurchaseFailed'), "error", 5000)
    end

    local itemLabel = Inventory.GetItemInfo(itemData.name).label or itemData.name
    Notify.SendNotify(src, lib.locale('Shops.PurchasedItem', amount, itemLabel), "success", 5000)
end

---This is an internal event to complete a checkout, complete with multiple validations. Please do not use this event directly.
---@param shopName string
---@param item string
---@param amount number
---@param account string
RegisterNetEvent("community_bridge:Server:completeCheckout", function(shopName, item, amount, account)
    local src = source
    if not shopName or not item or not account or not amount then return end
    if account ~= "money" and account ~= "bank" then return end
    amount = tonumber(amount)
    if not amount or amount <= 0 then return end
    Shops.CompleteCheckout(src, shopName, item, amount, account)
end)

return Shops