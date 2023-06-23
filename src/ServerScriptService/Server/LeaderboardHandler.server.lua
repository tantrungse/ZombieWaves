-- Services --
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playerLeaderboardData = DataStoreService:GetDataStore("PlayerStats")

local erroredPlayer = {}
local oldPlayerData = {}

-- Function --
local function createIntValue(name, value, parent)
    local int = Instance.new("IntValue")
    int.Name = name
    int.Value = value
    int.Parent = parent
end

local function saveData(player)
    if erroredPlayer[player.Name] then return end
    if player.UserId < 1 then return end
    if (oldPlayerData[player.Name].Kills > player.leaderstats.Kills.Value) 
    or (oldPlayerData[player.Name].Deaths > player.leaderstats.Deaths.Value) then return end

    playerLeaderboardData:SetAsync(
        player.UserId, {Kills = player.leaderstats.Kills.Value, Deaths = player.leaderstats.Deaths.Value})
end

-- Handler --
Players.PlayerAdded:Connect(function(player)
    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"
    folder.Parent = player

    createIntValue("Kills", 0, folder)
    createIntValue("Deaths", 0, folder)
    createIntValue("Money", 0, folder)

    local success, result = pcall(function()
        return playerLeaderboardData:GetAsync(player.UserId)
    end)

    if not success then
        warn("Error encountered when trying to grab player data!")
        print(result)
        erroredPlayer[player.Name] = true
    else
        player.leaderstats.Kills.Value = result.Kills
        player.leaderstats.Deaths.Value = result.Deaths
    end
    oldPlayerData[player.Name] = {Kills = player.leaderstats.Kills.Value, Deaths = player.leaderstats.Deaths.Value}

    player.CharacterAdded:Connect(function(character)
        character.Humanoid.Died:Connect(function()
            player.leaderstats.Deaths.Value += 1
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local success, result = pcall(function()
        saveData(player)
    end)

    if not success then
        repeat
            success, result = pcall(function()
                saveData(player)
            end)
            task.wait(5)
        until success
    end

    if erroredPlayer[player.Name] then
        erroredPlayer[player.Name] = nil
    end
    if oldPlayerData[player.Name] then
        oldPlayerData[player.Name] = nil
    end
end)

game:BindToClose(function()
    for _,player in ipairs(Players:GetPlayers()) do
        pcall(function()
            saveData(player)
        end)
    end
end)