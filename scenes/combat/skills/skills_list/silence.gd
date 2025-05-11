extends CombatAction

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_action(details : Dictionary) -> void:
	var entity : CombatEntity = details.targetEntity
	#TODO: replace this copy pasted code you dung beetle
	var spell : AnimatedSprite3D = spell_fx_basic.instantiate()
	var callback_free = func():
		apply_effect(details)
		spell.queue_free()		
	spell.play('Silence')
	spell.animation_finished.connect(callback_free)
	entity.add_child(spell)


func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	var silenced_status = preload("res://scenes/combat/status/status_list/status_debuff_silenced.gd").new()
	target.apply_status(silenced_status, 3)
	silenced_status.apply_effect(target)
	callback.call()

func _init() -> void:
	skillName = "Silence"
	actionType = CombatDetail.ACTION_TYPE.SKILL
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
