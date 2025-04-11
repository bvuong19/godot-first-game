extends Resource
class_name CombatSkill

# what do combat skills need?
@export var skillName : String = "missingName"

# targeting type
# none, self, ally, enemy, ally_range, enemy_range, global
@export var targetType : CombatSkillDetail.TARGET_TYPE

# targeting range
# assumes ally_range or enemy_range type. create a mask array to represent the range
@export var targetRange : SkillRange
# TODO: use SkillRange class instead

# effect type
# instant, lingering, delayed, other
@export var effectType : CombatSkillDetail.EFFECT_TYPE

func play_skill(details : Dictionary) -> void:
	pass

func apply_effect(details : Dictionary) -> void:
	pass
