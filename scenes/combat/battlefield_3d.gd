extends Control

const grid_w : int = 5
const grid_h : int = 4


var selected_entity = null
var cursor_tile : Vector3i = Vector3i(0,0,0)
@export var is_select_enemy = false
var is_active = false


signal onSelect(targetPosition : Vector2, targetTiles : Array[Vector2i], isEnemy : bool)
signal onCancel()
var targetRange : SkillRange = null

func _ready() -> void:
	#$playergrid.set_cell_item(Vector3i(0,0,0),1)
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
			
			#var tiles = selected_grid.get_tiles_from_range(cursor_tile[0], cursor_tile[1], targetRange)
			#for tile in tiles:
				#if tile:
					#tile._animate_select()
			selected_grid.set_cell_item(cursor_tile,1)
		if Input.is_action_just_pressed("confirm"):
			selected_grid.set_cell_item(cursor_tile,2)
			onSelect.emit(Vector2i(cursor_tile[0],cursor_tile[2]), get_tile_coords_from_range(cursor_tile[0], cursor_tile[2], targetRange), is_select_enemy)

#TODO implement this

#
func get_tiles_from_range(x : int, y : int, range: SkillRange) -> Array[Vector2i]:
	if is_invalid_coordinate(x, y):
		return []
	elif not range:
		return [Vector2i(x,y)]
	else:
		var tiles : Array[Vector2i] = []
		var mask = range.aoe
		var orig_x = range.origin[0]
		var orig_y = range.origin[1]
		for i in range(len(mask)):
			for j in range(len(mask[0])):
				if mask[i][j] and not is_invalid_coordinate(x+j-orig_x,y+i-orig_y):
					tiles.append(Vector2i(x+j-orig_x,y+i-orig_y))
		return tiles
		
func get_tile_coords_from_range(x : int, y : int, range: SkillRange) -> Array[Vector2i]:
	if is_invalid_coordinate(x, y) or not range:
		return []
	else:
		var tiles : Array[Vector2i] = []
		var mask = range.aoe
		var orig_x = range.origin[0]
		var orig_y = range.origin[1]
		for i in range(len(mask)):
			for j in range(len(mask[0])):
				if mask[i][j] and not is_invalid_coordinate(x+j-orig_x,y+i-orig_y):
					tiles.append(Vector2i(x+j-orig_x,y+i-orig_y))
		return tiles
		
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
	#print('entity position\t\t%s' % entity_position)
	#print('grid position\t\t%s' % grid.position)
	entity.set_position(entity_position + grid.position)
#
func highlight_entity(entity: CombatEntity) -> void:
	var grid : GridMap = $enemygrid if entity.is_enemy else $playergrid
	grid.set_cell_item(Vector3i(entity.x,0,entity.y),2)

func set_active(active : bool) -> void:
	is_active = active
#
#func get_tile(x : int, z : int, isEnemy : bool) -> GridTile:
	#var grid : GridMap = $enemygrid if isEnemy else $playergrid
	#return grid.get_cell_item(x,0,z)
#
##TODO: move animations into their own class
#func animate_entity_attack(entity : CombatEntity, target : CombatEntity, callback) -> void:
	#var entity_pos  = Vector2(entity.position[0], entity.position[1]) #index into array to avoid copying array reference
	#var target_pos = Vector2(target.position[0], target.position[1])
	#var tween = entity.create_tween()
	#tween.tween_property(entity, "position", target_pos, 1).set_trans(Tween.TRANS_CUBIC)
	#tween.chain().tween_property(entity, "position", entity_pos, 0.6)
	#tween.tween_callback(callback)

func animate_entity_attack(char : Node3D, target : Node3D, callback : Callable) -> void:
	var pos = Vector3(char.position)
	var target_pos = Vector3(target.position) + Vector3(0, 0, 0.2)
	
	# 0.3 seconds of animation
	var tween = char.create_tween().set_parallel(true)
	tween.tween_property(char, "position:x", target_pos[0], 0.35)
	tween.tween_property(char, "position:z", target_pos[2], 0.35)
	tween.set_ease(Tween.EASE_IN)
	tween.chain().tween_property(char, "rotation", char.rotation, 0.2)
	tween.chain().tween_property(char, "position:x", pos[0], 0.5)
	tween.tween_property(char, "position:z", pos[2], 0.5)
	tween.tween_callback(callback)
	
	var tween_jump = char.create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)
	tween_jump.set_ease(Tween.EASE_OUT)
	tween_jump.tween_property(char, "position:y", 1.5, 0.17)
	tween_jump.set_ease(Tween.EASE_IN)
	tween_jump.chain().tween_property(char, "position:y", pos[1], 0.18)
	
func animate_entity_move(entity : CombatEntity, x : int, y : int, callback) -> void:
	var entity_pos  = Vector2(entity.position[0], entity.position[1]) #index into array to avoid copying array reference
	var grid = $playergrid
	var target_pos = grid.map_to_local(Vector3i(x,0.2,y)) + grid.position
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", target_pos, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(callback)

func animate_entity_hop(entity : CombatEntity, callback) -> void:
	var pos : Vector3  = Vector3(entity.position)
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", pos + Vector3(0, 0.6, 0), 0.1).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(entity, "position", pos, 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(callback)
