extends CombatAction

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_action(details : Dictionary) -> void:
	print("casting uwu")
	var user : CombatEntity = details.entity
	var target_is_enemy = not user.is_enemy
	if (user.apply_skill_cost(self)):
		var tiles = details.aoeTargetPositions
		var spellfx : Array[AnimatedSprite3D] = []
		var callback_free = func(spell):
			spell.queue_free()
			spellfx.erase(spell)
			if not spellfx:
				apply_effect(details)
		var mask = targetRange.aoe
		for i in range(len(mask)):
			var col = []
			for j in range(len(mask[0])):
				if mask[i][j]:
					var spell : AnimatedSprite3D = spell_fx_basic.instantiate()
					spell.play('Fire')
					spell.animation_finished.connect(callback_free.bind(spell))
					spellfx.append(spell)
					spell.position = tiles[i][j]
					#spell.apply_scale(Vector2(0.3,0.3))
					details.battlefield.add_child(spell)
		#TODO: replace this copy pasted code you dung beetle
	else:
		var callback : Callable = details.callback
		print('bitchass')
		callback.call()

func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var user : CombatEntity = details.entity
	var targets = utils.flatten(details.aoeTargetEntities)
	for target in targets:
		if target:
			target.apply_damage(user.atk * 1.5, CombatDetail.DAMAGE_TYPE.MAGIC)
	callback.call()

func _init() -> void:
	skillName = "Fira"
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE
	actionType = CombatDetail.ACTION_TYPE.SKILL
	#targetRange = preload("res://scenes/combat/skills/range/pierce_two.tres")
	targetRange = preload("res://scenes/combat/skills/range/small_plus.tres")
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
	skillCostType = CombatSkillDetail.COST_TYPE.MP
	skillCost = 15
