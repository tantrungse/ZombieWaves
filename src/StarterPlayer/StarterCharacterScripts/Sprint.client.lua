-- Services --
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables --
local camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid") :: Humanoid

local gui = player.PlayerGui:WaitForChild("StaminaGui")

local currentStamina = 100
local origFov = camera.FieldOfView

-- Constants --
local SPRINT_SPEED = 20
local DEFAULT_SPEED = humanoid.WalkSpeed
local MAX_STAMINA = 100
local STAMINA_REDUCE = 0.55 -- 0.55*60 = 33 -> reduce 33 per second
local STAMINA_INCREASE = 0.2
local SPRINT_FOV = 85
local SPRINT_COOLDOWN = 5

-- Debounces --
local shiftDown = false
local sprintingCooldown = false
local canReplenishStamina = true

-- Functions --
local function updateStaminaBar()
    if not gui.Enabled then
        gui.Enabled = true
        local tween1 = TweenService:Create(gui.Border.Outline, TweenInfo.new(0.3), {["Transparency"] = 0})
        local tween2 = TweenService:Create(gui.Border.Fill, TweenInfo.new(0.3), {["Transparency"] = 0})
        tween1:Play()
        tween2:Play()
    end

    gui.Border.Fill.Size = UDim2.new(1, 0, currentStamina/MAX_STAMINA, 0)

    if gui.Border.Fill.Size.Y.Scale >= 1 and gui.Border.Outline.Transparency <= 0 then
        local tween1 = TweenService:Create(gui.Border.Outline, TweenInfo.new(0.3), {["Transparency"] = 1})
        local tween2 = TweenService:Create(gui.Border.Fill, TweenInfo.new(0.3), {["Transparency"] = 1})
        tween1:Play()
        tween2:Play()
        tween2.Completed:Wait()
        gui.Enabled = false
    end
end
-- Handlers --
UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        if currentStamina <= 0 then return end
        shiftDown = true
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.LeftShift then
        shiftDown = false
    end
end)

RunService.Heartbeat:Connect(function()
    if shiftDown and currentStamina >= 0 and humanoid.MoveDirection.Magnitude > 0 then
        if camera.FieldOfView ~= SPRINT_FOV then
            local cameraTween = TweenService:Create(camera, TweenInfo.new(0.8), {["FieldOfView"] = SPRINT_FOV})
            cameraTween:Play()
        end
        humanoid.WalkSpeed = SPRINT_SPEED
        currentStamina -= STAMINA_REDUCE
    else
        if camera.FieldOfView ~= origFov then
            local cameraTween = TweenService:Create(camera, TweenInfo.new(0.8), {["FieldOfView"] = origFov})
            cameraTween:Play()
        end
        humanoid.WalkSpeed = DEFAULT_SPEED
        if currentStamina <= 0 then
            currentStamina = 0
            if sprintingCooldown then return end
            sprintingCooldown = true
            canReplenishStamina = false
            shiftDown = false
            task.wait(SPRINT_COOLDOWN)
            canReplenishStamina = true
        end
    end

    if currentStamina < MAX_STAMINA then
        if not canReplenishStamina then return end

        if not shiftDown or humanoid.MoveDirection.Magnitude <= 0 then
            currentStamina += STAMINA_INCREASE
            sprintingCooldown = false
        end
        updateStaminaBar()
    end
end)