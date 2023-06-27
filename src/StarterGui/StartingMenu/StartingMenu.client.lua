-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

-- Variables --
local player = Players.LocalPlayer
local respawnEvent = ReplicatedStorage.GUI:WaitForChild("Respawn")
local cameraEvent = ReplicatedStorage.GUI:WaitForChild("RotateCamera")
local startingMenu = script.Parent

local storeFrame = startingMenu:WaitForChild("StoreFrame")
local spectatingFrame = startingMenu:WaitForChild("SpectateFrame")
local shopFrame = startingMenu:WaitForChild("StoreFrame")
local blurImg = startingMenu:WaitForChild("ImageLabel")
local guiFadeValues = {}
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "WAITING"}

local buyEvent = ReplicatedStorage.GUI:WaitForChild("BuyGamepass")

-- spectating
local viewingPlayer = 1
local camera = workspace.CurrentCamera

-- buttons
local playButton = blurImg:WaitForChild("Play")
local shopButton = blurImg:WaitForChild("Store")
local spectateButton = blurImg:WaitForChild("Spectate")

-- debounces
local playDebounce = false
local spectateDebounce = false

-- function
local function fade(guiElement, goal) 
	local tween = TweenService:Create(guiElement, TweenInfo.new(0.5), goal)
	tween:Play()
end

local function getAlivePlayers()
	return Teams.Alive:GetPlayers()
end

local function onHumanoidDeath()
	fade(startingMenu.Black, {BackgroundTransparency = 0})
	fade(startingMenu.Black.TextLabel, {TextTransparency = 0})
	player.CharacterAdded:Wait()
	cameraEvent:Fire(true)
	blurImg.Visible = true
	fade(startingMenu.Black, {BackgroundTransparency = 1})
	fade(startingMenu.Black.TextLabel, {TextTransparency = 1})
end
-- event handler
if player.Character then
	player.Character:WaitForChild("Humanoid").Died:Connect(onHumanoidDeath)
end

player.CharacterAdded:Connect(function(character)
	character:WaitForChild("Humanoid").Died:Connect(onHumanoidDeath)
end)

playButton.MouseButton1Click:Connect(function()
	if playDebounce then return end
	playDebounce = true
	
	if workspace:GetAttribute("GameState") == gameEnum[1] or workspace:GetAttribute("GameState") == gameEnum[2] then 
		fade(startingMenu.Black, {BackgroundTransparency = 0})
		task.wait(1)
		respawnEvent:FireServer()
		cameraEvent:Fire(false)
		task.wait(1)
		blurImg.Visible = false
		fade(startingMenu.Black, {BackgroundTransparency = 1})
	else
		local origText = playButton.Text
		playButton.Text = "Game in progress! Please wait..."
		task.wait(3)
		playButton.Text = origText
	end
	
	playDebounce = false
end)

-- spectating
spectateButton.MouseButton1Click:Connect(function()
	if spectateDebounce then return end
	spectateDebounce = true

	local alivePlayers = getAlivePlayers()
	if #alivePlayers > 0 then
		viewingPlayer = 1
		spectatingFrame.Visible = true
		blurImg.Visible = false
		cameraEvent:Fire(false)
		camera.CameraSubject = alivePlayers[viewingPlayer].Character.Humanoid
		spectatingFrame.NameForPlayer.Text = alivePlayers[viewingPlayer].Name
	else
		local origText = spectateButton.Text
		spectateButton.Text = "No players to spectate!"
		task.wait(3)
		spectateButton = origText
	end

	spectateDebounce = false
end)

spectatingFrame.Stop.MouseButton1Click:Connect(function()
	spectatingFrame.Visible = false
	blurImg.Visible = true
	cameraEvent:Fire(true)
end)

spectatingFrame.Next.MouseButton1Click:Connect(function()
	viewingPlayer += 1
	local alivePlayers = getAlivePlayers()
	if #alivePlayers == 0 then return end
	if viewingPlayer > #alivePlayers then
		viewingPlayer = 1
	end
	camera.CameraSubject = alivePlayers[viewingPlayer].Character.Humanoid
	spectatingFrame.NameForPlayer.Text = alivePlayers[viewingPlayer].Name
end)

spectatingFrame.Previous.MouseButton1Click:Connect(function()
	viewingPlayer -= 1
	local alivePlayers = getAlivePlayers()
	if #alivePlayers == 0 then return end
	if viewingPlayer < 1 then
		viewingPlayer = #alivePlayers
	end
	camera.CameraSubject = alivePlayers[viewingPlayer].Character.Humanoid
	spectatingFrame.NameForPlayer.Text = alivePlayers[viewingPlayer].Name
end)

-- store system
shopButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = true
end)

shopFrame.CloseButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)

shopFrame:WaitForChild("FasterReload").Buy.MouseButton1Click:Connect(function()
	buyEvent:FireServer("FasterReload")
end)

shopFrame:WaitForChild("GoldenKnife").Buy.MouseButton1Click:Connect(function()
	buyEvent:FireServer("GoldenKnife")
end)