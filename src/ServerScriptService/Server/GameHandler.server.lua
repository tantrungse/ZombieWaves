-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ServerStorage = game:GetService("ServerStorage") 

-- Variables --
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "GAME_OVER_WIN","WAITING"}

local gameEvent = ReplicatedStorage.Remotes.GameEvent
local respawnEvent = ReplicatedStorage.GUI.Respawn

local zombieSpawns = workspace.Spawns.ZombieSpawns:GetChildren()
local zombies = ServerStorage.Zombies
local zombiesWorkspace = workspace.Zombies

local rng = Random.new()
local currentWave = 0

local zombiesInWave = {
    ["Wave1"] = {["Zombie"] = 12},
    ["Wave2"] = {["Zombie"] = 20},
    ["Wave3"] = {["Zombie"] = 18, ["Fast Zombie"] = 8},
    ["Wave4"] = {["Zombie"] = 24, ["Fast Zombie"] = 10},
    ["Wave5"] = {["Zombie"] = 24, ["Fast Zombie"] = 12, ["Tough Zombie"] = 4},
    ["Wave6"] = {["Zombie"] = 28, ["Fast Zombie"] = 16, ["Tough Zombie"] = 8},
    ["Wave7"] = {["Zombie"] = 28, ["Fast Zombie"] = 16, ["Tough Zombie"] = 10, ["Fast Zombie Boss"] = 2},
    ["Wave8"] = {["Zombie"] = 34, ["Fast Zombie"] = 20, ["Tough Zombie"] = 12, ["Fast Zombie Boss"] = 4, ["Tough Zombie Boss"] = 2},
    ["Wave9"] = {["Zombie"] = 36, ["Fast Zombie"] = 28, ["Tough Zombie"] = 16, ["Lightning Zombie"] = 8, ["Fast Zombie Boss"] = 5, ["Tough Zombie Boss"] = 4},
    ["Wave10"] = {["Zombie"] = 40, ["Fast Zombie"] = 28, ["Tough Zombie"] = 18, ["Lightning Zombie"] = 12, ["Fast Zombie Boss"] = 8, ["Tough Zombie Boss"] = 5},
    ["Wave11"] = {["Zombie"] = 44, ["Fast Zombie"] = 30, ["Tough Zombie"] = 20, ["Lightning Zombie"] = 14, ["Fast Zombie Boss"] = 8, ["Tough Zombie Boss"] = 6, ["Ultimate Zombie Boss"] = 1},
}

local waveCash = {
    ["Wave1"] = 20,
    ["Wave2"] = 20,
    ["Wave3"] = 20,
    ["Wave4"] = 30,
    ["Wave5"] = 30,
    ["Wave6"] = 30,
    ["Wave7"] = 40,
    ["Wave8"] = 50,
    ["Wave9"] = 60,
    ["Wave10"] = 70,
}

-- Contants --
local TOTAL_WAVES = 11

-- Functions --
local function createHighlight(parent, properties)
    local highlight = Instance.new("Highlight")
    for property,value in pairs(properties) do
        highlight[property] = value
    end
    highlight.Parent = parent
    return highlight
end

-- Event
Players.PlayerAdded:Connect(function(player)
    player.Team = Teams.Dead

    player.CharacterAdded:Connect(function(character)
        character.Humanoid.Died:Connect(function()
            player.Team = Teams.Dead
        end)
    end)
end)

respawnEvent.OnServerEvent:Connect(function(player)
    if workspace:GetAttribute("GameState") ~= gameEnum[1] and workspace:GetAttribute("GameState") ~= gameEnum[2] then return end

    player.Team = Teams.Alive
    player:LoadCharacter()
    local knifeClone = ServerStorage.Tools.Knife:Clone()
    local pistolClone = ServerStorage.Tools.Pistol:Clone()
    knifeClone.Parent = player.Backpack
    pistolClone.Parent = player.Backpack
end)

Teams.Alive.PlayerRemoved:Connect(function()
    if workspace:GetAttribute("GameState") == gameEnum[4] 
    or workspace:GetAttribute("GameState") == gameEnum[5] 
    or workspace:GetAttribute("GameState") == gameEnum[6] then return end
    local alivePlayers = Teams.Alive:GetPlayers()
    if #alivePlayers == 0 then
        workspace:SetAttribute("GameState", gameEnum[4])
    end
end)

workspace.AttributeChanged:Connect(function(name)
    if name ~= "GameState" then return end

    if workspace:GetAttribute(name) == gameEnum[1] then
        -- START INTERMISSION
        gameEvent:FireAllClients("UpdateText", "WAITING FOR PLAYERS...")
        Teams.Alive.PlayerAdded:Wait()
        for i = 30, 1, -1 do
            gameEvent:FireAllClients("UpdateText", "WAVES ARE STARTING IN "..i.." SECONDS!")
            task.wait(1)
        end
        if workspace:GetAttribute(name) == gameEnum[1] then
            workspace:SetAttribute(name, gameEnum[3])
        end
    elseif workspace:GetAttribute(name) == gameEnum[2] then
        -- INTERMISSION
        for i = 60, 1, -1 do
            gameEvent:FireAllClients("UpdateText", "INTERMISSION: "..i.." SECONDS UNTIL NEXT WAVE!")
            task.wait(1)
        end
        if workspace:GetAttribute(name) == gameEnum[2] then
            workspace:SetAttribute(name, gameEnum[3])
        end
    elseif workspace:GetAttribute(name) == gameEnum[3] then
        -- WAVE IN PROGRESS
        currentWave += 1
        local zombiesToSpawn = {}
        for zombie,amount in pairs(zombiesInWave["Wave"..currentWave]) do
            for i = 1, amount do
                local clone = zombies[zombie]:Clone()
                table.insert(zombiesToSpawn, clone)
            end
        end
        local zombiesLeft = #zombiesToSpawn

        gameEvent:FireAllClients("UpdateText", "WAVE "..currentWave.." IN PROGRESS! || "..zombiesLeft.." ZOMBIES LEFT!")

        while workspace:GetAttribute(name) == gameEnum[3] and #zombiesToSpawn > 0 do
            local randomNum = rng:NextInteger(1, #zombiesToSpawn)
            zombiesToSpawn[randomNum].HumanoidRootPart.CFrame = zombieSpawns[rng:NextInteger(1, #zombieSpawns)].Attachment.WorldCFrame
            zombiesToSpawn[randomNum].Parent = zombiesWorkspace

            zombiesToSpawn[randomNum].Humanoid.Died:Connect(function()
                zombiesLeft -= 1
                gameEvent:FireAllClients("UpdateText", "WAVE "..currentWave.." IN PROGRESS! || "..zombiesLeft.." ZOMBIES LEFT!")
                if zombiesLeft == 1 then
                    for _,zombie in ipairs(zombiesWorkspace:GetChildren()) do
                        if zombie.Humanoid.Health > 0 then
                            createHighlight(zombie, {["FillColor"] = Color3.fromRGB(255, 205, 26)})
                        end
                    end
                elseif zombiesLeft == 0 and workspace:GetAttribute("GameState") == gameEnum[3] then
                    if currentWave ~= TOTAL_WAVES then
                        for _,player in ipairs(Players:GetPlayers()) do
                            player.leaderstats.Money.Value += waveCash["Wave"..currentWave]
                        end
                        workspace:SetAttribute(name, gameEnum[2])
                    else
                        workspace:SetAttribute(name, gameEnum[5])
                    end
                end
            end)

            table.remove(zombiesToSpawn, randomNum)
            task.wait(0.5)
        end

    elseif workspace:GetAttribute(name) == gameEnum[4] then
        -- GAME OVER, PLAYERS LOST
        gameEvent:FireAllClients("UpdateText", "GAME OVER... ZOMBIES WIN...")
        task.wait(10)
        workspace:SetAttribute(name, gameEnum[6])
    elseif workspace:GetAttribute(name) == gameEnum[5] then
        -- GAME OVER! PLAYERS WIN
        gameEvent:FireAllClients("UpdateText", "GAME OVER! YOU WIN!!")
        task.wait(10)
        workspace:SetAttribute(name, gameEnum[6])
    elseif workspace:GetAttribute(name) == gameEnum[6] then
        -- WAITING FOR CLEANUP
        gameEvent:FireAllClients("UpdateText", "CLEANING UP GAME...")
        zombiesWorkspace:ClearAllChildren()
        workspace.FilteringFolder.BulletHoles:ClearAllChildren()
        currentWave = 0
        for _,player in ipairs(Teams.Alive:GetPlayers()) do
            player.Team = Teams.Dead
            player:LoadCharacter()
        end
        task.wait(5)
        for i = 10, 1, -1 do
            gameEvent:FireAllClients("UpdateText", "STARTING A NEW GAME IN "..i.." SECONDS!")
            task.wait(1)
        end
        workspace:SetAttribute(name, gameEnum[1])
    end
end)

workspace:SetAttribute("GameState", gameEnum[1]) -- Starting the game