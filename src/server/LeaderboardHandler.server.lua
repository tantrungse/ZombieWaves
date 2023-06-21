-- Services --
local Players = game:GetService("Players")

-- Function --
local function createIntValue(name, value, parent)
    local int = Instance.new("IntValue")
    int.Name = name
    int.Value = value
    int.Parent = parent
end

-- Handler --
Players.PlayerAdded:Connect(function(player)
    local folder = Instance.new("Folder")
    folder.Name = "leaderstats"
    folder.Parent = player

    createIntValue("Kills", 0, folder)
    createIntValue("Deaths", 0, folder)
    createIntValue("Money", 0, folder)

    player.CharacterAdded:Connect(function(character)
        character.Humanoid.Died:Connect(function()
            player.leaderstats.Deaths.Value += 1
        end)
    end)
end)