extends Node2D

class_name DamageText

static func new(dmg: float) -> DamageText:
	var instance = DamageText.new()
	instance.label.text = "-" + str(dmg) + "!"
	return instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
