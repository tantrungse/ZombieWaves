-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables --
local ammoBoxes = workspace.AmmoBoxes:GetChildren()
local refillSound = ReplicatedStorage.Audio.CollectAmmo

-- Functions --
local function onTriggered(player, ammoBox)
    local gun = player.Character:FindFirstChildWhichIsA("Tool")

    if not gun then return end
    if not gun:GetAttribute("GunType") then return end
    local properties = require(gun.Properties)
    if gun:GetAttribute("AmmoReserve") == properties.MaxReserveAmmo then return end

    local ammoNeeded = math.min(properties.MaxReserveAmmo - gun:GetAttribute("AmmoReserve"), ammoBox:GetAttribute("CurrentAmmo"))
    gun:SetAttribute("AmmoReserve", gun:GetAttribute("AmmoReserve") + ammoNeeded)
    ammoBox:SetAttribute("CurrentAmmo", ammoBox:GetAttribute("CurrentAmmo") - ammoNeeded)
    -- play collection sound
    local clone = refillSound:Clone()
    clone.Parent = ammoBox
    clone:Play()
    clone.Ended:Wait()
    clone:Destroy()
end

local function changeText(element, text)
    element.Text = text
end

local function onAttributeChange(ammoBox, name)
    if name == "CurrentAmmo" then
        changeText(ammoBox.Attachment.BillboardGui.TextLabel, "CURRENT AMMO: "..ammoBox:GetAttribute("CurrentAmmo"))
        if ammoBox:GetAttribute("CurrentAmmo") == 0 then
            ammoBox.Attachment.ProximityPrompt.Enabled = false
            task.wait(ammoBox:GetAttribute("RefillCooldown"))
            ammoBox:SetAttribute("CurrentAmmo", ammoBox:GetAttribute("MaxAmmo"))
        else
            ammoBox.Attachment.ProximityPrompt.Enabled = true
        end
    end
end

-- Handler --
for _,ammoBox in ipairs(ammoBoxes) do
    ammoBox.Attachment.ProximityPrompt.Triggered:Connect(function(player)
        onTriggered(player, ammoBox)
    end)
    ammoBox.AttributeChanged:Connect(function(name)
        onAttributeChange(ammoBox, name)
    end)
    changeText(ammoBox.Attachment.BillboardGui.TextLabel, "CURRENT AMMO: "..ammoBox:GetAttribute("CurrentAmmo"))
end