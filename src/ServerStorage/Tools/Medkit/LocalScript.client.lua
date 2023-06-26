-- Services --
local Players = game:GetService("Players")

-- Variables --
local tool = script.Parent
local properties = require(tool:WaitForChild("Properties"))

-- Animations --
local player = Players.LocalPlayer
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

-- Debounces --
local healingDebounce = false

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

tool.Destroying:Connect(function()
    equipTrack:Stop()
end)

tool.Activated:Connect(function()
    if healingDebounce then return end
    if humanoid.Health >= humanoid.MaxHealth then return end
    healingDebounce = true

    local healingTrack = createTrack(properties.HealingAnimation)
    healingTrack:Play()
    healingTrack:AdjustSpeed(1/properties.AnimationDuration)
    
    if not properties.OneUse then
        healingTrack.Ended:Wait()
        task.wait(properties.HealingCooldown)
        healingDebounce = false
    end
end)