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
	if y * 5 + x < (w * h):
		return $tiles.get_children()[(y * 5) + x]
	return null
	
func select_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_select()

func unselect_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_unselect()

func confirm_tile(x: int, y: int) -> void:
	$tiles.get_children()[(y * 5) + x]._animate_confirm()
	

	
func get_tiles_from_mask(x : int, y : int, mask: Array, orig_x : int, orig_y : int) -> Array[GridTile]:
	if is_invalid_coordinate(x, y):
		return []
	else:
		var tiles : Array[GridTile] = []
		for i in range(len(mask)):
			for j in range(len(mask[0])):
				if mask[i][j] and not is_invalid_coordinate(x+j-orig_x,y+i-orig_y):
					tiles.append(get_tile(x+j-orig_x,y+i-orig_y))
		return tiles
		
func is_invalid_coordinate(x : int, y : int):
	return x >= w or y >= h or x < 0 or y < 0
