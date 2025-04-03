extends Resource
class_name CombatSkill

# what do combat skills need?
var skillName : String = "missingName"

# targeting type
# none, self, ally, enemy, ally_range, enemy_range, global
var targetType : CombatSkillDetail.TARGET_TYPE

# targeting range
# assumes ally_range or enemy_range type. create a bitmask array to represent the range
var targetRange : Array #SkillRange

# effect type
# instant, lingering, delayed, other
var effectType : CombatSkillDetail.EFFECT_TYPE

# effect - takes a lingering 
var apply_effect : Callable

func _init(skillName, targetType, targetRange, effectType, apply_effect):
	self.skillName = skillName
	self.targetType = targetType
	self.targetRange = targetRange
	self.effectType = effectType
	self.apply_effect = apply_effect
