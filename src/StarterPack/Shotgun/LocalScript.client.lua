-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

-- Variables --
local player = Players.LocalPlayer
local gun = script.Parent
local mouse = player:GetMouse()
mouse.TargetFilter = workspace:WaitForChild("FilteringFolder")
local origMouseIcon = "rbxasset://SystemCursors/Arrow"
local properties = require(gun:WaitForChild("Properties"))

-- Animations
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator

local animInstance = Instance.new("Animation")
animInstance.AnimationId = properties.Animations.AnimEquip
local equipTrack = animator:LoadAnimation(animInstance)
animInstance.AnimationId = properties.Animations.AnimShoot
local shootTrack = animator:LoadAnimation(animInstance)
animInstance.AnimationId = properties.Animations.AnimReload
local reloadTrack = animator:LoadAnimation(animInstance)

local gui = gun:WaitForChild("GunGUI")

-- Params --
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude

local UISConnection1 = nil
local UISConnection2 = nil

-- Event
local gunEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GunEvent")


-- Debounces
local shotCooldown = 60/properties.FireRate
local mouseButtonDown = false
local reloading = false
local shooting = false

-- Functions --
local function updateText(element, text)
	element.Text = text
end
updateText(gui:WaitForChild("Frame"):WaitForChild("MagAmmoText"), "  "..gun:GetAttribute("AmmoInMag"))
updateText(gui.Frame:WaitForChild("ReserveAmmoText"), "/ "..gun:GetAttribute("AmmoReserve"))

local function createSound(parent, soundProperties)
	local sound = Instance.new("Sound")
	for property,value in pairs(soundProperties) do
		sound[property] = value
	end
	sound.Parent = parent
	return sound
end

local function createHitmarker(result)
	if not result then return end
	if result.Instance.Parent:FindFirstChildWhichIsA("Humanoid") 
	and not Players:GetPlayerFromCharacter(result.Instance.Parent) then
		local sound = createSound(game:GetService("SoundService"), properties.HitmarkerSoundProperties)
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
		gui.Hitmarker.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
		if result.Instance.Name == "Head" then
			gui.Hitmarker.ImageColor3 = Color3.fromRGB(255, 119, 119)
		end
		task.spawn(function()
			gui.Hitmarker.Visible = true
			task.wait(0.08)
			gui.Hitmarker.Visible = false
			gui.Hitmarker.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end)
	end
end

local function reload()
	if gun:GetAttribute("AmmoInMag") == properties.MaxMagAmmo or gun:GetAttribute("AmmoReserve") == 0 then return end
	if reloading then return end
	reloading = true
	updateText(gui.Frame.MagAmmoText, "RELOADING")
	reloadTrack:Play()
	reloadTrack:AdjustSpeed(1/properties.ReloadDuration)
	local sound = createSound(gun.Handle, properties.ReloadSoundProperties)
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
	reloadTrack.Ended:Wait()
	if reloading then
		gunEvent:FireServer("ValidateReload")
		reloading = false
	else
		updateText(gui.Frame.MagAmmoText, "  "..gun:GetAttribute("AmmoInMag"))
	end
end

local function shoot()
	params.FilterDescendantsInstances = {player.Character, workspace.FilteringFolder}
	local shotDirection = (mouse.Hit.Position - gun.Handle.Muzzle.WorldCFrame.Position).Unit
	
	if gun:GetAttribute("GunType") == "Standard" then
		local result = workspace:Raycast(gun.Handle.Muzzle.WorldCFrame.Position, shotDirection*properties.MaxBulletDistance, params)
		if result then
			gunEvent:FireServer("ValidateShot", result.Instance, result.Position, result.Normal, result.Instance.Position)
		else 
			gunEvent:FireServer("ValidateShot")
		end
		createHitmarker(result)
	elseif gun:GetAttribute("GunType") == "Spread" then
		local allPellets = {}
		for i = 1, properties.TotalPellets do
			if properties.RoundType ~= "Slug" then
				shotDirection = (CFrame.lookAt(gun.Handle.Muzzle.WorldCFrame.Position, mouse.Hit.Position) *
					CFrame.Angles(math.rad(Random.new():NextNumber(-properties.MaxSpread, properties.MaxSpread)), 
						math.rad(Random.new():NextNumber(-properties.MaxSpread, properties.MaxSpread)), 0)).LookVector
			end
			
			local result = workspace:Raycast(gun.Handle.Muzzle.WorldCFrame.Position, shotDirection*properties.MaxBulletDistance, params)
			if result then
				result = {["Instance"] = result.Instance, ["Position"] = result.Position, ["Normal"] = result.Normal, ["InstanceOriginPosition"] = result.Instance.Position}
				table.insert(allPellets, result)	
			end
		end
		gunEvent:FireServer("ValidateShot", allPellets)
		local bodyShots = {}
		for _,result in ipairs(allPellets) do
			if result.Instance.Name == "Head" then
				createHitmarker(result)
				bodyShots = {}
				break
			elseif result.Instance.Parent:FindFirstChildWhichIsA("Humanoid") then
				table.insert(bodyShots, result)
			end
		end
		if #bodyShots > 0 then
			createHitmarker(bodyShots[1])
		end
	end
	shootTrack:Play()
end

-- Event handlers --
gun.Equipped:Connect(function()
	equipTrack:Play()
	gui.Parent = player.PlayerGui
	mouse.Icon = "rbxassetid://11839767092"
	
	UISConnection1 = UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if mouseButtonDown then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if shooting then return end
			if reloading then return end
			if gun:GetAttribute("AmmoInMag") == 0 then
				local sound = createSound(gun.Handle, properties.GunClickSoundProperties)
				sound:Play()
				sound.Ended:Wait()
				sound:Destroy()
				return 
			end
			shooting = true
			
			if properties.Automatic then
				mouseButtonDown = true
				while mouseButtonDown do
					shoot()
					task.wait(shotCooldown)
					if gun:GetAttribute("AmmoInMag") <= 0 then mouseButtonDown = false end
				end
			else
				shoot()
				task.wait(shotCooldown)
			end
			shooting = false
		elseif input.KeyCode == Enum.KeyCode.R then
			reload()
		end
	end)
	
	UISConnection2 = UIS.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mouseButtonDown = false
		end
	end)
end)

gun.Unequipped:Connect(function()
	mouse.Icon = origMouseIcon
	gui.Parent = gun
	equipTrack:Stop()
	reloadTrack:Stop()
	shootTrack:Stop()
	
	mouseButtonDown = false
	shooting = false
	reloading = false
	UISConnection1:Disconnect()
	UISConnection2:Disconnect()
end)

gun.AttributeChanged:Connect(function(name)
	if name == "AmmoInMag" then
		updateText(gui.Frame.MagAmmoText, "  "..gun:GetAttribute("AmmoInMag"))
	elseif name == "AmmoReserve" then
		updateText(gui.Frame.ReserveAmmoText, "/ "..gun:GetAttribute("AmmoReserve"))
	end
end)

if gun:GetAttribute("GunType") == "Spread" then
	shootTrack:GetMarkerReachedSignal("Pump"):Connect(function()
		local sound = createSound(gun.Handle.Muzzle, properties.ShotgunPumpSoundProperties)
		sound:Play()
		sound.Ended:Wait()
		sound:Destroy()
	end)
end