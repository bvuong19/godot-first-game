extends Control

class_name Battlefield3D

const grid_w : int = 5
const grid_h : int = 4

var selected_entity = null
var cursor_tile : Vector3i = Vector3i(0,0,0)
var is_select_enemy = false
var is_active = false

# targetTiles and targetEntities takes the same shape as the range, or a scalar if there is no range.
# godot type checking for matrices is hot stinky garbage so proceed with caution
signal onSelect(targetTile : Vector2i, targetPosition : Vector3i, aoeTargetPositions : Array, isEnemy : bool)
signal onCancel()
var targetRange : SkillRange = null

func _ready() -> void:
	grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_cancel"):
			onCancel.emit()
			return
		var selected_grid : GridMap = $enemygrid if is_select_enemy else $playergrid
		selected_grid.set_cell_item(cursor_tile,1)
		var new_tile : Vector3i
		new_tile = handleUserTargetingInput(cursor_tile)
		if new_tile != cursor_tile:
			reset_cursor()
			cursor_tile = new_tile
			print("current cursor tile is %s" % new_tile)
			var tiles = get_tiles_from_range(new_tile[0], new_tile[2], targetRange)
			for tile in tiles:
				selected_grid.set_cell_item(tile, 1)
		if Input.is_action_just_pressed("confirm"):
			selected_grid.set_cell_item(cursor_tile,2)
			var targetTile = cursor_tile
			var targetPosition = get_global_position_from_grid(cursor_tile[0], cursor_tile[2], is_select_enemy)
			var aoeTargetPositions : Array = get_tile_positions_from_range(cursor_tile[0], cursor_tile[2], targetRange) if targetRange else []
			onSelect.emit(Vector2i(targetTile[0], targetTile[2]), targetPosition, aoeTargetPositions, is_select_enemy)

#TODO implement this
func get_tiles_from_range(x : int, y : int, range: SkillRange) -> Array[Vector3i]:
	if is_invalid_coordinate(x, y):
		return []
	elif not range:
		return [Vector3i(x,0,y)]
	else:
		var tiles : Array[Vector3i] = []
		var mask = range.aoe
		var orig_x = range.origin[0]
		var orig_y = range.origin[1]
		for i in range(len(mask)):
			for j in range(len(mask[0])):
				if mask[i][j] and not is_invalid_coordinate(x+j-orig_x,y+i-orig_y):
					tiles.append(Vector3i(x+j-orig_x,0,y+i-orig_y))
		return tiles

func get_tile_positions_from_range(x : int, y : int, range: SkillRange) -> Array:
	if is_invalid_coordinate(x, y) or not range:
		print("get_tile_positions_from_range was called without a range")
		return []
	else:
		var tilePositions : Array = []
		var mask = range.aoe
		var orig_x = range.origin[0]
		var orig_y = range.origin[1]
		for i in range(len(mask)):
			var col = []
			for j in range(len(mask[0])):
				#if mask[i][j] and not is_invalid_coordinate(x+j-orig_x,y+i-orig_y):
					col.append(get_global_position_from_grid(x+j-orig_x, y+i-orig_y, is_select_enemy))
			tilePositions.append(col)
		#print(tilePositions)
		return tilePositions
		
func is_invalid_coordinate(x : int, y : int):
	return x >= grid_w or y >= grid_h or x < 0 or y < 0

func refresh_selections() -> void:
	cursor_tile = Vector3i(0,0,0)
	for x in grid_w:
		for z in grid_h:
			$enemygrid.set_cell_item(Vector3i(x,0,z), 0)
			$playergrid.set_cell_item(Vector3i(x,0,z), 0)
			
func reset_cursor() -> void:
	for x in grid_w:
		for z in grid_h:
			$enemygrid.set_cell_item(Vector3i(x,0,z), 0)
			$playergrid.set_cell_item(Vector3i(x,0,z), 0)

func handleUserTargetingInput(selected_tile : Vector3i) -> Vector3i:
	if Input.is_action_just_pressed("left"):
		return Vector3i(max(0, selected_tile[0] - 1), 0, selected_tile[2])
	elif Input.is_action_just_pressed("right"):
		return Vector3i(min(grid_w - 1, selected_tile[0] + 1), 0, selected_tile[2])
	elif Input.is_action_just_pressed("down"):
		return Vector3i(selected_tile[0], 0, min(grid_h - 1, selected_tile[2] + 1))
	elif Input.is_action_just_released("up"):
		return Vector3i(selected_tile[0], 0, max(0, selected_tile[2] - 1))
	return selected_tile
#
func add_entity(entity: CombatEntity) -> void:
	var grid : GridMap = $playergrid
	if entity.is_enemy:
		grid = $enemygrid
	var entity_position = grid.map_to_local(Vector3i(entity.x,0.2,entity.y))
	entity.set_position(entity_position + grid.position)
#
func highlight_entity(entity: CombatEntity) -> void:
	var grid : GridMap = $enemygrid if entity.is_enemy else $playergrid
	grid.set_cell_item(Vector3i(entity.x,0,entity.y),2)

func get_global_position_from_grid(x : int, z : int, is_enemy : bool) -> Vector3:
	var grid : GridMap =  %enemygrid if is_enemy else %playergrid
	return grid.map_to_local(Vector3i(x, 0, z)) + grid.position


func set_active(active : bool) -> void:
	is_active = active
