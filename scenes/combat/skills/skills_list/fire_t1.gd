extends CombatAction

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_action(details : Dictionary) -> void:
	var entity : CombatEntity = details.targetEntity
	if (details.user.apply_skill_cost(self)):
		var spell : AnimatedSprite3D = spell_fx_basic.instantiate()
		var callback_free = func():
			apply_effect(details)
			spell.queue_free()
		spell.play('Fire')
		spell.animation_finished.connect(callback_free)
		entity.add_child(spell)
	else:
		print('skill cost could not be applied!')
		var callback : Callable = details.callback
		callback.call()
		
func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	target.apply_damage(entity.atk * 1.5, CombatDetail.DAMAGE_TYPE.MAGIC)
	callback.call()

func _init() -> void:
	skillName = "Fire"
	actionType = CombatDetail.ACTION_TYPE.SKILL
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
	skillCostType = CombatSkillDetail.COST_TYPE.MP
	skillCost = 5
