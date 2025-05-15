if GetResourceState('qb-banking') ~= 'started' then return end
Managment = Managment or {}

---This will return a table with account details
---@param account string
---@return table
Managment.GetAccountMoney = function(account)
    return exports['qb-banking']:GetAccountBalance(account)
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@return boolean
Managment.AddAccountMoney = function(account, amount)
    return exports['qb-banking']:AddMoney(account, amount)
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@return boolean
Managment.RemoveAccountMoney = function(account, amount)
    return exports['qb-banking']:RemoveMoney(account, amount)
end

return Managment