Version = Version or {}

---Pass a github username and repo name to check for the latest version of the resource.
---
---Tebex is a optional boolean to determine if the message should be for a escrowed resource or not.
---
---Example Version.VersionChecker("The-Order-Of-The-Sacred-Framework/community_bridge", false)
---@param repoPath string
---@param tebex boolean | nil
---@return nil
function Version.VersionChecker(repoPath, tebex)
    local username, reponame = repoPath:match("([^/]+)/([^/]+)")
    local resource = reponame and repoPath:match("([^/]+)$")
    if not username or not reponame or not resource then
        return Prints.Error('^1Invalid repository format. Expected format: "username/reponame"^0')
    end

    local version = GetResourceMetadata(resource, "version", 0):match('%d+%.%d+%.%d+')
    if not version then return end

    PerformHttpRequest(('https://api.github.com/repos/%s/%s/releases/latest'):format(username, reponame), function(status, response)
        if status ~= 200 then return end
        local latest = json.decode(response).tag_name:match('%d+%.%d+%.%d+')
        if not latest or latest == version or version:gsub('%D', '') >= latest:gsub('%D', '') then return end

        local url = tebex and "https://portal.cfx.re/assets/granted-assets" or json.decode(response).html_url
        print(('^1An update is available for %s (current version: %s)\r\n - ^5Please download the latest version from %s^7'):format(resource, version, url))
    end, 'GET')
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Version.VersionChecker("The-Order-Of-The-Sacred-Framework/community_bridge")
end)

return Version