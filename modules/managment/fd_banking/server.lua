if GetResourceState('fd_banking') ~= 'started' then return end
Managment = Managment or {}

---@param identifier<string> - Identifier (citizen id)
Managment.GetAccountMoney = function(citizenId)
    return exports.fd_banking:getPersonalAccount(identifier).balance
end

---This will add money to the specified account of the passed amount
---@param society<string> - society identifier
---@param amount<number> - amount
---@param reason<string> - reason
Managment.AddAccountMoney = function(account, amount)
    return exports.fd_banking:AddMoney(society, amount, reason)
end

---This will remove money from the specified account of the passed amount
---@param society<string> - society identifier
---@param amount<number> - amount
---@param reason<string> - reason
Managment.RemoveAccountMoney = function(account, amount)
    return exports.fd_banking:RemoveMoney(society, amount, reason)
end

return Managment
