extends CombatStatusEffect

class_name SilencedDebuffStatus

func apply_effect(entity : CombatEntity) -> void:
	entity.effective_stats.actions = entity.effective_stats.get('actions', entity.actions)
	entity.effective_stats.actions.erase(CombatDetail.ACTION_TYPE.SKILL)

func _init() -> void:
	status_name = "Silenced"
	hud_icon = load('res://assets/dotdotdot.png')
