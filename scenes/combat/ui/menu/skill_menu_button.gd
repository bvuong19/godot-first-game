extends Button

class_name SkillMenuItem

var skill : CombatSkill
var pressed_color : Color
var default_color : Color
var disabled_color : Color

const scene : PackedScene = preload("res://scenes/combat/ui/menu/skill_menu_button.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed_color = theme.get_color("font_pressed_color", "Button")
	default_color = theme.get_color("font_color", "Button")
	disabled_color = theme.get_color("font_disabled_color", "Button")
	$".".focus_entered.connect(func(): refresh_label(pressed_color))
	$".".focus_exited.connect(func(): refresh_label(default_color))

func refresh_cost_label() -> void:
	if skill.skillCostType and skill.skillCost:
		%skillcost.text = '%s %s' % [skill.skillCost, CombatSkillDetail.COST_TYPE.keys()[skill.skillCostType]]
	else:
		%skillcost.text = '---'

func refresh_label(color : Color) -> void:
	$skillcost.add_theme_color_override("font_color", color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func from_skill(skill : CombatSkill, disabled : bool = false) -> SkillMenuItem:
	var skillButton = scene.instantiate()
	skillButton.skill = skill
	skillButton.text = skill.skillName
	skillButton.refresh_cost_label()
	if disabled:
		skillButton.disabled = true
		skillButton.refresh_label(skillButton.theme.get_color("font_disabled_color", "Button"))
		skillButton.focus_mode = Control.FOCUS_NONE
	return skillButton
