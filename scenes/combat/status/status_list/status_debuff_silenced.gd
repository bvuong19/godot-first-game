extends CombatStatusEffect

class_name SilencedDebuffStatus

func apply_effect(entity : CombatEntity) -> void:
	entity.effective_stats.actions = entity.effective_stats.get('actions', entity.actions)
	entity.effective_stats.actions.erase(Combat_Action.SKILL)

func _ready() -> void:
	status_name = "Silenced"
	hud_icon = load("res://assets/silence_icon.png")
