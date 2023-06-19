-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Variables --
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "WAITTING"}

local currentGameState = gameEnum[2]

local playButtonEvent = ReplicatedStorage.GUI.Play
local respawnEvent = ReplicatedStorage.GUI.Respawn

-- Event
Players.PlayerAdded:Connect(function(player)
    player.Team = Teams.Dead

    player.CharacterAdded:Connect(function(character)
        character.Humanoid.Died:Connect(function()
            player.Team = Teams.Dead
        end)
    end)
end)

playButtonEvent.OnServerInvoke = function()
    if currentGameState ~= gameEnum[1] and currentGameState ~= gameEnum[2] then
        -- for start intermission or intermission
        return false, "Please wait! Game in progress..."
    end
    return true
end

respawnEvent.OnServerEvent:Connect(function(player)
    if currentGameState ~= gameEnum[1] and currentGameState ~= gameEnum[2] then return end

    player.Team = Teams.Alive
    player:LoadCharacter()
end)