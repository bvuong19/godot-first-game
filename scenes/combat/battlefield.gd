extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_entity(entity: CombatEntity, is_enemy: bool) -> void:
	var grid = $playergrid
	if is_enemy:
		grid = $enemygrid
	var position = grid.get_tile_pos(entity.x, entity.y)
	entity.apply_scale(Vector2(0.3, 0.3))
	entity.position = position
