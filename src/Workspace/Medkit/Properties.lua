self = {
	
	HealingAmount = 40, -- how much to heal by,
	
	OneUse = true, -- if it's one use or not
	HealingCooldown = 1, -- if not one use, set a cooldown time between heals
	
	-- ANIMATIONS
	-- change the IDs to your own animations!
	EquipAnimation = "rbxassetid://13846328399",
	HealingAnimation = "rbxassetid://13846790864",
	AnimationDuration = 4, -- duration for healing animation
	
	HealingSoundProperties = {["SoundId"] = "rbxassetid://444675291", ["RollOffMaxDistance"] = 35, 
		["RollOffMinDistance"] = 15, ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["Volume"] = 0.2, ["TimePosition"] = 0.8}
	
}

return self