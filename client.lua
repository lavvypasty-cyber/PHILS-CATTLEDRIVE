

local RSG = exports['rsg-core']:GetCoreObject()

-- =============================================================
-- STATE
-- =============================================================
local activeDrive = false
local menuOpen = false
local cows = {}
local npcs = {}
local createdBlips = {}
local destBlip = nil
local currentStartIndex = nil
local currentDest = nil
local currentReward = 0
local KEY = nil

local spawnDebug = true -- set false once everything works
local npcCount = 0
local blipCount = 0

-- =============================================================
-- UI HELPER
-- =============================================================
local function SendUI(action, data)
    SendNUIMessage({ action = action, data = data or {} })
end

-- =============================================================
-- NATIVE HASHES
-- =============================================================
local N = {
    SET_MISSION_ENTITY   = 0x283978A15512B2FE,
    TASK_WANDER_STANDARD = 0x51455AB0A5A32300,
    TASK_ANIMAL_FLEE     = 0x6C3D9045FF8D3139,
    TASK_START_SCENARIO  = 0x9175A069CA423392,
    TASK_FOLLOW_OFFSET   = 0x304AE42E357B8C7E,
    REMOVE_BLIP          = 0xA7CB0A9D3A1C447B,
    SET_BLIP_NAME        = 0x9CB1A1623062F402,
    START_GPS_MULTI      = 0x3D3D15AF7BCAAF83,
    ADD_GPS_POINT        = 0xA905192A6781C41B,
    SET_GPS_RENDER       = 0x3DDA37128DD1ACA8,
    CLEAR_GPS_MULTI      = 0x67EEDEA1B9BAFD94,
}

-- colour string -> blip modifier hash mapping
local BLIP_MODIFIERS = {
    COLOR_YELLOW = 'BLIP_MODIFIER_MP_COLOR_8',
    COLOR_GREEN  = 'BLIP_MODIFIER_COLOR_GREEN',
    COLOR_RED    = 'BLIP_MODIFIER_COLOR_RED',
    COLOR_WHITE  = 'BLIP_MODIFIER_COLOR_WHITE',
    COLOR_BLUE   = 'BLIP_MODIFIER_MP_COLOR_9',
}



-- =============================================================
-- KEYBIND (lazy load)
-- =============================================================
CreateThread(function()
    while not RSG do Wait(100) end
    local ok, key = pcall(function()
        return RSG.Shared and RSG.Shared.Keybinds and RSG.Shared.Keybinds[Config.InteractKey]
    end)
    KEY = ok and key or 0xCEFD9220
    --print('^2[phils-cattledrive] Keybind [' .. Config.InteractKey .. '] = ' .. tostring(KEY) .. '^0')
end)

-- =============================================================
-- HELPERS
-- =============================================================
local function RemoveBlipSafe(blip)
    if blip and blip ~= 0 then
        Citizen.InvokeNative(N.REMOVE_BLIP, blip)
    end
end

-- =============================================================
-- MODEL LOADING
-- =============================================================
local function LoadModel(modelName)
    local hash = type(modelName) == 'number' and modelName or joaat(modelName)
    local timeout = 10000

    if not IsModelValid(hash) then
        --print('^1[phils-cattledrive] INVALID MODEL: ' .. tostring(modelName) .. '^0')
        return nil
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) and timeout > 0 do
        Wait(50)
        timeout = timeout - 50
    end

    if not HasModelLoaded(hash) then
        --print('^1[phils-cattledrive] MODEL TIMED OUT: ' .. tostring(modelName) .. '^0')
        return nil
    end
    return hash
end

-- =============================================================
-- NPC SPAWNING (mission entity flag = stays visible)
-- =============================================================
local function SpawnNPC(modelName, coords, heading, scenario)
    local model = LoadModel(modelName)
    if not model then return nil end

    local x, y, z = coords.x, coords.y, coords.z
    local found, groundZ = GetGroundZAndNormalFor_3dCoord(x, y, z + 50.0)
    if found and groundZ and groundZ > 0.0 then
        z = groundZ
    end

    local ped = CreatePed(model, x, y, z, heading, false, true)
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        
        SetModelAsNoLongerNeeded(model)
        return nil
    end

    Wait(100)

    Citizen.InvokeNative(N.SET_MISSION_ENTITY, ped, true)

    SetEntityCoords(ped, x, y, z, true, true, true, false)
    SetEntityHeading(ped, heading)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, true, false)

    if scenario then
        Citizen.InvokeNative(N.TASK_START_SCENARIO, ped, joaat(scenario), -1, true, false, false, false)
    end

    npcCount = npcCount + 1
    
    SetModelAsNoLongerNeeded(model)
    return ped
end


local function CreateBlip(coords, blipConfig)
    
    local blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, coords)

    if not blip then
        
        return nil
    end

    
    SetBlipSprite(blip, blipConfig.sprite)

    
    local modifier = BLIP_MODIFIERS[blipConfig.colour] or 'BLIP_MODIFIER_MP_COLOR_8'
    BlipAddModifier(blip, joaat(modifier))

    
    pcall(function()
        Citizen.InvokeNative(0x2CCA5165E01C68F9, blip, blipConfig.scale or 0.9)
    end)

   
    Citizen.InvokeNative(N.SET_BLIP_NAME, blip, blipConfig.name or 'Cattle Drive')

    table.insert(createdBlips, blip)
    blipCount = blipCount + 1
    
    return blip
end

local function CreateBlips()
    for _, loc in ipairs(Config.StartLocations) do
        CreateBlip(loc.coords, loc.blip)
    end
    for _, loc in ipairs(Config.DeliveryPoints) do
        CreateBlip(loc.coords, loc.blip)
    end
end


CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end
    Wait(3000)

    

    CreateBlips()

    for _, loc in ipairs(Config.StartLocations) do
        local ped = SpawnNPC(loc.npc.model, loc.npc.coords, loc.npc.heading, loc.npc.scenario)
        if ped then npcs[#npcs + 1] = ped end
    end

    for _, loc in ipairs(Config.DeliveryPoints) do
        local ped = SpawnNPC(loc.npc.model, loc.npc.coords, loc.npc.heading, loc.npc.scenario)
        if ped then npcs[#npcs + 1] = ped end
    end

    
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Citizen.InvokeNative(N.CLEAR_GPS_MULTI)
    for _, b in ipairs(createdBlips) do RemoveBlipSafe(b) end
    RemoveBlipSafe(destBlip)
    for _, ped in ipairs(npcs) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, cow in ipairs(cows) do
        if DoesEntityExist(cow.entity) then DeleteEntity(cow.entity) end
    end
end)


local function CalculateReward(startCoords, destCoords)
    local distance = #(startCoords - destCoords)
    return math.floor(Config.BaseReward + (distance * Config.RewardPerMeter))
end


CreateThread(function()
    while true do
        local sleep = 1000

        if not activeDrive and not menuOpen and KEY then
            local pCoords = GetEntityCoords(PlayerPedId())

            for i, loc in ipairs(Config.StartLocations) do
                local dist = #(pCoords - loc.npc.coords)
                if dist < 15.0 then
                    sleep = 0
                    if dist < 2.5 then
                        SendUI('setPrompt', { text = ('[%s] Talk to the Ranch Hand'):format(Config.InteractKey) })
                        if IsControlJustReleased(0, KEY) then
                            currentStartIndex = i
                            menuOpen = true
                            SetNuiFocus(true, true)

                           
                            local destinationsWithReward = {}
                            for j, dest in ipairs(Config.DeliveryPoints) do
                                local reward = CalculateReward(loc.coords, dest.coords)
                                destinationsWithReward[j] = {
                                    label = dest.label,
                                    reward = reward,
                                }
                            end

                            SendUI('showMenu', {
                                startIndex = i,
                                destinations = destinationsWithReward,
                            })
                        end
                        break
                    end
                end
            end
        end
        Wait(sleep)
    end
end)


CreateThread(function()
    while true do
        Wait(1000)
        if menuOpen then
            SetNuiFocus(true, true)
        else
            local pCoords = GetEntityCoords(PlayerPedId())
            local near = false
            for _, loc in ipairs(Config.StartLocations) do
                if #(pCoords - loc.npc.coords) < 2.5 then near = true break end
            end
            if not near then SendUI('setPrompt', { text = '' }) end
        end
    end
end)


local function MakeCowFollow(entity)
    local playerPed = PlayerPedId()
    Citizen.InvokeNative(N.TASK_FOLLOW_OFFSET, entity, playerPed,
        math.random(-2, 2) + 0.0, -3.0 + math.random(-2, 0), 0.0,
        1.2, -1, 1.5, true, true, false, false, false)
end

local function SpawnHerd(startCoords, startHeading, destCoords)
    for _, cow in ipairs(cows) do
        if DoesEntityExist(cow.entity) then DeleteEntity(cow.entity) end
    end
    cows = {}

    local model = LoadModel(Config.CowModel)
    if not model then
       
        return
    end

    local netIds = {}
    local playerPed = PlayerPedId()

    for i = 1, Config.HerdSize do
        local angle = (i / Config.HerdSize) * (math.pi * 2)
        local offset = vector3(math.cos(angle) * 3.0, math.sin(angle) * 3.0, 0.0)
        local spawnPos = startCoords + offset

        local found, groundZ = GetGroundZAndNormalFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z + 50.0)
        if found and groundZ and groundZ > 0.0 then
            spawnPos = vector3(spawnPos.x, spawnPos.y, groundZ)
        end

        local ped = CreatePed(model, spawnPos.x, spawnPos.y, spawnPos.z + 0.5,
                              startHeading + math.random(-30, 30), true, true)

        if ped and ped ~= 0 and DoesEntityExist(ped) then
            Citizen.InvokeNative(N.SET_MISSION_ENTITY, ped, true)
            SetEntityAsMissionEntity(ped, true, true)

            local offX = math.random(-2, 2) + 0.0
            local offY = -3.0 + math.random(-2, 0)
            Citizen.InvokeNative(N.TASK_FOLLOW_OFFSET, ped, playerPed,
                offX, offY, 0.0, 1.2, -1, 1.5, true, true, false, false, false)

            cows[#cows + 1] = {
                entity = ped,
                delivered = false,
                panic = false,
                deadHandled = false,
                followTimer = 0,
            }
            netIds[#netIds + 1] = NetworkGetNetworkIdFromEntity(ped)
            
                
        else
            
        end
    end

    SetModelAsNoLongerNeeded(model)
    TriggerServerEvent('phils-cattledrive:server:registerCows', netIds)

   
    RemoveBlipSafe(destBlip)
    destBlip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, destCoords)
    if destBlip then
        SetBlipSprite(destBlip, 423351566)
        BlipAddModifier(destBlip, joaat('BLIP_MODIFIER_COLOR_GREEN'))
        Citizen.InvokeNative(N.SET_BLIP_NAME, destBlip, 'Cattle Drive Destination')
        StartGpsMultiRoute(`COLOR_GREEN`, true, true)
        AddPointToGpsMultiRoute(destCoords)
        SetGpsMultiRouteRender(true)
    else
        
    end

    activeDrive = true
end



CreateThread(function()
    while true do
        local sleep = 1000

        if activeDrive then
            sleep = 250
            local pCoords = GetEntityCoords(PlayerPedId())
            local lost = 0

            for _, cow in ipairs(cows) do
                if not cow.delivered and not cow.deadHandled and DoesEntityExist(cow.entity) then
                    local cCoords = GetEntityCoords(cow.entity)
                    local dist = #(pCoords - cCoords)

                    if dist > Config.PanicDistance and not cow.panic then
                        cow.panic = true
                        Citizen.InvokeNative(N.TASK_ANIMAL_FLEE, cow.entity,
                            cCoords.x + math.random(-50, 50),
                            cCoords.y + math.random(-50, 50),
                            cCoords.z, 3.0, -1, false)
                    elseif dist < (Config.PanicDistance / 2) and cow.panic then
                        cow.panic = false
                        ClearPedTasks(cow.entity)
                        MakeCowFollow(cow.entity)
                    end

                    if not cow.panic then
                        cow.followTimer = (cow.followTimer or 0) + 250
                        if cow.followTimer >= 5000 then
                            cow.followTimer = 0
                            ClearPedTasks(cow.entity)
                            MakeCowFollow(cow.entity)
                        end
                    end

                    if IsEntityDead(cow.entity) then
                        cow.deadHandled = true
                        lost = lost + 1
                        TriggerServerEvent('phils-cattledrive:server:cowLost')
                    end
                end
            end
        end
        Wait(sleep)
    end
end)


CreateThread(function()
    while true do
        local sleep = 1000

        if activeDrive and currentDest then
            sleep = 500
            local dCoords = currentDest.coords

            for _, cow in ipairs(cows) do
                if not cow.delivered and not cow.deadHandled and DoesEntityExist(cow.entity) then
                    local cCoords = GetEntityCoords(cow.entity)
                    if #(cCoords - dCoords) < 15.0 then
                        cow.delivered = true
                        FreezeEntityPosition(cow.entity, true)
                        TriggerServerEvent('phils-cattledrive:server:cowDelivered',
                            NetworkGetNetworkIdFromEntity(cow.entity))
                    end
                end
            end

            local alive, delivered = 0, 0
            for _, cow in ipairs(cows) do
                if not cow.deadHandled then alive = alive + 1 end
                if cow.delivered then delivered = delivered + 1 end
            end
            if alive == 0 and delivered == 0 then
                TriggerServerEvent('phils-cattledrive:server:cancelDrive')
            end
        end
        Wait(sleep)
    end
end)


RegisterNUICallback('startDrive', function(data, cb)
    local dest = tonumber(data.destination) or 1
    

    if not currentStartIndex then
       
    end

    menuOpen = false
    SetNuiFocus(false, false)
    TriggerServerEvent('phils-cattledrive:server:startDrive', currentStartIndex, dest)
    cb('ok')
end)


RegisterNUICallback('closeUI', function(_, cb)
    menuOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('cancelDrive', function(_, cb)
    TriggerServerEvent('phils-cattledrive:server:cancelDrive')
    cb('ok')
end)


RegisterNetEvent('phils-cattledrive:client:spawnHerd', function(startCoords, startHeading, destCoords, destIndex, reward)
    

    if not startCoords or not destCoords then
        
        return
    end

    currentDest = Config.DeliveryPoints[destIndex or 1]
    currentReward = reward or Config.RewardMoney
    SpawnHerd(startCoords, startHeading, destCoords)
end)


RegisterNetEvent('phils-cattledrive:client:driveComplete', function()
    activeDrive = false
    currentDest = nil

    SendUI('driveComplete', { earned = true })
    SetTimeout(4000, function() end)

    RemoveBlipSafe(destBlip)
    Citizen.InvokeNative(N.CLEAR_GPS_MULTI)
    destBlip = nil

    for _, cow in ipairs(cows) do
        if DoesEntityExist(cow.entity) then
            SetEntityAsMissionEntity(cow.entity, true, true)
            DeleteEntity(cow.entity)
        end
    end
    cows = {}
end)

RegisterNetEvent('phils-cattledrive:client:cleanup', function()
    activeDrive = false
    currentDest = nil
    menuOpen = false

    RemoveBlipSafe(destBlip)
    Citizen.InvokeNative(N.CLEAR_GPS_MULTI)
    destBlip = nil

    for _, cow in ipairs(cows) do
        if DoesEntityExist(cow.entity) then
            SetEntityAsMissionEntity(cow.entity, true, true)
            DeleteEntity(cow.entity)
        end
    end
    cows = {}

    SetNuiFocus(false, false)
end)
