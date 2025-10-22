Logs = Logs or {}
local BridgeServerConfig = BridgeServerConfig or Require('settings/serverConfig.lua')

local pendingLogs = {}
local sendTimer = nil

local function sendBufferedLogsToDiscord()
    if #pendingLogs == 0 then
        sendTimer = nil
        return
    end

    local embeds = {}
    for _, log in ipairs(pendingLogs) do
        table.insert(embeds, {
            color = '15769093',
            title = log.resource,
            thumbnail = { url = BridgeServerConfig.EmbedLogo },
            fields = {
                {
                    name = 'Log Message',
                    value = '```' .. log.message .. '```',
                    inline = false,
                }
            },
            timestamp = log.timestamp,
        })
    end

    PerformHttpRequest(BridgeServerConfig.WebhookURL, function(err, text, headers) end, 'POST', json.encode({
        username = 'Community_Bridge Logger',
        avatar_url = 'https://avatars.githubusercontent.com/u/192999457?s=400&u=da632e8f64c85def390cfd1a73c3b664d6882b38&v=4',
        embeds = embeds
    }), { ['Content-Type'] = 'application/json' })

    pendingLogs = {}
    sendTimer = nil
end

local function queueLogForDiscord(message)
    table.insert(pendingLogs, {
        message = tostring(message),
        resource = GetInvokingResource() or GetCurrentResourceName(),
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S')
    })

    if not sendTimer then
        sendTimer = true
        SetTimeout(3000, sendBufferedLogsToDiscord)
    end
end

local logHandlers = {
    fivemerr = function(message)
        local fivemerrData = {
            level = 'info',
            message = tostring(message),
            resource = GetInvokingResource() or GetCurrentResourceName(),

        }
        PerformHttpRequest('https://api.fivemerr.com/v1/logs', function(code, text, headers)
            if code ~= 200 then
                print(('Failed to send log to Fivemerr API (HTTP %d): Please verify your API key is correct and the service is available.'):format(code))
            end
        end, 'POST', json.encode(fivemerrData), {
            ['Content-Type'] = 'application/json',
            ['Authorization'] = BridgeServerConfig.FivemerrApiKey
        })
    end,

    fivemanage = function(message)
        if GetResourceState("fmsdk") == "missing" then return print('^1Error:^0 fivemanage log system selected but fmsdk resource is missing.') end
        exports.fmsdk:LogMessage('info', message)
    end,

    qb = function(message)
        TriggerEvent('qb-log:server:CreateLog', GetCurrentResourceName(), GetInvokingResource(), 'green', message, false)
    end,

    ox_lib = function(message)
        lib.logger(GetInvokingResource(), GetCurrentResourceName(), message)
    end,

    ['built-in'] = function(message)
        queueLogForDiscord(message)
    end
}

---@deprecated Use Logs.CreateLog instead (deprecated 9/1/25)
Logs.Send = function(src, message)
    print('^1Deprecated^0 function Logs.Send called. Please use Logs.CreateLog instead.')
    Logs.CreateLog(message)
end

---@deprecated Use Logs.CreateLog instead (deprecated 9/1/25)
Logs.Notify = function(src, url, image, message)
    print('^1Deprecated^0 function Logs.Notify called. Please use Logs.CreateLog instead.')
    Logs.CreateLog(message)
end

Logs.CreateLog = function(message)
    local handler = logHandlers[BridgeServerConfig.LogSystem]
    if not handler then return end
    handler(message)
end

exports('Logs', Logs)
return Logs
