local Core = exports.vorp_core:GetCore()

function GetPlayer(src)
    local Player = Core.getUser(src)
    return Player or false
end

function RemoveItem(source, item)
    local Player = GetPlayer(source)
    if not Player then return false end
    local removed = exports.vorp_inventory:subItem(source, item, 1)
    return removed and true or false
end

function CreateItem(itemName)
    exports.vorp_inventory:registerUsableItem(itemName, function(data)
        local source = data.source
        if not source then return false end
        
        exports.vorp_inventory:closeInventory(source)
        TriggerClientEvent("bangdai-poster:client:usePaper", source, itemName)
        return true
    end)
    return true
end

--eventhandler

AddEventHandler("vorp:SelectedCharacter", function(source, character)
    local src = source
    SetTimeout(2000, function()
        LoadPoster(src)
    end)
end)
