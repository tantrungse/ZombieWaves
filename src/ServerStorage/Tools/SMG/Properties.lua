local self = {
	
	-- DAMAGE PROPERTIES
	Damage = 12,
	BodyPartMultipliers = {
		["Head"] = 2,
		["UpperTorso"] = 1.3,
		["LowerTorso"] = 1.1,
		["LeftFoot"] = 0.2,
		["RightFoot"] = 0.2,
		["LeftLowerLeg"] = 0.6,
		["RightLowerLeg"] = 0.6,
		["LeftUpperLeg"] = 0.8,
		["RightUpperLeg"] = 0.8,
		["LeftHand"] = 0.2,
		["RightHand"] = 0.2,
		["LeftLowerArm"] = 0.4,
		["RightLowerArm"] = 0.4,
		["LeftUpperArm"] = 0.5,
		["RightUpperArm"] = 0.5,
		["HumanoidRootPart"] = 1
	},
	
	-- GUN PROPERTIES
	Automatic = true, -- does gun keep shooting when mouse is held down?
	MaxBulletDistance = 500, -- how far bullets travel in studs
	ReloadDuration = 3, -- how many seconds the reload animation will last
	FireRate = 550, -- how many rounds per minute
	MaxReserveAmmo = 150, -- how much ammo the player can carry in reserve
	MaxMagAmmo = 30, -- how much ammo can be stored in a magazine
	
	-- BULLET HOLE PROPERTIES
	BulletHoleSize = Vector3.new(0.3,0.3,0.001), -- change X, Y size to change bullet hole size
	BulletHoleParticleAmount = 5, -- how many particles will come out of our particle emitter

	-- ANIMS
	
	-- NOTE! CHANGE THESE ANIMATIONS TO YOUR UPLOADED ANIMATION IDs!!!
	Animations = {
		AnimEquip = "rbxassetid://13812316479",
		AnimReload = "rbxassetid://13812323247",
		AnimShoot = "rbxassetid://13812320132"},
	-- MISC PROPERTIES
	MuzzleFlashProperties = {["Brightness"] = 5, ["Color"] = Color3.fromRGB(255, 199, 88), ["Range"] = 4, ["Shadows"] = true},

	-- SOUNDS
	ShootSoundProperties = {["SoundId"] = "rbxassetid://8231976490", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 65, 
		["RollOffMinDistance"] = 25, ["Volume"] = 1},
	ReloadSoundProperties = {["SoundId"] = "rbxassetid://6523977613", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 0.6},
	GunClickSoundProperties = {["SoundId"] = "rbxassetid://9116544314",  ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 1.5},
	HitmarkerSoundProperties = {["SoundId"] = "rbxassetid://160432334", ["Volume"] = 0.25}
}

return self