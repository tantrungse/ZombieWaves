local self = {
	
	-- DAMAGE PROPERTIES
	Damage = 10,
	BodyPartMultipliers = {
		["Head"] = 2.5,
		["UpperTorso"] = 1.5,
		["LowerTorso"] = 1.3,
		["LeftFoot"] = 0.2,
		["RightFoot"] = 0.2,
		["LeftLowerLeg"] = 0.5,
		["RightLowerLeg"] = 0.5,
		["LeftUpperLeg"] = 0.75,
		["RightUpperLeg"] = 0.75,
		["LeftHand"] = 0.2,
		["RightHand"] = 0.2,
		["LeftLowerArm"] = 0.4,
		["RightLowerArm"] = 0.4,
		["LeftUpperArm"] = 0.65,
		["RightUpperArm"] = 0.65,
		["HumanoidRootPart"] = 1.3
	},
	
	-- GUN PROPERTIES
	Automatic = false, -- does gun keep shooting when mouse is held down?
	MaxBulletDistance = 500, -- how far bullets travel in studs
	ReloadDuration = 4, -- how many seconds the reload animation will last
	FireRate = 100, -- how many rounds per minute
	MaxReserveAmmo = 35, -- how much ammo the player can carry in reserve
	MaxMagAmmo = 7, -- how much ammo can be stored in a magazine
	
	-- SHOTGUN PROPERTIES
	RoundType = "Buckshot", -- if set to "Slug" then the rounds wont be randomly shot out
	TotalPellets = 8, -- how many pellets in a shotgun round
	MaxSpread = 4, -- how severe the spread is in degrees
	
	-- BULLET HOLE PROPERTIES
	BulletHoleSize = Vector3.new(0.2,0.2,0.001), -- change X, Y size to change bullet hole size
	BulletHoleParticleAmount = 5, -- how many particles will come out of our particle emitter
	
	-- ANIMS
	
	-- NOTE! CHANGE THESE ANIMATIONS TO YOUR UPLOADED ANIMATION IDs!!!
	Animations = {
		AnimEquip = "rbxassetid://13812333252",
		AnimReload = "rbxassetid://13812335788",
		AnimShoot = "rbxassetid://13812330247"},
	-- MISC PROPERTIES
	MuzzleFlashProperties = {["Brightness"] = 8, ["Color"] = Color3.fromRGB(255, 199, 88), ["Range"] = 6, ["Shadows"] = true},
	
	-- SOUNDS
	ShootSoundProperties = {["SoundId"] = "rbxassetid://5686379468", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 65, 
		["RollOffMinDistance"] = 25, ["Volume"] = 1},
	ReloadSoundProperties = {["SoundId"] = "rbxassetid://6523977613", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 0.6},
	GunClickSoundProperties = {["SoundId"] = "rbxassetid://9116544314",  ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 1.5},
	ShotgunPumpSoundProperties = {["SoundId"] = "rbxassetid://3603402053", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 1},
}

return self