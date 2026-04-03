---@diagnostic disable: duplicate-set-field
if GetResourceState('DHS-BankingSim') == 'missing' then return end
Banking = Banking or {}

local dhsBanking = exports['DHS-BankingSim']

--- Helper: resolve business account ID from a job/society name
---@param account string Job or society name (e.g. 'police', 'ambulance')
---@return number|nil businessId
local function ResolveBusinessId(account)
    local row = MySQL.single.await(
        'SELECT id FROM business_accounts WHERE job_name = ? AND status = ? LIMIT 1',
        { account, 'active' }
    )
    return row and row.id or nil
end

---This will get the name of the Managment system being being used.
---@return string
Banking.GetManagmentName = function()
    return 'DHS-BankingSim'
end

---This will get the name of the in use resource.
---@return string
Banking.GetResourceName = function()
    return 'DHS-BankingSim'
end

---This will return a number
---@param account string
---@return number
Banking.GetAccountMoney = function(account)
    local businessId = ResolveBusinessId(account)
    if not businessId then return 0 end
    local balance = dhsBanking:GetBusinessBalance(businessId)
    return balance or 0
end

---This will add money to the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Banking.AddAccountMoney = function(account, amount, reason)
    local businessId = ResolveBusinessId(account)
    if not businessId then return false end
    reason = reason or 'Community Bridge deposit'
    MySQL.update.await('UPDATE business_accounts SET balance = balance + ? WHERE id = ?', { amount, businessId })
    return true
end

---This will remove money from the specified account of the passed amount
---@param account string
---@param amount number
---@param reason string
---@return boolean
Banking.RemoveAccountMoney = function(account, amount, reason)
    local businessId = ResolveBusinessId(account)
    if not businessId then return false end
    reason = reason or 'Community Bridge withdrawal'
    local row = MySQL.single.await('SELECT balance FROM business_accounts WHERE id = ?', { businessId })
    if not row or (tonumber(row.balance) or 0) < amount then return false end
    MySQL.update.await('UPDATE business_accounts SET balance = balance - ? WHERE id = ?', { amount, businessId })
    return true
end

return Banking
