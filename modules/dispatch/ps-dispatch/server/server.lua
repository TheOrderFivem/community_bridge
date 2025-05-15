if GetResourceState('ps-dispatch') ~= 'started' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

return Dispatch