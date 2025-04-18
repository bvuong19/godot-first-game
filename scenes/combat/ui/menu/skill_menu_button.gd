extends Button

var skill : CombatSkill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$".".focus_entered.connect(func(): refresh_label(theme.get_color("font_pressed_color", "Button")))
	$".".focus_exited.connect(func(): refresh_label(theme.get_color("font_color", "Button")))

func refresh_label(color : Color) -> void:
	$skillcost.add_theme_color_override("font_color", color)#$".".get_theme_color("font_color", "button"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
