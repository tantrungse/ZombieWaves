-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local buyEvent = ReplicatedStorage.GUI.BuyItem

-- Gui --
local gui = script.Parent
local frame = gui.BackgroundFrame
local closeButton = frame.CloseButton
local shopFrame = frame.ShopFrame

-- Functions --
local function onButtonClick(nameOfItem)
   buyEvent:FireServer(nameOfItem)
end

for _,button in ipairs(shopFrame:GetDescendants()) do
    if button:IsA("TextButton") then
        button.MouseButton1Click:Connect(function()
            onButtonClick(button.Name)
        end)
    end
end

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)