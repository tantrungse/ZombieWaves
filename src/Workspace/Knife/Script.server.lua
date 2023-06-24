-- Services --
local Players = game:GetService("Players")

-- Variables --
local tool = script.Parent
local touchPart = tool.Touch
local swungEvent = tool.Script.Swung
local properties = require(tool.Properties)

local timeSinceLastSwung = 0
local rng = Random.new()
local touchConnection = nil

-- Debounces --
local swinging = false
local touchDebounce = false

-- Functions --
local function createPitchShift(parent, value)
    local pitchShift = Instance.new("PitchShiftSoundEffect")
    pitchShift.Octave = value
    pitchShift.Parent = parent
    return pitchShift
end

local function createSound(parent, soundProperties, ID)
    local sound = Instance.new("Sound")
    for property,value in pairs(soundProperties) do
        sound[property] = value
    end
    sound.SoundId = ID
    sound.Parent = parent
    return sound
end

local function onTouched(otherPart, player)
    if not swinging then return end
    if touchDebounce then return end
    local humanoid = otherPart.Parent:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end
    if Players:GetPlayerFromCharacter(otherPart.Parent) then return end
    touchDebounce = true

    local hitSound = createSound(tool.Handle, properties.SoundProperties, properties.HitSoundID)
    createPitchShift(hitSound, rng:NextNumber(properties.PitchShiftOctaves.Min, properties.PitchShiftOctaves.Max))
    hitSound:Play()
    hitSound.Ended:Connect(function()
        hitSound:Destroy()
    end)

    local criticalHitChance = properties.CriticalHitChance * 100
    local dmg = properties.Damage

    if rng:NextInteger(1, 100) <= criticalHitChance then
        dmg *= rng:NextNumber(properties.CriticalHitMultiplier.Min, properties.CriticalHitMultiplier.Max)
    end
    humanoid:TakeDamage(dmg)

    if humanoid.Parent:FindFirstChild("WhoLastDamaged") then
        humanoid.Parent.WhoLastDamaged.Value = player
    end
end

-- Handlers --
swungEvent.OnServerEvent:Connect(function(player)
    if swinging then return end
    if player.Name ~= tool.Parent.Name then return end

    if DateTime.now().UnixTimestampMillis - timeSinceLastSwung < properties.SwingCooldown * 1000 then return end
    timeSinceLastSwung = DateTime.now().UnixTimestampMillis
    swinging = true

    local swingSound = createSound(tool.Handle, properties.SoundProperties, properties.SwingSoundID)
    createPitchShift(swingSound, rng:NextNumber(properties.PitchShiftOctaves.Min, properties.PitchShiftOctaves.Max))
    swingSound:Play()
    swingSound.Ended:Connect(function()
        swingSound:Destroy()
    end)

    touchConnection = touchPart.Touched:Connect(function(otherPart)
        onTouched(otherPart, player)
    end)

    task.delay(properties.AnimationDuration, function()
        touchConnection:Disconnect()
    end)
    task.wait(properties.SwingCooldown + properties.AnimationDuration)

    swinging = false
    touchDebounce = false
end)