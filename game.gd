extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#add_child(preload("res://scenes/combat/combat_3d.tscn").instantiate())
	var combat = Combat3D.init([])
	add_child(combat)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("confirm"):
		#if not $Combat.event_queue:
			#$Combat.debug_add_events()
		#else:
			#$Combat.process_event_queue()
	pass
