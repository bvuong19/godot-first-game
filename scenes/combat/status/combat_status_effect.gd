extends Resource
class_name CombatStatusEffect

# what do combat skills need?
@export var status_name : String = "missingName"
@export var max_duration : int
@export var duration : int

@export var hud_icon : Texture2D

func apply_effect(entity : CombatEntity) -> void:
	pass
