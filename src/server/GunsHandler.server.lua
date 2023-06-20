-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Variables --
local gunEvent = ReplicatedStorage.Remotes.GunEvent

local timeSinceLastShot = {}
local whoIsReloading = {}

-- Constants --
local MAX_DISCREPANCY_DIST = 10

-- Functions --
local function createSound(parent, soundProperties)
	local sound = Instance.new("Sound")
	for property,value in pairs(soundProperties) do
		sound[property] = value
	end
	sound.Parent = parent
	return sound
end

local function createMuzzleFlash(parent, lightProperties)
	local light = Instance.new("PointLight")
	for property,value in pairs(lightProperties) do
		light[property] = value
	end
	light.Parent = parent
	light.Enabled = true
	return light
end

local function checkBulletRay(properties, result)
	if not result then return end
	
	local character = result.Instance.Parent
	if not character:FindFirstChildWhichIsA("Humanoid") or Players:GetPlayerFromCharacter(character) then return end
	
	local offset = (result.Position - result.InstanceOriginPosition)
	local serverCFrameOffset = CFrame.new(result.Instance.Position) * CFrame.new(offset)
	
	if (result.Position - serverCFrameOffset.Position).Magnitude > MAX_DISCREPANCY_DIST then return end
	
	character.Humanoid:TakeDamage(properties.Damage * properties.BodyPartMultipliers[result.Instance.Name])
end

local function reload(player, gun, properties)
	local ammoInMag = gun:GetAttribute("AmmoInMag")
	local ammoReserve = gun:GetAttribute("AmmoReserve")
	if ammoInMag == properties.MaxMagAmmo then return end
	if ammoReserve <= 0 then return end

	if (DateTime.now().UnixTimestampMillis - timeSinceLastShot[player.Name][gun.Name]) < properties.ReloadDuration then return end
	if not whoIsReloading[player.Name] then
		whoIsReloading[player.Name] = {[gun.Name] = true}
	else
		if whoIsReloading[player.Name][gun.Name] then return end
	end
	whoIsReloading[player.Name][gun.Name] = true

	local ammoNeeded = math.min(properties.MaxMagAmmo - ammoInMag, ammoReserve)

	gun:SetAttribute("AmmoInMag", ammoInMag + ammoNeeded)
	gun:SetAttribute("AmmoReserve", ammoReserve - ammoNeeded)

	whoIsReloading[player.Name][gun.Name] = false
end

local function shoot(player: Player, gun : Tool, properties, result)
	if gun:GetAttribute("AmmoInMag") == 0 then return end
	
	if not timeSinceLastShot[player.Name] then
		timeSinceLastShot[player.Name] = {[gun.Name] = 0, ["PelletCount"] = 1}
	end
	if not timeSinceLastShot[player.Name][gun.Name] then
		timeSinceLastShot[player.Name][gun.Name] = 0
	end
	
	if gun:GetAttribute("GunType") == "Spread" then
		if DateTime.now().UnixTimestampMillis - timeSinceLastShot[player.Name][gun.Name] < 60/properties.FireRate then
			return
		else
			timeSinceLastShot[player.Name]["PelletCount"] += 1
		end
		
		if timeSinceLastShot[player.Name]["PelletCount"] >= properties.TotalPellets then
			timeSinceLastShot[player.Name][gun.Name] = DateTime.now().UnixTimestampMillis
			timeSinceLastShot[player.Name]["PelletCount"] = 0
			
			gun:SetAttribute("AmmoInMag", gun:GetAttribute("AmmoInMag") - 1)
			local light = createMuzzleFlash(gun.Handle.Muzzle, properties.MuzzleFlashProperties)
			task.spawn(function()
				task.wait(0.15)
				light:Destroy()
			end)
			gun.Handle.Muzzle.Flash:Emit(1)
			
			local sound = createSound(gun.Handle.Muzzle, properties.ShootSoundProperties)
			sound:Play()
			sound.Ended:Connect(function() sound:Destroy() end)
			
			checkBulletRay(properties, result)
		else
			checkBulletRay(properties, result)
		end
	elseif gun:GetAttribute("GunType") == "Standard" then
		if DateTime.now().UnixTimestampMillis - timeSinceLastShot[player.Name][gun.Name] < 60/properties.FireRate then return end
		timeSinceLastShot[player.Name][gun.Name] = DateTime.now().UnixTimestampMillis

		gun:SetAttribute("AmmoInMag", gun:GetAttribute("AmmoInMag") - 1)
			local light = createMuzzleFlash(gun.Handle.Muzzle, properties.MuzzleFlashProperties)
			task.spawn(function()
				task.wait(0.15)
				light:Destroy()
			end)
			gun.Handle.Muzzle.Flash:Emit(1)
			
			local sound = createSound(gun.Handle.Muzzle, properties.ShootSoundProperties)
			sound:Play()
			sound.Ended:Connect(function() sound:Destroy() end)
			
			checkBulletRay(properties, result)
	end
end

-- Event handler --
gunEvent.OnServerEvent:Connect(function(player : Player, action, ...)
	if not player.Character then return end
	local gun = player.Character:FindFirstChildWhichIsA("Tool")
	if not gun:GetAttribute("GunType") then return end
	local properties = require(gun.Properties)
	
	if action == "ValidateShot" then
		local args = {...}
		if args[1] and args[2] and args[3] and args[4] then
			args = {["Instance"] = args[1], ["Position"] = args[2], ["Normal"] = args[3], ["InstanceOriginPosition"] = args[4]}
		else 
			args = nil
		end
		shoot(player, gun, properties, args)
	elseif action == "ValidateReload" then
		reload(player, gun, properties)
	end
end)