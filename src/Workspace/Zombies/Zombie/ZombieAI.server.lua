-- Services --
local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")

-- Variables --
local properties = require(script.Parent.Properties)

local myHumanoid = script.Parent.Humanoid
local myRootPart = script.Parent.HumanoidRootPart
myRootPart:SetNetworkOwner() -- give server full control our zombies
local head = script.Parent.Head
local soundIDs = {
	["AttackIDs"] = properties.AttackSoundIDs,
	["DeathIDs"] = properties.DeathSoundIDs,
	["PlayerSeenIDs"] = properties.PlayerSeenSoundIDs,
	["GrowlIDs"] = properties.GrowlSoundIDs
}

-- Animator
local animator = myHumanoid.Animator

for property,value in pairs(properties.HumanoidStats) do
	myHumanoid[property] = value
end

local currentHealth = myHumanoid.Health
local targetingDistance = properties.TargetingDistance
local rng = Random.new()

-- Conditions --
local alive = true
local wandering = false
local canAttack = true

-- Functions --
local function waitUntil(event, timeOut)
	local thread = coroutine.running()
	
	local connection = nil
	connection = event:Connect(function(...)
		if connection == nil then 
			return
		end
		
		connection:Disconnect()
		connection = nil
		
		task.spawn(thread, false, ...)
	end)
	
	task.delay(timeOut, function()
		if connection == nil then
			return
		end
		
		connection:Disconnect()
		connection = nil
		
		task.spawn(thread, true)
	end)
	
	return coroutine.yield()
end

local function playRandomSound(idList, parent)
	local sound = Instance.new("Sound")
	sound.SoundId = idList[rng:NextInteger(1, #idList)]
	for property,value in pairs(properties.SoundProperties) do
		sound[property] = value
	end
	sound.Parent = parent
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function wander()
	wandering = true
	local randomX = rng:NextInteger(-8, 8)
	local randomZ = rng:NextInteger(-8, 8)
	local goal = myRootPart.Position + Vector3.new(randomX, 0, randomZ)
	
	local path = Pathfinding:CreatePath(properties.AgentParams) :: Path
	path:ComputeAsync(myRootPart.Position, goal)
	local waypoints = path:GetWaypoints()
	
	if path.Status == Enum.PathStatus.Success then
		for _,waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				myHumanoid.Jump = true
			end
			myHumanoid:MoveTo(waypoint.Position)
			local timeOut = waitUntil(myHumanoid.MoveToFinished, 3)
			if timeOut then
				print("Zombie time out! Is it stuck?")
				myHumanoid.Jump = true
				break
			end
			if not wandering then break end
			if rng:NextInteger(1, 100) == 1 then
				playRandomSound(soundIDs.GrowlIDs, head)
			end
		end
	else
		return
	end
	task.wait(rng:NextInteger(1, 3))
end

local function attack(target)
	if not canAttack then return end
	if (myRootPart.Position - target.Position).Magnitude < properties.AttackRange then
		if target.Parent == nil then return end
		canAttack = false

		local attackAnim = Instance.new("Animation")
		attackAnim.AnimationId = properties.AttackAnimationIDs[rng:NextInteger(1, #properties.AttackAnimationIDs)]
		local attackTrack = animator:LoadAnimation(attackAnim)
		attackTrack:Play()
		attackTrack.Ended:Connect(function()
			attackTrack:Destroy()
			attackAnim:Destroy()
		end)
		
		if rng:NextInteger(1, 4) == 1 then
			playRandomSound(soundIDs.AttackIDs, head)
		end
		-- play attack animation
		target.Parent.Humanoid:TakeDamage(properties.DamagePerHit)
		
		task.delay(properties.CooldownBetweenAttack, function()
			canAttack = true
		end)
	end
end

local function checkVisbility(target)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {script.Parent, workspace.FilteringFolder, workspace.Zombies}
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	local direction = (target.Position - head.Position).Unit
	local result = workspace:Raycast(head.Position, direction * targetingDistance, params)
	if result and result.Instance:IsDescendantOf(target.Parent) then
		if target.Position.Y <= myRootPart.Position.Y then
			return true
		elseif math.abs(target.Position.Y - myRootPart.Position.Y) > properties.MaxVisibilityHeight then
			return false
		else 
			return true
		end
	end
	return false
end

local function newPathTo(target)
	local path = Pathfinding:CreatePath(properties.AgentParams)
	path:ComputeAsync(myRootPart.Position, target.Position)
	local waypoints = path:GetWaypoints()
	
	--[[
	local color = Color3.fromRGB(rng:NextInteger(0, 255), rng:NextInteger(0, 255), rng:NextInteger(0, 255))
	for i,waypoint in ipairs(waypoints) do
		local part = Instance.new("Part")
		part.Shape = "Ball"
		part.Material = "Neon"
		part.Color = color
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Position = waypoint.Position
		part.Anchored = true
		part.CanCollide = false
		part.Parent = workspace
	end
	--]]
	
	if path.Status == Enum.PathStatus.Success then
		for _,waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				myHumanoid.Jump = true
			end
			myHumanoid:MoveTo(waypoint.Position)
			local timeOut = waitUntil(myHumanoid.MoveToFinished, 3)
			if timeOut then
				print("Zombie time out! Is it stuck?")
				myHumanoid.Jump = true
				newPathTo(target)
				break;
			end
			if checkVisbility(target) then
				repeat
					myHumanoid:MoveTo(target.Position + target.CFrame.LookVector * 2)
					attack(target)
					if rng:NextInteger(1, 150) == 1 then
						playRandomSound(soundIDs.GrowlIDs, head)
					end
					
					if target == nil then
						break
					elseif target.Parent == nil then
						break
					end
					task.wait(0.05)
				until checkVisbility(target) == false or not alive or target.Parent.Humanoid.Health < 1
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end
			if (myRootPart.Position - target.Position).Magnitude > targetingDistance then
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end
			if (myRootPart.Position - waypoints[1].Position).Magnitude > properties.RecalculatePathAfterDist then
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end
		end
	else
		myHumanoid.Jump = true
	end
end

local function getNearestPlayer()
	local closestTarget = nil
	local lastDist = properties.AlertTargetingDistance * 2
	
	for _,player in ipairs(Players:GetPlayers()) do
		if player.Team == game:GetService("Teams").Dead or not player.Character
			or not player.Character.HumanoidRootPart or player.Character.Humanoid.Health < 1 then return end
		
		local newTarget = player.Character.HumanoidRootPart
		local distance = (myRootPart.Position - newTarget.Position).Magnitude
		if (distance <= targetingDistance) and (distance < lastDist) then
			closestTarget = newTarget
			lastDist = distance
		end
	end
	if closestTarget then
		if rng:NextInteger(1, 10) == 1 then
			playRandomSound(soundIDs.PlayerSeenIDs, head)
		end
	end
	
	return closestTarget
end

-- Handlers --
myHumanoid.Died:Connect(function()
	alive = false
	playRandomSound(soundIDs.DeathIDs, head)
	task.wait(5)
	script.Parent:Destroy()
end)

myHumanoid.HealthChanged:Connect(function(newHealth)
	if newHealth < currentHealth then
		currentHealth = newHealth
		wandering = false
		targetingDistance = properties.AlertTargetingDistance
	end
end)

while alive do
	local target = getNearestPlayer()
	if target then 
		myHumanoid.WalkSpeed = properties.ChaseSpeed
		newPathTo(target)
	else
		myHumanoid.WalkSpeed = properties.WanderSpeed
		wander()
		wandering = false
	end
	
	task.wait(0.1)
end