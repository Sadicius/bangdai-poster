lib.locale()
local previewObject = nil
local spawnedObjects = {}
local Info = {}
local canNotify = true
local openNui = false

local ActionPrompt = GetRandomIntInRange(0, 0xffffff)
local Prompt = GetRandomIntInRange(0, 0xffffff)

local Config = require('shared.config')

local objectRotation = {
    pitch = 0.0,
    roll = 0.0,
    yaw = 0.0
}

local MainPrompt = function ()
    local str = locale('open_poster')
    OpenPrompt = PromptRegisterBegin()
    PromptSetControlAction(OpenPrompt, Config.Prompt.openposter)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenPrompt, str)
    PromptSetEnabled(OpenPrompt, true)
    PromptSetVisible(OpenPrompt, true)
    PromptSetStandardMode(OpenPrompt, 1)
    PromptSetGroup(OpenPrompt, Prompt)
    PromptRegisterEnd(OpenPrompt)

    str = locale('delete_poster')
    DeletePrompt = PromptRegisterBegin()
    PromptSetControlAction(DeletePrompt, Config.Prompt.deleteposter)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(DeletePrompt, str)
    PromptSetEnabled(DeletePrompt, true)
    PromptSetVisible(DeletePrompt, true)
    PromptSetStandardMode(DeletePrompt, 1)
    PromptSetGroup(DeletePrompt, Prompt)
    PromptRegisterEnd(DeletePrompt)
end

CreateThread(function()
    if not Config.UseTarget then
        MainPrompt()
    end
end)

local PromptControl = function()
    local str = locale('prompt_updown')
    ControlP = PromptRegisterBegin()
    PromptSetControlAction(ControlP, Config.Prompt.up_down[1])
    PromptSetControlAction(ControlP, Config.Prompt.up_down[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP, str)
    PromptSetEnabled(ControlP, true)
    PromptSetVisible(ControlP, true)
    PromptSetStandardMode(ControlP, 1)
    PromptSetGroup(ControlP, ActionPrompt)
    PromptRegisterEnd(ControlP)

    str = locale('prompt_leftright')
    ControlP2 = PromptRegisterBegin()
    PromptSetControlAction(ControlP2, Config.Prompt.left_right[1])
    PromptSetControlAction(ControlP2, Config.Prompt.left_right[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP2, str)
    PromptSetEnabled(ControlP2, true)
    PromptSetVisible(ControlP2, true)
    PromptSetStandardMode(ControlP2, 1)
    PromptSetGroup(ControlP2, ActionPrompt)
    PromptRegisterEnd(ControlP2)

    str = locale('prompt_forwback')
    ControlP6 = PromptRegisterBegin()
    PromptSetControlAction(ControlP6, Config.Prompt.for_back[1])
    PromptSetControlAction(ControlP6, Config.Prompt.for_back[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP6, str)
    PromptSetEnabled(ControlP6, true)
    PromptSetVisible(ControlP6, true)
    PromptSetStandardMode(ControlP6, 1)
    PromptSetGroup(ControlP6, ActionPrompt)
    PromptRegisterEnd(ControlP6)

    str = locale('prompt_rotateupdown')
    ControlP7 = PromptRegisterBegin()
    PromptSetControlAction(ControlP7, Config.Prompt.rot_updown[1])
    PromptSetControlAction(ControlP7, Config.Prompt.rot_updown[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP7, str)
    PromptSetEnabled(ControlP7, true)
    PromptSetVisible(ControlP7, true)
    PromptSetStandardMode(ControlP7, 1)
    PromptSetGroup(ControlP7, ActionPrompt)
    PromptRegisterEnd(ControlP7)

    str = locale('prompt_rotatelr')
    ControlP3 = PromptRegisterBegin()
    PromptSetControlAction(ControlP3, Config.Prompt.rotatelr[1])
    PromptSetControlAction(ControlP3, Config.Prompt.rotatelr[2])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP3, str)
    PromptSetEnabled(ControlP3, true)
    PromptSetVisible(ControlP3, true)
    PromptSetStandardMode(ControlP3, 1)
    PromptSetGroup(ControlP3, ActionPrompt)
    PromptRegisterEnd(ControlP3)

    str = locale('prompt_place')
    ControlP4 = PromptRegisterBegin()
    PromptSetControlAction(ControlP4, Config.Prompt.place[1])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP4, str)
    PromptSetEnabled(ControlP4, true)
    PromptSetVisible(ControlP4, true)
    PromptSetStandardMode(ControlP4, 1)
    PromptSetGroup(ControlP4, ActionPrompt)
    PromptRegisterEnd(ControlP4)

    str = locale('prompt_cancel')
    ControlP5 = PromptRegisterBegin()
    PromptSetControlAction(ControlP5, Config.Prompt.delete[1])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(ControlP5, str)
    PromptSetEnabled(ControlP5, true)
    PromptSetVisible(ControlP5, true)
    PromptSetStandardMode(ControlP5, 1)
    PromptSetGroup(ControlP5, ActionPrompt)
    PromptRegisterEnd(ControlP5)
end

local function setDesiredHeading(ped, heading, waiter)
    if waiter == nil then waiter = true end
    TaskAchieveHeading(ped, heading % 360, 10000)

    if waiter then
        Wait(1000)
        while not IsPedStill(ped) do
            Wait(100)
        end
    end
end

local function goToCoords(ped, coords, speed, waiter, distanceToStop)
    speed = speed or 1.0
    if waiter or type(coords) == "vec4" then
        local sequence = OpenSequenceTask(math.random(1000))
        TaskGoToCoordAnyMeans(0, coords.xyz, speed, 0, 0, 0, 0.1)
        CloseSequenceTask(sequence)
        ClearPedTasks(ped)
        TaskPerformSequence(ped, sequence)
        ClearSequenceTask(sequence)

        Wait(500)
        repeat
            Wait(0)
        until GetSequenceProgress(ped) == -1 or (distanceToStop and #(GetEntityCoords(ped) - coords.xyz) < distanceToStop)

        if type(coords) == "vec4" then
            setDesiredHeading(ped, coords.w, true)
        end
    else
        TaskGoToCoordAnyMeans(ped, coords.xyz, speed, 0, 0, 0, 0.1)
    end
end

function PreviewObject()
    local model = GetHashKey('mp005_p_mp_bountyPoster01x')
    if not IsModelInCdimage(model) then return end
    
    lib.requestModel(model)

    local coords = GetEntityCoords(cache.ped)
    local heading = GetEntityHeading(cache.ped)
    
    local offsetDist = 1.0
    local forward = GetEntityForwardVector(cache.ped)
    local posX = coords.x + (forward.x * offsetDist)
    local posY = coords.y + (forward.y * offsetDist)
    local posZ = coords.z + 1.0
    
    local object = CreateObject(model, posX, posY, posZ, true, false)
    SetEntityHeading(object, heading)
    SetEntityCollision(object, false, false)
    SetEntityAlpha(object, 150, false)
    SetModelAsNoLongerNeeded(model)
    previewObject = object
    
    objectRotation = {
        pitch = 0.0,
        roll = 0.0,
        yaw = heading
    }
    
    CreateThread(PromptControl)
    CreateThread(ActiveControl)
end

function DeletePreviewObject()
    if previewObject then
        DeleteEntity(previewObject)
        previewObject = nil
        Info = {}
    end
end

local function OpenPosterNui(url)
    if not openNui then
        openNui = true
        SendNUIMessage({
            action = "open",
            url = url
        })
        SetNuiFocus(true, false)
    end
end

function PlaceObject()
    if not previewObject or not DoesEntityExist(previewObject) then return end

    local coords = GetEntityCoords(previewObject)
    local forward = GetEntityForwardVector(previewObject)
    
    local checkPoints = {
        {z = 0},       -- Center
        {z = 0.2},     -- Top
        {z = -0.2},    -- Bottom
    }
    
    local bestHit = nil
    local bestEndCoords = nil
    local bestNormal = nil
    local isBackward = false
    local shortestDist = 999999

    for _, point in ipairs(checkPoints) do
        local rayFwd = StartShapeTestRay(
            coords.x + (forward.x * 0.5),
            coords.y + (forward.y * 0.5),
            coords.z + point.z,
            coords.x - (forward.x * 0.5),
            coords.y - (forward.y * 0.5),
            coords.z + point.z,
            1 + 16 + 32,
            previewObject,
            7
        )
        
        local _, hitFwd, endCoordsFwd, normalFwd = GetShapeTestResult(rayFwd)
        
        if hitFwd == 1 then
            local dist = #(coords - endCoordsFwd)
            if dist < shortestDist then
                shortestDist = dist
                bestHit = hitFwd
                bestEndCoords = endCoordsFwd
                bestNormal = normalFwd
                isBackward = false
            end
        end

        local rayBwd = StartShapeTestRay(
            coords.x - (forward.x * 0.5),
            coords.y - (forward.y * 0.5),
            coords.z + point.z,
            coords.x + (forward.x * 0.5),
            coords.y + (forward.y * 0.5),
            coords.z + point.z,
            1 + 16 + 32,
            previewObject,
            7
        )
        
        local _, hitBwd, endCoordsBwd, normalBwd = GetShapeTestResult(rayBwd)
        
        if hitBwd == 1 then
            local dist = #(coords - endCoordsBwd)
            if dist < shortestDist then
                shortestDist = dist
                bestHit = hitBwd
                bestEndCoords = endCoordsBwd
                bestNormal = normalBwd
                isBackward = true
            end
        end
    end
    
    if bestHit == 1 then
        local offsetDistance = 0.01
        local properPosition = vec3(
            bestEndCoords.x + (bestNormal.x * offsetDistance),
            bestEndCoords.y + (bestNormal.y * offsetDistance),
            bestEndCoords.z + (bestNormal.z * offsetDistance)
        )

        local currentYaw = objectRotation.yaw
        if isBackward then
            currentYaw = currentYaw + 180.0
        end
        currentYaw = currentYaw % 360.0
        
        local properPitch = math.deg(math.asin(bestNormal.z))
        
        local finalRotation = vec3(
            properPitch,
            0.0,
            currentYaw
        )
        
        local loksi = vec4(properPosition.x, properPosition.y, properPosition.z, currentYaw)
        local savedInfo = Info
        savedInfo.rotation = finalRotation
        
        DeletePreviewObject()

        goToCoords(cache.ped, loksi, false, 1.0)
        if lib.progressCircle({
                duration = 5000,
                label = locale('progress_label'),
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = {
                    scenario = 'WORLD_HUMAN_SLEDGEHAMMER',
                },
            }) then
            TriggerServerEvent('bangdai-poster:server:syncobject', {
                coords = loksi,
                data = savedInfo,
                rotation = finalRotation
            })
            ClearPedTasksImmediately(cache.ped)
            savedInfo = nil
        end
    else
        if canNotify then
            Notify(locale('notif_title'), locale('notif_cantplace'), 'error', 5000)
            canNotify = false
            SetTimeout(1000, function()
                canNotify = true
            end)
        end
    end
end

local function clampRotation(value, min, max)
    while value > max do
        value = value - 360.0
    end
    while value < min do
        value = value + 360.0
    end
    return math.max(min, math.min(max, value))
end

local function rotateObject(direction)
    if not previewObject then return end
    
    local rotationSpeed = 5.0
    
    if direction == "left" or direction == "right" then
        if direction == "left" then
            objectRotation.yaw = objectRotation.yaw + rotationSpeed
        else
            objectRotation.yaw = objectRotation.yaw - rotationSpeed
        end

        if objectRotation.yaw > 360.0 then
            objectRotation.yaw = objectRotation.yaw - 360.0
        elseif objectRotation.yaw < 0.0 then
            objectRotation.yaw = objectRotation.yaw + 360.0
        end

        SetEntityRotation(previewObject, objectRotation.pitch, objectRotation.roll, objectRotation.yaw, 2, true)
            
    elseif direction == "up" or direction == "down" then
        local newPitch = objectRotation.pitch
        if direction == "up" then
            newPitch = newPitch + rotationSpeed
        else
            newPitch = newPitch - rotationSpeed
        end
        
        objectRotation.pitch = clampRotation(newPitch, -85.0, 85.0)

        SetEntityRotation(previewObject, objectRotation.pitch,objectRotation.roll,objectRotation.yaw, 2, true)
    end
end

local function movingObject(direction)
    if not previewObject then return end
    local coords = GetEntityCoords(previewObject)
    local moveSpeed = 0.1
    local heading = GetEntityHeading(previewObject)

    local newCoords = coords
    local moveDir = vec3(0, 0, 0)
    
    if direction == "up" then
        moveDir = vec3(0, 0, moveSpeed)
    elseif direction == "down" then
        moveDir = vec3(0, 0, -moveSpeed)
    elseif direction == "left" or direction == "right" then
        local headingRad = math.rad(heading + 90)
        local moveX = math.sin(headingRad)
        local moveY = -math.cos(headingRad)
        local multiplier = direction == "left" and 1 or -1
        moveDir = vec3(moveX * moveSpeed * multiplier, moveY * moveSpeed * multiplier, 0)
    elseif direction == "forward" or direction == "backward" then
        local headingRad = math.rad(heading)
        local moveX = math.sin(headingRad)
        local moveY = -math.cos(headingRad)
        local multiplier = direction == "forward" and -1 or 1
        moveDir = vec3(moveX * moveSpeed * multiplier, moveY * moveSpeed * multiplier, 0)
    end

    newCoords = vec3(
        coords.x + moveDir.x,
        coords.y + moveDir.y,
        coords.z + moveDir.z
    )

    local checkPoints = {
        {x = 0, y = 0, z = 0},     -- Center
        {x = 0.1, y = 0, z = 0.1}, -- Top right
        {x = -0.1, y = 0, z = 0.1}, -- Top left
        {x = 0.1, y = 0, z = -0.1}, -- Bottom right
        {x = -0.1, y = 0, z = -0.1} -- Bottom left
    }

    local canMove = true
    for _, point in ipairs(checkPoints) do
        local rayStart = vec3(
            coords.x + point.x,
            coords.y + point.y,
            coords.z + point.z
        )
        
        local rayEnd = vec3(
            rayStart.x + (moveDir.x * 0.3),
            rayStart.y + (moveDir.y * 0.3),
            rayStart.z + (moveDir.z * 0.3)
        )

        local ray = StartShapeTestRay(
            rayStart.x, rayStart.y, rayStart.z,
            rayEnd.x, rayEnd.y, rayEnd.z,
            1 + 16 + 32,
            previewObject,
            7
        )
        
        local _, hit, hitCoords = GetShapeTestResult(ray)
        if hit == 1 then
            local hitDist = #(rayStart - hitCoords)
            if hitDist < 0.3 then
                canMove = false
                break
            end
        end
    end

    if canMove then
        SetEntityCoords(previewObject, newCoords.x, newCoords.y, newCoords.z, false, false, false, true)
    end
end

function ActiveControl()
    while previewObject do
        Wait(0)
        local label = CreateVarString(10, 'LITERAL_STRING', locale('notif_title'))
        PromptSetActiveGroupThisFrame(ActionPrompt, label)

        if IsControlJustPressed(0, Config.Prompt.place[1]) then
            PlaceObject()
        elseif IsControlJustPressed(0, Config.Prompt.delete[1]) then
            DeletePreviewObject()
        elseif IsControlJustPressed(0, Config.Prompt.rotatelr[1]) then
            rotateObject("left")
        elseif IsControlJustPressed(0, Config.Prompt.rotatelr[2]) then
            rotateObject("right")
        elseif IsControlJustPressed(0, Config.Prompt.up_down[1]) then
            movingObject("up")
        elseif IsControlJustPressed(0, Config.Prompt.up_down[2]) then
            movingObject("down")
        elseif IsControlJustPressed(0, Config.Prompt.left_right[1]) then
            movingObject("left")
        elseif IsControlJustPressed(0, Config.Prompt.left_right[2]) then
            movingObject("right")
        elseif IsControlJustPressed(0, Config.Prompt.for_back[1]) then
            movingObject("backward")
        elseif IsControlJustPressed(0, Config.Prompt.for_back[2]) then
            movingObject("forward")
        elseif IsControlJustPressed(0, Config.Prompt.rot_updown[1]) then
            rotateObject("up")
        elseif IsControlJustPressed(0, Config.Prompt.rot_updown[2]) then
            rotateObject("down")
        end
    end
end

-- command

RegisterCommand(Config.CommandStuck, function()
    if openNui then
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)
        openNui = false
    end
end, false)

--event

RegisterNetEvent('bangdai-poster:client:usePaper', function (item)
    if source == '' then return end
    local input = lib.inputDialog(locale('input_title'), {
        { type = 'input', label = locale('input_label'), required = true },
    })
    if not input then return end
    local flyers = input[1]
    if flyers ~= '' then
        TriggerServerEvent('bangdai-poster:server:SavePoster', flyers, item)
    end
end)

RegisterNetEvent('bangdai-poster:client:createProp', function(data)
    if source == '' then return end
    if not data or type(data) ~= 'table' then return end
    if not data.id or not data.coords or not data.data then return end

    local points = lib.points.new({
        coords = vec3(data.coords.x, data.coords.y, data.coords.z),
        heading = data.coords.w,
        distance = 10.0,
        id = data.id,
        target = {{
            name = 'bangdai_poster_open',
            icon = 'fas fa-clipboard-user',
            label = locale('open_poster'),
            onSelect = function ()
                return OpenPosterNui(data.data.url)
            end,
            canInteract = function(_, distance)
                return distance < 2.0
            end
        },{
            name = 'bangdai_poster_delete',
            icon = 'fas fa-trash-can',
            label = locale('delete_poster'),
            onSelect = function ()
                return TriggerServerEvent('bangdai-poster:server:removeProp', data)
            end,
            canInteract = function(_, distance)
                return distance < 2.0
            end
        }}
    })

    points.onEnter = function(self)
        if not self.object then
            local model = joaat('mp005_p_mp_bountyPoster01x')
            lib.requestModel(model, 120000)
            self.object = CreateObject(model, self.coords.x, self.coords.y, self.coords.z, false, false, false)

            if data.rotation then
                SetEntityRotation(self.object, data.rotation.x, data.rotation.y, data.rotation.z, 2, true)
            else
                SetEntityHeading(self.object, self.heading)
            end

            FreezeEntityPosition(self.object, true)

            SetModelAsNoLongerNeeded(model)
            
            if Config.UseTarget then
                exports.ox_target:addLocalEntity(self.object, self.target)
            end
        end
    end

    points.onExit = function(self)
        if self.object and DoesEntityExist(self.object) then
            Citizen.InvokeNative(0x7DFB49BCDB73089A, self.object, false)
            DeleteEntity(self.object)
            self.object = nil

            if Config.UseTarget then
                exports.ox_target:removeLocalEntity(self.ped, self.advanced and 'bangdai_poster_open' or 'bangdai_poster_delete')
            end
        end
    end

    points.nearby = function (self)
        if self.currentDistance < 5.0 then
            Citizen.InvokeNative(0x7DFB49BCDB73089A, self.object, true)
            if not Config.UseTarget and self.currentDistance < 2.0 then
                local label = CreateVarString(10, 'LITERAL_STRING', locale('notif_title'))
                PromptSetActiveGroupThisFrame(Prompt, label)
                if IsControlJustPressed(0, Config.Prompt.openposter) then
                    OpenPosterNui(data.data.url)
                    return
                end
                if IsControlJustPressed(0, Config.Prompt.deleteposter) then
                    TriggerServerEvent('bangdai-poster:server:removeProp', data)
                    return
                end
            end
        end
    end

    spawnedObjects[data.id] = points
end)

RegisterNetEvent('bangdai-poster:client:spawnobject', function(data)
    if source == '' then return end
    PreviewObject()
    Info = { item = data.item, url = data.url}
end)

RegisterNetEvent('bangdai-poster:client:removeProp', function(data)
    if source == '' then return end
    if not data or not data.id then return end
    
    local points = spawnedObjects[data.id]
    if points then
        if points.object and DoesEntityExist(points.object) then
            DeleteEntity(points.object)
            if Config.UseTarget then
                exports.ox_target:removeLocalEntity(points.object, points.advanced and 'bangdai_poster_open' or 'bangdai_poster_delete')
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompt)
            end

            points.object = nil
        end
        points:remove()
        spawnedObjects[data.id] = nil
    end
end)

--nuicallback

RegisterNUICallback('CloseDocument', function(_, cb)
    if openNui then
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)
        openNui = false
    end
    cb('ok')
end)

--cleanup

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if openNui then
        SendNUIMessage({
            action = "close"
        })
        SetNuiFocus(false, false)
        openNui = false
    end
    
    for id, points in pairs(spawnedObjects) do
        if points.object and DoesEntityExist(points.object) then
            DeleteEntity(points.object)
            if Config.UseTarget then
                exports.ox_target:removeLocalEntity(points.object, points.advanced and 'bangdai_poster_open' or 'bangdai_poster_delete')
            else
                Citizen.InvokeNative(0x00EDE88D4D13CF59, Prompt)
            end

            points.object = nil
        end
        points:remove()
        spawnedObjects[id] = nil
    end
    
    if previewObject and DoesEntityExist(previewObject) then
        DeleteEntity(previewObject)
    end

    Citizen.InvokeNative(0x00EDE88D4D13CF59, ActionPrompt)
end)