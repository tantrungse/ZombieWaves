-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Variables --
local player = Players.LocalPlayer
local respawnEvent = ReplicatedStorage.GUI:WaitForChild("Respawn")
local cameraEvent = ReplicatedStorage.GUI:WaitForChild("RotateCamera")
local startingMenu = script.Parent

local storeFrame = startingMenu:WaitForChild("StoreFrame")
local blurImg = startingMenu:WaitForChild("ImageLabel")
local guiFadeValues = {}
local gameEnum = {"START_INTERMISSION", "INTERMISSION", "WAVE_IN_PROGRESS", "GAME_OVER", "WAITTING"}

-- buttons
local playButton = blurImg:WaitForChild("Play")
local storeButton = blurImg:WaitForChild("Store")
local spectateButton = blurImg:WaitForChild("Spectate")

-- debounces
local playDebounce = false
local storeDebounce = false
local spectateButton = false

-- function 
local function fade(guiElement, goal) 
	local tween = TweenService:Create(guiElement, TweenInfo.new(0.5), goal)
	tween:Play()
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