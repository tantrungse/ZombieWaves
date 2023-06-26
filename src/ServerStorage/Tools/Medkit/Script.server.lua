-- Variables --
local tool = script.Parent
local properties = require(tool.Properties)

local healingDebounce = false

-- Functions --
local function createSound(parent, soundProperties)
    local sound = Instance.new("Sound")
    for property,value in pairs(soundProperties) do
        sound[property] = value
    end
    sound.Parent = parent
    return sound
end

-- Handlers --
tool.Activated:Connect(function()
    if healingDebounce then return end
    if tool.Parent.Humanoid.Health >= tool.Parent.Humanoid.MaxHealth then return end
    healingDebounce = true

    local healingSound = createSound(tool.Handle, properties.HealingSoundProperties)
    healingSound:Play()
    healingSound.Ended:Connect(function()
        healingSound:Destroy()
    end)
    task.wait(properties.AnimationDuration)

    if tool.Parent.Name ~= "Backpack" then
        tool.Parent.Humanoid.Health += properties.HealingAmount
    else
        healingDebounce = false
        return
    end

    if not properties.OneUse then
        task.wait(properties.HealingCooldown)
        healingDebounce = false
    else
        tool:Destroy()
    end
end)