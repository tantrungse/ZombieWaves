local self = {
	
	-- DAMAGE PROPERTIES
	Damage = 20,
	BodyPartMultipliers = {
		["Head"] = 2,
		["UpperTorso"] = 1,
		["LowerTorso"] = 1,
		["LeftFoot"] = 0.15,
		["RightFoot"] = 0.15,
		["LeftLowerLeg"] = 0.4,
		["RightLowerLeg"] = 0.4,
		["LeftUpperLeg"] = 0.6,
		["RightUpperLeg"] = 0.6,
		["LeftHand"] = 0.1,
		["RightHand"] = 0.1,
		["LeftLowerArm"] = 0.2,
		["RightLowerArm"] = 0.2,
		["LeftUpperArm"] = 0.4,
		["RightUpperArm"] = 0.4,
		["HumanoidRootPart"] = 1
	},
	
	-- GUN PROPERTIES
	Automatic = true, -- does gun keep shooting when mouse is held down?
	MaxBulletDistance = 500, -- how far bullets travel in studs
	ReloadDuration = 3, -- how many seconds the reload animation will last
	FireRate = 350, -- how many rounds per minute
	MaxReserveAmmo = 100, -- how much ammo the player can carry in reserve
	MaxMagAmmo = 20, -- how much ammo can be stored in a magazine
	
	-- BULLET HOLE PROPERTIES
	BulletHoleSize = Vector3.new(0.5,0.5,0.001), -- change X, Y size to change bullet hole size
	BulletHoleParticleAmount = 8, -- how many particles will come out of our particle emitter
	 
	-- ANIMS
	
	-- NOTE! CHANGE THESE ANIMATIONS TO YOUR UPLOADED ANIMATION IDs!!!
	Animations = {
		AnimEquip = "rbxassetid://13812303296",
		AnimReload = "rbxassetid://13812309867",
		AnimShoot = "rbxassetid://13812306879"},
	-- MISC PROPERTIES
	MuzzleFlashProperties = {["Brightness"] = 8, ["Color"] = Color3.fromRGB(255, 199, 88), ["Range"] = 5, ["Shadows"] = true},
	
	-- SOUNDS
	ShootSoundProperties = {["SoundId"] = "rbxassetid://801128774", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 65, 
		["RollOffMinDistance"] = 25, ["Volume"] = 1},
	ReloadSoundProperties = {["SoundId"] = "rbxassetid://6523977613", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 0.6},
	GunClickSoundProperties = {["SoundId"] = "rbxassetid://9116544314",  ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 1.5},
}

return self