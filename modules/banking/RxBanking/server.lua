---@diagnostic disable: duplicate-set-field
if GetResourceState('RxBanking') == 'missing' then return end

Banking = Banking or {}

---This will get the name of the Managment system being being used.
---@return string
Banking.GetManagmentName = function()
    return 'RxBanking'
end

---This will get the name of the in use resource.
---@return string
Banking.GetResourceName = function()
    return 'RxBanking'
end

---This will return a number
---@param account string
---@return number
Banking.GetAccountMoney = function(account)
    local societyAccount = exports['RxBanking']:GetSocietyAccount(account)
    if societyAccount then
        -- We try to catch the common keys for money/balance
        return societyAccount.balance or societyAccount.money or societyAccount.amount or 0
    end
    return 0
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Banking.AddAccountMoney = function(account, amount, reason)
    -- exports['RxBanking']:AddSocietyMoney(society, amount, type, reason, fromIban)
    local success = pcall(function()
        exports['RxBanking']:AddSocietyMoney(account, amount, 'deposit', reason or 'Unknown Reason')
    end)
    return success
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Banking.RemoveAccountMoney = function(account, amount, reason)
     -- exports['RxBanking']:RemoveSocietyMoney(society, amount, type, reason, toIban)
     local success = pcall(function()
        exports['RxBanking']:RemoveSocietyMoney(account, amount, 'withdraw', reason or 'Unknown Reason')
    end)
    return success
end

return Banking
