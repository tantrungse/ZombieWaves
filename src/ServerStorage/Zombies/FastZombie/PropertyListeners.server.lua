-- VARIABLES --
local properties = require(script.Parent.Properties)
local myHumanoid = script.Parent.Humanoid

-- Debounces --
local healing = false
local rng = Random.new()

-- Event handlers --
if properties.AgentParams.AgentCanJump then
	script.Parent.LowerTorso.Touched:Connect(function(otherPart)
		-- just incase zombie isn't jumping when it's supposed to
		if otherPart.Parent:FindFirstChildWhichIsA("Humanoid") then return end
		-- stop the zombie from jumping if it hits another zombie or touches a player
		
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
		healing = false
	end)
end

myHumanoid.Died:Connect(function()
	local player = script.Parent.WhoLastDamaged.Value
	if not player then return end
	if not player:IsA("Player") then return end
	
	player.leaderstats.Kills.Value += 1
	player.leaderstats.Money.Value += rng:NextInteger(properties.MoneyDrop.Min, properties.MoneyDrop.Max)
end)