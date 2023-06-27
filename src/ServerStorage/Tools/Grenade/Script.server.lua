-- Services --
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

-- Variables --
local tool = script.Parent
local properties = require(tool.Properties)

-- Functions --
local function createExplosion(explosionProperties)
    local explosion = Instance.new("Explosion")
    for property,value in pairs(explosionProperties) do
        explosion[property] = value
    end
    return explosion
end

local function numInRange(num, min, max)
    if num >= min and num < max then return true end
    return false
end

local function getDamage(distance)
    for _,range in ipairs(properties.DamageRanges) do
        if numInRange(distance, range.Min, range.Max) then
            return properties.BaseDamage * range.Multiplier
        end
    end
end

-- Event handlers --
tool.Activated:Connect(function()
    if tool:GetAttribute("GrenadesLeft") == 0 then return end
    tool:SetAttribute("GrenadesLeft", tool:GetAttribute("GrenadesLeft") - 1)
    local character = tool.Parent
    local player = Players:GetPlayerFromCharacter(character)
    local grenadeClone = tool.Handle:Clone()

    grenadeClone.CanCollide = true
    grenadeClone.Parent = workspace
    grenadeClone.Position = character.HumanoidRootPart.Position + (character.HumanoidRootPart.CFrame.LookVector * 2)
    grenadeClone.AssemblyLinearVelocity = (character.HumanoidRootPart.CFrame.LookVector * 25) + Vector3.new(0, 55, 0)

    task.wait(properties.TimeUntilExplosion)

    local explosion = createExplosion(properties.ExplosionProperties)
    explosion.Hit:Connect(function(hitPart, distance)
        if hitPart.Name ~= "HumanoidRootPart" then return end
        local humanoid = hitPart.Parent:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        if Players:GetPlayerFromCharacter(hitPart.Parent) then return end

        local damage = getDamage(distance)
        humanoid:TakeDamage(damage)
        if hitPart.Parent:FindFirstChild("WhoLastDamaged") then
            hitPart.Parent.WhoLastDamaged.Value = player
        end
    end)
    explosion.Position = grenadeClone.Position
    grenadeClone.Anchored = true
    explosion.Parent = grenadeClone -- our grenade explodes

    grenadeClone.Transparency = 1
    grenadeClone.ExplosionEmitter:Emit(properties.ExplosionParticleAmount)
    grenadeClone.SmokeEmitter:Emit(properties.SmokeParticleAmount)
    grenadeClone.ExplosionSound:Play()
    Debris:AddItem(grenadeClone, properties.LifetimeAfterExplosion)
end)

tool.AttributeChanged:Connect(function(name)
    if name == "GrenadesLeft" then
        tool.Name = "Grenade ("..tool:GetAttribute(name)..")"
    end
    if tool:GetAttribute("GrenadesLeft") == 0 then
        tool.Handle.Transparency = 1
    else
        tool.Handle.Transparency = 0
    end
end)

tool.Name = "Grenade ("..tool:GetAttribute("GrenadesLeft")..")"