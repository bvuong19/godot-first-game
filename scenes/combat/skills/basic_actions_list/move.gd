extends CombatAction


func play_action(details : Dictionary) -> void:
	var entity : CombatEntity = details.entity
	var entity_pos  = Vector2(entity.position[0], entity.position[1]) #index into array to avoid copying array reference
	var target_pos = details.battlefield.get_global_position_from_grid(details.targetTile[0], details.targetTile[1], entity.is_enemy)
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", target_pos, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(apply_effect.bind(details))


func apply_effect(details: Dictionary) -> void:
	var entity : CombatEntity = details.entity
	entity.x = details.targetTile[0]
	entity.y = details.targetTile[1]
	print("entity %s moves to tile (%s, %s)!" % [entity.name, entity.x, entity.y])
	details.callback.call()

func _init() -> void:
	actionType = CombatDetail.ACTION_TYPE.MOVE
	targetType = CombatSkillDetail.TARGET_TYPE.ALLY_RANGE
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
