-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local gameEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GameEvent")
local gui = script.Parent
local textLabel = gui:WaitForChild("Frame"):WaitForChild("TextLabel")

-- Event handler --
gameEvent.OnClientEvent:Connect(function(action, text)
    if action == "UpdateText" then
        textLabel.Text = text
    end    
end)