extends Script

static var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

static func play_skill(details : Dictionary) -> void:
	var entity : CombatEntity = details.targetEntity
	#TODO: replace this copy pasted code you dung beetle
	var spell : AnimatedSprite2D = spell_fx_basic.instantiate()
	var callback_free = func():
		apply_effect(details)
		spell.queue_free()		
	spell.play('Fire')
	spell.animation_finished.connect(callback_free)
	entity.add_child(spell)


static func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	target.apply_damage(entity.atk * 1.5)
	callback.call()
