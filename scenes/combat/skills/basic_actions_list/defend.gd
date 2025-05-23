extends CombatAction


func play_action(details : Dictionary) -> void:
	var entity : CombatEntity = details.entity
	var start_y : float = entity.position.y
	var tween_jump = entity.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)
	tween_jump.set_ease(Tween.EASE_OUT)
	tween_jump.tween_property(entity, "position:y", start_y + 0.5, 0.1)
	tween_jump.set_ease(Tween.EASE_IN)
	tween_jump.chain().tween_property(entity, "position:y", start_y, 0.1)
	apply_effect(details)


func apply_effect(details: Dictionary) -> void:
	var entity : CombatEntity = details.entity
	var callback : Callable = details.callback
	var guard_status = preload('res://scenes/combat/status/status_list/status_guarding.gd').new()
	entity.apply_status(guard_status, 2)
	guard_status.apply_effect(entity)
	print(entity.name + " defends, raising their defense to " + str(entity.effective_stats.get('def', entity.def)) + "!")
	callback.call()

func _init() -> void:
	actionType = CombatDetail.ACTION_TYPE.DEFEND
	targetType = CombatSkillDetail.TARGET_TYPE.SELF
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
