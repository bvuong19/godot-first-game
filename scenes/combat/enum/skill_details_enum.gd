class_name CombatSkillDetail

# targeting type
# none, self, ally, enemy, any, ally_range, enemy_range, global
enum TARGET_TYPE {
	NONE,
	SELF,
	ALLY,
	ENEMY,
	ANY,
	ALLY_RANGE,
	ENEMY_RANGE,
	GLOBAL
}

# effect type
# instant, lingering, delayed, other
enum EFFECT_TYPE { 
	INSTANT,
	LINGERING,
	DELAYED,
	OTHER
}

enum COST_TYPE {
	NONE,
	MP,
	HP,
	TP
}
