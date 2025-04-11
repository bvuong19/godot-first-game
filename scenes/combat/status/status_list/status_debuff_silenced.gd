extends CombatStatusEffect

class_name SilencedDebuffStatus

func apply_effect(entity : CombatEntity) -> void:
	entity.effective_moves.erase(Combat_Action.SKILL)

func _ready() -> void:
	status_name = "Silenced"
