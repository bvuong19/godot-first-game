extends Control


@onready var camera = get_viewport().get_camera_3d()
@onready var parent = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if camera:
		var unprojected_position = camera.unproject_position(parent.global_transform.origin)
		position = unprojected_position
