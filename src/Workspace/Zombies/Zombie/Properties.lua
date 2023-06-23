local self = {

	-- Zombie stats
	HumanoidStats = {
		MaxHealth = 200, -- max possible health
		Health = 200, -- starting health
		JumpPower = 50,
	},
	ChaseSpeed = 14, -- how fast the zombie walks when it sees a player
	WanderSpeed = 5, -- how fast the zombie walks when it's just wandering

	RegeneratesHealth = true, -- Should the zombie regenerate health?
	HealthRegenAmount = 5, -- how much health should regen
	HealthRegenTick = 1, -- how long to wait in seconds before healing again
	HealthRegenLimit = 0.5, -- decimal representing the percentage of MaxHealth will be healed to

	TargetingDistance = 75, -- the farthest away this zombie will track/find players
	AlertTargetingDistance = 95, -- the farthest away this zombie will track/find players after being shot
	RecalculatePathAfterDist = 20, -- how far the zombie path finds from the first waypoint until it decides to recalculate the path
	DamagePerHit = 10, -- self-explanatory
	CooldownBetweenAttack = 1.5, -- how many seconds to wait in between attacks
	AttackRange = 4, -- how many studs a player has to be within the zombie for it to attack and deal damage
	MaxVisibilityHeight = 8, --[[ how high in studs between where the player is and where the zombie is on the Y axis for the zombie 
	to attempt to move to its location, I wouldn't set this number too high or zombies could get stuck in place...
	Also wouldn't set it too small, else players jumping would cause the path finding to reset. Either keep this ~8 studs, or reduce player jump power!
	]]
	MoneyDrop = {Min = 5, Max = 10}, -- how much money (randomly) our zombie will give when killed

	-- Attack animations
	AttackAnimationIDs = {"rbxassetid://13833666917", "rbxassetid://13833682158"},

	-- AGENT PARAMETERS REQUIRED FOR PATH FINDING SERVICE
	AgentParams = {
		AgentRadius = 2, -- the minimum width separation between two parts that our zombie can walk through, the default diameter of an R15 is 4 studs, so the radius is 2
		AgentHeight = 5, -- the minimum height separation between two parts that our zombie can walk through, the default height of an R15 character is 5 studs
		AgentCanJump = true, -- can the zombie jump when path finding?
		AgentCanClimb = false, -- can the zombie climb truss parts when path finding?
		WaypointSpacing = 4, -- the distance in studs between waypoints, decrease number to become more detailed or increase number to become less detailed, default is 4
		Costs = {} -- a table that contains the names of certain materials and their costs to traverse over them, the higher the cost number, the less likely the AI will pathfind over that material
	},

	AttackSoundIDs = {"rbxassetid://131138828", "rbxassetid://131138832", "rbxassetid://131138835"},
	DeathSoundIDs = {"rbxassetid://131138839", "rbxassetid://131138845", "rbxassetid://131138848", "rbxassetid://131138850", "rbxassetid://131138854", "rbxassetid://131138860"},
	PlayerSeenSoundIDs = {"rbxassetid://131060145", "rbxassetid://131060194"},
	GrowlSoundIDs = {"rbxassetid://131060210", "rbxassetid://131060226", "rbxassetid://131060249"},

	SoundProperties = {["Volume"] = 0.5, ["RollOffMaxDistance"] = 45, ["RollOffMinDistance"] = 15, ["RollOffMode"] = Enum.RollOffMode.InverseTapered},
}

return self