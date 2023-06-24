local self = {
	
	-- DAMAGE PROPERTIES
	Damage = 15,
	BodyPartMultipliers = {
		["Head"] = 2,
		["UpperTorso"] = 1.3,
		["LowerTorso"] = 1.1,
		["LeftFoot"] = 0.3,
		["RightFoot"] = 0.3,
		["LeftLowerLeg"] = 0.65,
		["RightLowerLeg"] = 0.65,
		["LeftUpperLeg"] = 0.85,
		["RightUpperLeg"] = 0.85,
		["LeftHand"] = 0.3,
		["RightHand"] = 0.3,
		["LeftLowerArm"] = 0.5,
		["RightLowerArm"] = 0.5,
		["LeftUpperArm"] = 0.6,
		["RightUpperArm"] = 0.6,
		["HumanoidRootPart"] = 1
	},
	
	-- GUN PROPERTIES
	Automatic = false, -- does gun keep shooting when mouse is held down?
	MaxBulletDistance = 500, -- how far bullets travel in studs
	ReloadDuration = 2, -- how many seconds the reload animation will last
	FireRate = 200, -- how many rounds per minute
	MaxReserveAmmo = 60, -- how much ammo the player can carry in reserve
	MaxMagAmmo = 12, -- how much ammo can be stored in a magazine
	
	-- BULLET HOLE PROPERTIES
	BulletHoleSize = Vector3.new(0.3,0.3,0.001), -- change X, Y size to change bullet hole size
	BulletHoleParticleAmount = 4, -- how many particles will come out of our particle emitter

	-- ANIMS
	
	-- NOTE! CHANGE THESE ANIMATIONS TO YOUR UPLOADED ANIMATION IDs!!!
	Animations = {
		AnimEquip = "rbxassetid://13812279677",
		AnimReload = "rbxassetid://13812264290",
		AnimShoot = "rbxassetid://13812285229"},
	-- MISC PROPERTIES
	MuzzleFlashProperties = {["Brightness"] = 5, ["Color"] = Color3.fromRGB(255, 199, 88), ["Range"] = 4, ["Shadows"] = true},
	
	-- SOUNDS
	-- rbxassetid://1153275576 good sound for a dmr style rifle
	ShootSoundProperties = {["SoundId"] = "rbxassetid://799960407", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 65, 
		["RollOffMinDistance"] = 25, ["Volume"] = 1},
	ReloadSoundProperties = {["SoundId"] = "rbxassetid://6523977613", ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 0.6},
	GunClickSoundProperties = {["SoundId"] = "rbxassetid://9116544314",  ["RollOffMode"] = Enum.RollOffMode.InverseTapered, ["RollOffMaxDistance"] = 25, 
		["RollOffMinDistance"] = 15, ["Volume"] = 1.5},
	HitmarkerSoundProperties = {["SoundId"] = "rbxassetid://160432334", ["Volume"] = 0.25}
}


return self