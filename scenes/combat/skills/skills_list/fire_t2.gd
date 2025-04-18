extends CombatSkill

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_skill(details : Dictionary) -> void:
	var tiles = details.targetGridTiles
	print(tiles)
	#TODO: replace this copy pasted code you dung beetle
	var spellfx : Array[AnimatedSprite2D] = []
	var callback_free = func(spell):
		spell.queue_free()
		spellfx.erase(spell)
		if not spellfx:
			apply_effect(details)
	for tile in tiles:
		var spell : AnimatedSprite2D = spell_fx_basic.instantiate()
		spell.play('Fire')
		spell.animation_finished.connect(callback_free.bind(spell))
		spellfx.append(spell)
		spell.global_position = tile.global_position
		spell.apply_scale(Vector2(0.3,0.3))
		details.battlefield.add_child(spell)

func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var targets = details.targetEntities
	for target in targets:
		target.apply_damage(entity.atk * 1.5, Combat_Detail.DAMAGE_TYPE.MAGIC)
	callback.call()

func _init() -> void:
	skillName = "Fira"
	targetType = CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE
	targetRange = preload("res://scenes/combat/skills/range/small_plus.tres")
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
	skillCostType = CombatSkillDetail.COST_TYPE.MP
	skillCost = 15
