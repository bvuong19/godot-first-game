extends Button

var skill : CombatSkill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#$".".pressed.connect(refresh_label)
	pass # Replace with function body.
#
#func refresh_label() -> void:
	#$skillcost.add_theme_color_override("font_color", $".".get_theme_color("font_color", "button"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
