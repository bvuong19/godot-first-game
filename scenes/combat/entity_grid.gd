extends Node2D
class_name EntityGrid

const grid_size = 64
const w = 5
const h = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#gets location depending on X and Y coordinate on the grid.

func get_tile_pos(x: int, y: int) -> Vector2:
	var pos = get_tile(x, y).get_node("marker").global_position
	return pos
	#var offset = Vector2(x * grid_size, y * grid_size)
	#return Transform2D(0, Vector2(1,1), (get_skew()), Vector2(10,20)) * offset

func reset() -> void:
	for t in $tiles.get_children():
		t._animate_unselect()

func get_tile(x: int, y: int) -> GridTile:
	return $tiles.get_children()[(y * 5) + x]

func select_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_select()
	
func unselect_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_unselect()

func confirm_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_confirm()
