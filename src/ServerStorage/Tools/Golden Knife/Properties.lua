self = {
	
	Damage = 95,
	CriticalHitChance = 0.55, -- float representing percentage chance of getting a critical hit, smallest number can be 0.01
	CriticalHitMultiplier = {Min = 1.4, Max = 2.2}, -- how much to multiply the base damage by if critical hit
	SwingCooldown = 0, -- time to wait in between swings, if set to 0 it will wait only for the duration of the animation
	
	-- ANIMATIONS
	SwingAnimations = {"rbxassetid://13845196579", "rbxassetid://13845199365", "rbxassetid://13845202596"},
	EquipAnimation = "rbxassetid://13845192425",
	AnimationDuration = 0.25, -- how long the swing animation will last in seconds
	
	-- SOUNDS
	SwingSoundID = "rbxassetid://5792087636",
	HitSoundID = "rbxassetid://201858024",
	
	PitchShiftOctaves = {Min = 0.8, Max = 1.2}, -- randomly change the pitch of the swing/hit sound effects
	SoundProperties = {["RollOffMaxDistance"] = 40, ["RollOffMinDistance"] = 15, ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["Volume"] = 0.25},
	
}

return self