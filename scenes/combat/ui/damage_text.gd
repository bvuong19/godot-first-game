extends Node2D

class_name DamageText

func set_damage(dmg: float) -> void:
	%label.text = "-" + str(dmg) + "!" if dmg >= 0 else "+" + str(dmg * -1)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func animate() -> void:
	var target_pos = Vector2(position.x, position.y - 30)
	var tween = create_tween()
	tween.tween_property($".", "position", target_pos, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: $".".queue_free())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
