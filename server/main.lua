local ActivePoster = {}

local function InitDatabase()
    local success, error = pcall(function()
        exports.oxmysql:execute([[
            CREATE TABLE IF NOT EXISTS bangdai_posters (
                id VARCHAR(50) PRIMARY KEY,
                location JSON NOT NULL,
                rotation JSON NOT NULL,
                url TEXT NOT NULL,
                item VARCHAR(100) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ]], {}, function(success)
            if success then
                lib.print.info('^2Database table checked/created successfully^0')
            end
        end)
    end)

    if not success then
        lib.print.error('^1Failed to initialize database:^0', error)
        return false
    end
    return true
end

local function LoadAllPostersFromDatabase()
    if not next(ActivePoster) then ActivePoster = {} end

    local scs, result = pcall(function()
        return exports.oxmysql:executeSync('SELECT * FROM bangdai_posters')
    end)

    if not scs then
        lib.print.info('^1Failed to load posters from database^0')
        return false
    end

    if not result or #result == 0 then
        lib.print.info('^3No posters found in database^0')
        return true
    end

    lib.print.info('^2Loading ^3' .. #result .. '^2 posters from database^0')

    for _, posterData in ipairs(result) do
        local success, coords = pcall(json.decode, posterData.location)
        local success2, rotation = pcall(json.decode, posterData.rotation)

        if success and success2 then
            local data = {
                id = posterData.id,
                coords = vec4(coords.x, coords.y, coords.z, coords.w),
                data = {
                    url = posterData.url,
                    item = posterData.item,
                },
                rotation = vec3(rotation.x, rotation.y, rotation.z)
            }
            ActivePoster[data.id] = data
            TriggerClientEvent('bangdai-poster:client:createProp', -1, data)
        else
            lib.print.info('^1Failed to decode poster data for ID:^3', posterData.id, '^0')
        end
    end

    return true
end

local function SavePosterToDatabase(data)
    local location = {
        x = data.coords.x,
        y = data.coords.y,
        z = data.coords.z,
        w = data.coords.w
    }
    
    local rotation = {
        x = data.rotation.x,
        y = data.rotation.y,
        z = data.rotation.z
    }

    local success = exports.oxmysql:insert_async('INSERT INTO bangdai_posters (id, location, rotation, url, item) VALUES (?, ?, ?, ?, ?)', {
        data.id,
        json.encode(location),
        json.encode(rotation),
        data.data.url,
        data.data.item,
    })
    return success
end

local function RemovePosterFromDatabase(id)
    return exports.oxmysql:execute_async('DELETE FROM bangdai_posters WHERE id = ?', {id})
end

local function searchActivePosterById(id)
    if not next(ActivePoster) then return false end
    local Poster = ActivePoster[id]
    return Poster ~= nil and Poster or false
end

RegisterNetEvent('bangdai-poster:server:SavePoster', function(url, item)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end
    local data = {}
    data.url = url
    data.item = item
    if url ~= (nil or '') then
        TriggerClientEvent('bangdai-poster:client:spawnobject', src, data)
        data = {}
    end
end)

RegisterNetEvent('bangdai-poster:server:syncobject', function(data)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    data.id = lib.string.random('.......')

    local formattedData = {
        id = data.id,
        coords = data.coords,
        data = {
            url = data.data.url,
            item = data.data.item
        },
        rotation = data.rotation
    }

    ActivePoster[data.id] = formattedData

    local success = SavePosterToDatabase(formattedData)
    if success then
        RemoveItem(src, data.data.item)
        TriggerClientEvent('bangdai-poster:client:createProp', -1, formattedData)
    else
        lib.print.warn("^1Failed to save poster to database^0")
    end
end)

RegisterNetEvent('bangdai-poster:server:removeProp', function(data)
    local src = source
    local Player = GetPlayer(src)
    if not Player then return end

    local posterData = searchActivePosterById(data.id)
    if not posterData then return end

    local success = RemovePosterFromDatabase(data.id)
    if success then
        TriggerClientEvent('bangdai-poster:client:removeProp', -1, posterData)
        ActivePoster[data.id] = nil
    else
        lib.print.warn("^1Failed to remove poster from database^0")
    end
end)

local Config = require('shared.config')

CreateThread(function ()
    CreateItem(Config.Item)
end)

function LoadPoster(src)
    for _, posterData in pairs(ActivePoster) do
        TriggerClientEvent('bangdai-poster:client:createProp', src, posterData)
    end
end

local function CheckResourceName()
    local currentName = GetCurrentResourceName()
    local expectedName = 'bangdai-poster'

    if currentName ~= expectedName then
        print('^1===========================================^0')
        print('^1[ERROR] Resource name must be: ^3' .. expectedName .. '^0')
        print('^1Current resource name: ^3' .. currentName .. '^0')
        print('^1Please rename your resource folder to: ^3' .. expectedName .. '^0')
        print('^1===========================================^0')

        Wait(100)
        StopResource(currentName)
        return false
    end
    return true
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    if not CheckResourceName() then return end

    lib.print.info("^2Resource started successfully!^0")

    if InitDatabase() then
        Wait(1000)
        LoadAllPostersFromDatabase()
    else
        lib.print.error('^1Failed to initialize database, stopping resource^0')
        StopResource(resourceName)
    end
end)