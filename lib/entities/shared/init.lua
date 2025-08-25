local fileList = {
    client = {
        'scenarios',
        "anim",
        "particles",
        "targets",
        "follow",
        'clothing',
        'weapon',
    },
    server = {
       
    },
    shared = {
         "stash"
    }
}

local path = "lib/entities/shared/behaviors/"

local function loadAllResources()
    local modules = {}
    local duplicity = IsDuplicityVersion() and "server" or "client"
    local fl = fileList[duplicity] or {}
    for _, fileName in pairs(fileList.shared) do
        table.insert(fl, fileName)
    end
 
    for _, fileName in pairs(fl) do
        local filePath = path .. fileName .. ".lua"
        local required = Require(filePath)        
        if required then
            table.insert(modules, required)
        end
    end
    return modules
end
return loadAllResources()