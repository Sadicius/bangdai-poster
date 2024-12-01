local Core = exports['rsg-core']:GetCoreObject()

function GetPlayer(src)
    local Player = Core.Functions.GetPlayer(src)
    return Player
end

function RemoveItem(source, item)
    local Player = GetPlayer(source)
    if not Player then return false end
    local removed = Player.Functions.RemoveItem(item, 1)
    if removed then
        TriggerClientEvent('rsg-inventory:client:ItemBox', source, Core.Shared.Items[item], 'remove', 1)
        return true
    end
    return false
end

function CreateItem(itemName)
    if not Core.Shared.Items[itemName] then 
        print('^1Error: Item ' .. itemName .. ' not found in Core.Shared.Items^0')
        return false
    end

    Core.Functions.CreateUseableItem(itemName, function(source, item)
        if not source then return false end
        
        TriggerClientEvent("bangdai-poster:client:usePaper", source, item.name)
        return true
    end)
    return true
end

--eventhandler

RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(2000, function()
        LoadPoster(src)
    end)
end)