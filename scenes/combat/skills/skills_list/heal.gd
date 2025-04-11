extends CombatSkill

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

func play_skill(details : Dictionary) -> void:
	var entity : CombatEntity = details.targetEntity
	#TODO: replace this copy pasted code you dung beetle
	var spell : AnimatedSprite2D = spell_fx_basic.instantiate()
	var callback_free = func():
		apply_effect(details)
		spell.queue_free()		
	spell.play('Heal')
	spell.animation_finished.connect(callback_free)
	entity.add_child(spell)


func apply_effect(details: Dictionary) -> void:
	var callback : Callable = details.callback
	var entity : CombatEntity = details.entity
	var target : CombatEntity = details.targetEntity
	target.apply_heal(entity.atk * 0.5)
	callback.call()

func _init() -> void:
	skillName = 'Heal'
	targetType = CombatSkillDetail.TARGET_TYPE.ALLY
	effectType = CombatSkillDetail.EFFECT_TYPE.INSTANT
	
	#@export var skillName : String = "missingName"
	#@export var targetType : CombatSkillDetail.TARGET_TYPE
	#@export var targetRange : SkillRange
	#@export var effectType : CombatSkillDetail.EFFECT_TYPE
