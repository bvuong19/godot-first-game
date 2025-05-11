extends CombatAction


func play_action(details : Dictionary) -> void:
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	var pos = Vector3(entity.position)
	var target_pos = Vector3(target.position) + Vector3(0, 0, 0.2)
	
	# 0.3 seconds of animation
	var tween = entity.create_tween().set_parallel(true)
	tween.tween_property(entity, "position:x", target_pos[0], 0.35)
	tween.tween_property(entity, "position:z", target_pos[2], 0.35)
	tween.set_ease(Tween.EASE_IN)
	tween.chain().tween_property(entity, "rotation", entity.rotation, 0.2)
	tween.chain().tween_property(entity, "position:x", pos[0], 0.5)
	tween.tween_property(entity, "position:z", pos[2], 0.5)
	tween.chain().tween_callback(func() -> void: apply_effect(details))
	
	var tween_jump = entity.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)
	tween_jump.set_ease(Tween.EASE_OUT)
	tween_jump.tween_property(entity, "position:y", 1.5, 0.17)
	tween_jump.set_ease(Tween.EASE_IN)
	tween_jump.chain().tween_property(entity, "position:y", pos[1], 0.18)


func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	target.apply_damage(entity.atk, CombatDetail.DAMAGE_TYPE.PHYSICAL)
	callback.call()

func _init() -> void:
	actionType = CombatDetail.ACTION_TYPE.ATTACK
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
