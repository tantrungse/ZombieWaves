local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local tool = script.Parent
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

local swungEvent = tool:WaitForChild("Script"):WaitForChild("Swung")
local properties = require(tool:WaitForChild("Properties"))
local rng = Random.new()

-- Debounce --
local swingDebounce = false

-- Functions --
local function createTrack(animID)
    local animation = Instance.new("Animation")
    animation.AnimationId = animID
    return animator:LoadAnimation(animation)
end
local equipTrack = createTrack(properties.EquipAnimation)

-- Handlers --
tool.Equipped:Connect(function()
    equipTrack:Play()
end)

tool.Unequipped:Connect(function()
    equipTrack:Stop()
end)

tool.Activated:Connect(function()
    if swingDebounce then return end
    swingDebounce = true

    local swingTrack = createTrack(properties.SwingAnimations[rng:NextInteger(1, #properties.SwingAnimations)])
    swingTrack:Play()
    swingTrack:AdjustSpeed(1/properties.AnimationDuration)
    swungEvent:FireServer()
    swingTrack.Ended:Wait()
    task.wait(properties.SwingCooldown)
    swingDebounce = false
end)