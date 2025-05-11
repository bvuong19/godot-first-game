extends Resource
class_name CombatAction

@export var actionType : CombatDetail.ACTION_TYPE

# targeting type: none, self, ally, enemy, ally_range, enemy_range, global
@export var targetType : CombatSkillDetail.TARGET_TYPE

# targeting range
# assumes ally_range or enemy_range type. create a mask array to represent the range
@export var targetRange : SkillRange

# effect type
# instant, lingering, delayed, other
@export var effectType : CombatSkillDetail.EFFECT_TYPE

@export var skillCostType : CombatSkillDetail.COST_TYPE
@export var skillCost : float
@export var skillName : String = "missingName"

func play_action(details : Dictionary) -> void:
	pass

func apply_effect(details : Dictionary) -> void:
	pass
