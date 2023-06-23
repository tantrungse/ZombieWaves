-- Variables --
local properties = require(script.Parent.Properties)
local myHumanoid = script.Parent.Humanoid

-- Debounces --
local healing = false

-- Event handlers --
if properties.AgentParams.AgentCanJump then
	script.Parent.LowerTorso.Touched:Connect(function(otherPart)
		if otherPart.Parent:FindFirstChildWhichIsA("Humanoid") then return end
		
		myHumanoid.Jump = true
	end)
end

if properties.RegeneratesHealth then
	myHumanoid.HealthChanged:Connect(function(newHealth)
		if healing then return end
		if myHumanoid.Health >= myHumanoid.MaxHealth then return end
		healing = true
		repeat
			myHumanoid.Health += properties.HealthRegenAmount
			task.wait(properties.HealthRegenTick)
		until myHumanoid.Health >= (myHumanoid.MaxHealth * properties.HealthRegenLimit) or myHumanoid.Health < 1
	end)
end