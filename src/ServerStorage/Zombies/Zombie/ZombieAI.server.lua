-- SERVICES --
local Players = game:GetService("Players")
local Pathfinding = game:GetService("PathfindingService")

-- VARIABLES --
local properties = require(script.Parent.Properties)

local myHumanoid = script.Parent.Humanoid
local myRootPart = script.Parent.HumanoidRootPart
pcall(function()
	myRootPart:SetNetworkOwner()
end)
local head = script.Parent.Head
local soundIDs = {
	["AttackIDs"] = properties.AttackSoundIDs,
	["DeathIDs"] = properties.DeathSoundIDs,
	["PlayerSeenIDs"] = properties.PlayerSeenSoundIDs,
	["GrowlIDs"] = properties.GrowlSoundIDs
}

-- animations
local animator = myHumanoid.Animator

for property,value in pairs(properties.HumanoidStats) do
	-- set all properties for the humanoid
	myHumanoid[property] = value
end
local currentHealth = myHumanoid.Health
local targetingDistance = properties.TargetingDistance
local rng = Random.new()

-- conditions --
local alive = true
local wandering = false
local canAttack = true

-- FUNCTIONS --
local function waitUntil(event, timeOut)
	local thread = coroutine.running()
	-- get current thread

	local connection = nil
	connection = event:Connect(function(...)
		if connection == nil then
			-- don't do anything if the connection was terminated by other function
			return
		end

		connection:Disconnect()
		connection = nil

		task.spawn(thread, false, ...) -- resumes the thread, allowing us to return out of function
	end)

	task.delay(timeOut, function()
		if connection == nil then
			-- don't do anything if the connection was terminated by other function
			return
		end

		connection:Disconnect()
		connection = nil

		task.spawn(thread, true) -- resumes the thread, allowing us to return out of function
	end)

	return coroutine.yield()
	-- yield the current thread, this won't return until the task.spawn functions resume the thread and return either true or false
end

local function playRandomSound(idList, parent)
	-- pick random sound, and play it
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
	-- have our zombie wander around
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
			local timedOut = waitUntil(myHumanoid.MoveToFinished, 3)
			if timedOut then
				print("Zombie timed out! Is it stuck?")
				myHumanoid.Jump = true
				break
			end
			if not wandering then break end -- our wandering got interrupted because a player shot us
			if rng:NextInteger(1, 10) == 1 then
				playRandomSound(soundIDs.GrowlIDs, head)
			end
		end
	else
		return
	end
	task.wait(rng:NextInteger(1, 3)) -- wait a little bit so the zombie sits still before it starts wandering again
end

local function attack(target)
	if not canAttack then return end
	if (myRootPart.Position - target.Position).Magnitude < properties.AttackRange then
		-- zombie is close enough to hurt player
		-- play attack animation, play attack sound
		if target.Parent == nil then return end
		-- just in case if the character gets destroyed
		canAttack = false

		-- animation
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
		-- play attack animation!!
		target.Parent.Humanoid:TakeDamage(properties.DamagePerHit)

		task.delay(properties.CooldownBetweenAttack, function()
			canAttack = true
		end)
	end
end

local function checkVisbility(target)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {script.Parent, workspace.FilteringFolder, workspace.Zombies}
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local direction = (target.Position - head.Position).Unit
	local result = workspace:Raycast(head.Position, direction * targetingDistance, params)
	if result and result.Instance:IsDescendantOf(target.Parent) then
		-- we see something, that something is the player
		if target.Position.Y <= myRootPart.Position.Y then
			-- the player is below the zombie, so the zombie can get to them
			return true
		elseif math.abs(target.Position.Y - myRootPart.Position.Y) > properties.MaxVisibilityHeight then
			-- ...the Y check stops the zombie from being stuck in place in-case they can see the player but the player is too high up
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

	--local color = Color3.fromRGB(rng:NextInteger(0,255),rng:NextInteger(0,255),rng:NextInteger(0,255))
	--for i,waypoint in ipairs(waypoints) do
	--	local part = Instance.new("Part")
	--	part.Shape = "Ball"
	--	part.Material = "Neon"
	--	part.Color = color
	--	part.Size = Vector3.new(0.6,0.6,0.6)
	--	part.Position = waypoint.Position
	--	part.Anchored = true
	--	part.CanCollide = false
	--	part.Parent = workspace
	--end

	if path.Status == Enum.PathStatus.Success then
		for _,waypoint in ipairs(waypoints) do
			if waypoint.Action == Enum.PathWaypointAction.Jump then
				myHumanoid.Jump = true
			end
			myHumanoid:MoveTo(waypoint.Position)
			local timedOut = waitUntil(myHumanoid.MoveToFinished, 3)
			if timedOut then
				print("Zombie timed out! Is it stuck?")
				myHumanoid.Jump = true
				newPathTo(target)
				break
			end
			if checkVisbility(target) then
				-- the zombie can see the player, no need to path find, just run directly towards them
				repeat
					myHumanoid:MoveTo(target.Position + target.CFrame.LookVector*2) -- this offset is OPTIONAL!
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
				-- either we don't see them, or the zombie died, or the player died
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end

			if (myRootPart.Position - target.Position).Magnitude > targetingDistance then
				-- player got too far away, so find new player or start wandering instead
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end
			if (myRootPart.Position - waypoints[1].Position).Magnitude > properties.RecalculatePathAfterDist then
				-- the zombie has been pathfinding for greater than 20 studs and they still can't see the player,
				-- so break out and see if there is a closer player
				myHumanoid:MoveTo(myRootPart.Position+Vector3.new(0,0,0.05))
				break
			end
		end
	else
		-- zombie could be stuck, so just in case, let's make him jump
		myHumanoid.Jump = true
	end
end

local function getNearestPlayer()
	-- find the closest player to the zombie
	local closestTarget = nil
	local lastDist = properties.AlertTargetingDistance * 2 -- set it to something higher than the highest possible targeting distance

	for _,player in ipairs(Players:GetPlayers()) do
		if player.Team == game:GetService("Teams").Dead or not player.Character or not player.Character.HumanoidRootPart 
			or player.Character.Humanoid.Health < 1 then continue end
		-- player either does not have a character or they're dead or they're on the dead team

		local newTarget = player.Character.HumanoidRootPart
		local distance = (myRootPart.Position - newTarget.Position).Magnitude
		if (distance <= targetingDistance) and (distance < lastDist) then
			-- compare to see if this new target is closer than the previous last closest target
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
		-- player damaged us, so become more alert and stop wandering
		wandering = false
		targetingDistance = properties.AlertTargetingDistance
	end
end)

while alive do
	local target = getNearestPlayer()
	if target then
		-- player in range, chase em
		myHumanoid.WalkSpeed = properties.ChaseSpeed
		newPathTo(target)
	else
		-- no players in range, just wander
		myHumanoid.WalkSpeed = properties.WanderSpeed
		wander()
		wandering = false
	end

	task.wait(0.1)
end