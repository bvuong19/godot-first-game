extends CombatStatusEffect

class_name GuardingStatus

func apply_effect(entity : CombatEntity) -> void:
	entity.effective_stats["def"] = 2.0 * entity.effective_stats.get("def", entity.def)

func _init() -> void:
	status_name = "Guarding"
	hud_icon = load('res://assets/overdesigned-shield.png')
