local self = {
	
	BaseDamage = 200,
	TimeUntilExplosion = 3, -- how long to wait before exploding
	LifetimeAfterExplosion = 5, -- how long to wait before deleting the grenade after explosion, ideally, this number should be greater than the lifespan of the smoke particles
	DamageRanges = {
		-- min is inclusive, max is not, meaning if the distance was 3, damage multiplier would be 2 and not 3
		{Min = 0, Max = 3, Multiplier = 3},
		{Min = 3, Max = 5, Multiplier = 2},
		{Min = 5, Max = 7, Multiplier = 1.5},
		{Min = 7, Max = 9, Multiplier = 1},
		{Min = 9, Max = 13, Multiplier = 0.9},
		{Min = 13, Max = 17, Multiplier = 0.7},
		{Min = 17, Max = 20, Multiplier = 0.5},
	},
	
	ExplosionProperties = {
		["BlastPressure"] = 30000, -- how much force is exerted by the blast on unanchored parts
		["BlastRadius"] = 20, -- make sure to update damage distance multipliers if this is changed
		["DestroyJointRadiusPercent"] = 0, -- do not destroy joints as it'll insta kill the zombie
		["ExplosionType"] = Enum.ExplosionType.NoCraters, -- if the explosion creates a crater in terrain
		["Visible"] = false, -- do not show regular explosion effect
	},
	
	ExplosionParticleAmount = 100,
	SmokeParticleAmount = 100,
	
	-- add your own equip and throwing animations..?
}

return self