

local RSGCore = exports['rsg-core']:GetCoreObject()
local activeDrives = {} 


local function CalculateReward(startCoords, destCoords)
    local distance = #(startCoords - destCoords)
    local reward = math.floor(Config.BaseReward + (distance * Config.RewardPerMeter))
    return reward
end


RegisterNetEvent('phils-cattledrive:server:startDrive', function(startIndex, destIndex)
    local src = source
    

    startIndex = tonumber(startIndex)
    destIndex  = tonumber(destIndex) or 1

    if not startIndex then
       
        return
    end

    local startLoc = Config.StartLocations[startIndex]
    local destLoc  = Config.DeliveryPoints[destIndex]

    if not startLoc then
        
        return
    end
    if not destLoc then
        
        return
    end

    if activeDrives[src] then
        
        return
    end

    
    if Config.RequiredJob then
        local Player = RSGCore.Functions.GetPlayer(src)
        if not Player or Player.PlayerData.job.name ~= Config.RequiredJob then
            TriggerClientEvent('RSGCore:Notify', src, 'You need the ' .. Config.RequiredJob .. ' job', 'error')
            return
        end
    end

    local reward = CalculateReward(startLoc.coords, destLoc.coords)

    activeDrives[src] = {
        startIndex = startIndex,
        destIndex  = destIndex,
        delivered  = 0,
        lost       = 0,
        reward     = reward,
    }

    
    TriggerClientEvent('phils-cattledrive:client:spawnHerd', src,
        startLoc.coords, startLoc.heading, destLoc.coords, destIndex, reward)
end)


RegisterNetEvent('phils-cattledrive:server:registerCows', function(netIds)
    local src = source
    if not activeDrives[src] then return end
    activeDrives[src].cows = netIds
    
end)


RegisterNetEvent('phils-cattledrive:server:cowDelivered', function(netId)
    local src = source
    local drive = activeDrives[src]
    if not drive then return end

    drive.delivered = drive.delivered + 1
    

    if drive.delivered >= Config.HerdSize then
        local Player = RSGCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney(Config.RewardAccount, drive.reward, 'cattle-drive-complete')
            TriggerClientEvent('RSGCore:Notify', src,
                'Herd delivered! You earned $' .. drive.reward, 'success')
        end

        TriggerClientEvent('phils-cattledrive:client:driveComplete', src)
        activeDrives[src] = nil
    end
end)


RegisterNetEvent('phils-cattledrive:server:cowLost', function()
    local src = source
    local drive = activeDrives[src]
    if not drive then return end

    drive.lost = drive.lost + 1
    

    
    if drive.lost + drive.delivered >= Config.HerdSize and drive.delivered == 0 then
        TriggerClientEvent('RSGCore:Notify', src, 'You lost the entire herd!', 'error')
        TriggerClientEvent('phils-cattledrive:client:cleanup', src)
        activeDrives[src] = nil
    end
end)


RegisterNetEvent('phils-cattledrive:server:cancelDrive', function()
    local src = source
    if not activeDrives[src] then return end
    activeDrives[src] = nil
    TriggerClientEvent('phils-cattledrive:client:cleanup', src)
end)


AddEventHandler('playerDropped', function()
    local src = source
    if activeDrives[src] then
        activeDrives[src] = nil
    end
end)
