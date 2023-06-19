-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables --
local cameraEvent = ReplicatedStorage:WaitForChild("GUI"):WaitForChild("RotateCamera")

local camera = workspace.CurrentCamera
local cameraPart = workspace:WaitForChild("FilteringFolder"):WaitForChild("Invis"):WaitForChild("CameraPart")

camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = cameraPart.CFrame

-- Function --
local function rotateCamera()
    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame *= CFrame.Angles(0, math.rad(camera.CFrame.Rotation.Y) - 0.002, 0)
end

-- Event handlers --
local cameraFunction = RunService.Heartbeat:Connect(rotateCamera)

cameraEvent.Event:Connect(function(bool)
    if bool then
        if cameraFunction then cameraFunction:Disconnect() end
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = cameraPart.CFrame
        cameraFunction = RunService.Heartbeat:Connect(rotateCamera)
    else
        cameraFunction:Disconnect()
        camera.CameraType = Enum.CameraType.Custom
    end
end)