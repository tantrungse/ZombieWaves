-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Variables --
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "WAITTING"}

workspace:SetAttribute("GameState", gameEnum[2])

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

respawnEvent.OnServerEvent:Connect(function(player)
    if workspace:GetAttribute("GameState") ~= gameEnum[1] and workspace:GetAttribute("GameState") ~= gameEnum[2] then return end

    player.Team = Teams.Alive
    player:LoadCharacter()
end)