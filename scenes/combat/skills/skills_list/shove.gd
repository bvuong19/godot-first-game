extends CombatAction

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_skill(details : Dictionary) -> void:
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	if entity.apply_skill_cost(self):
		var push_result : Dictionary = get_push_result(details)
		var callback_free = func():
			apply_effect(details)
		var entity_pos  = Vector3(entity.position) #index into array to avoid copying array reference
		var target_grid : GridMap = details.battlefield.get_node("%enemygrid")
		var battlefield : Battlefield3D = details.battlefield
		var entity_target_pos = battlefield.get_global_position_from_grid(details.targetTile[0], details.targetTile[1], details.targetEntity.is_enemy) - Vector3(0.2,0,0)
		var endpoint_pos = battlefield.get_global_position_from_grid(push_result.endpointTile[0], push_result.endpointTile[1], details.targetEntity.is_enemy)

		var tween = entity.create_tween()
		tween.tween_property(entity, "position", entity_target_pos, 0.5).set_trans(Tween.TRANS_CUBIC)
			
		if push_result.collidedEntity:
			var collided_enemy_pos = battlefield.get_global_position_from_grid(push_result.collidedEntity.x, push_result.collidedEntity.y, details.targetEntity.is_enemy)			
			tween.chain().tween_property(target, "position", collided_enemy_pos - Vector3(0.2,0,0), 0.2).set_ease(Tween.EASE_IN)
			tween.chain().tween_property(target, "position", endpoint_pos, 0.1).set_ease(Tween.EASE_IN)
		else:
			tween.chain().tween_property(target, "position", endpoint_pos, 0.4).set_ease(Tween.EASE_IN)
			tween.chain().tween_property(entity, "position", entity_pos, 0.5)

		tween.chain().tween_property(entity, "position", entity_pos, 0.5)
		tween.tween_callback(callback_free)


		
func get_push_result(details : Dictionary) -> Dictionary:
	var endpointTile : Vector2i
	var collidedEntity : CombatEntity
	for i in utils.flatten(details.aoeTargetEntities):
		if i and i != details.targetEntity:
			collidedEntity = i
			endpointTile = Vector2i(collidedEntity.x-1, collidedEntity.y)
			break
	if not collidedEntity:
		endpointTile = Vector2i(min(details.targetTile[0] + 2, 4), details.targetTile[1])

	return { 'endpointTile' : endpointTile, 'collidedEntity' : collidedEntity }

func apply_effect(details: Dictionary) -> void:
	#check if the unit will collide with a unit
	var push_result : Dictionary = get_push_result(details)

	#push the unit
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity

	target.x = push_result.endpointTile[0]
	target.y = push_result.endpointTile[1]
	if push_result.collidedEntity:
		target.apply_damage(target.hp * 0.2, CombatDetail.DAMAGE_TYPE.PHYSICAL)
		push_result.collidedEntity.apply_damage(target.hp * 0.2, CombatDetail.DAMAGE_TYPE.PHYSICAL)
	
	var callback : Callable = details.callback
	callback.call()

func _init() -> void:
	skillName = 'Shove'
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
	targetRange = preload("res://scenes/combat/skills/range/pierce_two.tres")
	skillCostType = CombatSkillDetail.COST_TYPE.NONE
	skillCost = 0
