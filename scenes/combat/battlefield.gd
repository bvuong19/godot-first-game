extends Control

var selected_entity = null
var cursor_tile = []
@export var is_select_enemy = false
var is_active = false

var spell_fx_basic = preload("res://scenes/combat/animation/spell_effect_basic.tscn")

signal onSelect(targetPosition : Vector2, targetTiles : Array[Vector2i], isEnemy : bool)
signal onCancel()
var targetRange : SkillRange = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_cancel"):
			onCancel.emit()
			return
		
		var selected_grid : EntityGrid = $enemygrid if is_select_enemy else $playergrid
		var new_tile = []
		
		if cursor_tile:
			new_tile = handleUserTargetingInput(cursor_tile, selected_grid)
		else:
			new_tile = [0,0]
		if new_tile:
			selected_grid.reset()
			cursor_tile = new_tile
			var tiles = selected_grid.get_tiles_from_range(cursor_tile[0], cursor_tile[1], targetRange)
			for tile in tiles:
				if tile:
					tile._animate_select()

		if Input.is_action_just_pressed("confirm"):
			onSelect.emit(Vector2i(cursor_tile[0],cursor_tile[1]), selected_grid.get_tile_coords_from_range(cursor_tile[0], cursor_tile[1], targetRange), is_select_enemy)

func refresh_selections() -> void:
	cursor_tile = []
	$enemygrid.reset()
	$playergrid.reset()

func handleUserTargetingInput(selected_tile : Array, selected_grid : EntityGrid) -> Array:
	if Input.is_action_just_pressed("left"):
		return [max(0, selected_tile[0] - 1), selected_tile[1]] 
	elif Input.is_action_just_pressed("right"):
		return [min(selected_grid.w - 1, selected_tile[0] + 1), selected_tile[1]]
	elif Input.is_action_just_pressed("down"):
		return [selected_tile[0], min(selected_grid.h - 1, selected_tile[1] + 1)]
	elif Input.is_action_just_released("up"):
		return [selected_tile[0], max(0, selected_tile[1] - 1)]
	return []

func add_entity(entity: CombatEntity, is_enemy: bool) -> void:
	var grid = $playergrid
	if is_enemy:
		grid = $enemygrid
	var position = grid.get_tile_pos(entity.x, entity.y)
	entity.apply_scale(Vector2(0.3, 0.3))
	entity.position = position

func highlight_entity(entity: CombatEntity) -> void:
	var grid : EntityGrid = $enemygrid if entity.isEnemy else $playergrid
	grid.select_tile(entity.x, entity.y)

func refresh_entity_position(entity: CombatEntity, is_enemy : bool) -> void:
	var grid : EntityGrid = $enemygrid if is_enemy else $playergrid
	entity.position = grid.get_tile_pos(entity.x, entity.y)

func set_active(active : bool) -> void:
	is_active = active

func get_tile(x : int, y : int, isEnemy : bool) -> GridTile:
	var grid : EntityGrid = $enemygrid if isEnemy else $playergrid
	return grid.get_tile(x, y)

#TODO: move animations into their own class
func animate_entity_attack(entity : CombatEntity, target : CombatEntity, callback) -> void:
	var entity_pos  = Vector2(entity.position[0], entity.position[1]) #index into array to avoid copying array reference
	var target_pos = Vector2(target.position[0], target.position[1])
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", target_pos, 1).set_trans(Tween.TRANS_CUBIC)
	tween.chain().tween_property(entity, "position", entity_pos, 0.6)
	tween.tween_callback(callback)
	
func animate_entity_move(entity : CombatEntity, x : int, y : int, callback) -> void:
	var entity_pos  = Vector2(entity.position[0], entity.position[1]) #index into array to avoid copying array reference
	var grid = $playergrid
	var target_pos = grid.get_tile_pos(entity.x, entity.y)
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", target_pos, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(callback)

func animate_entity_hop(entity : CombatEntity, callback) -> void:
	var pos = Vector2(entity.position[0], entity.position[1])
	var target_pos = Vector2(pos[0], pos[1] - 40)
	var tween = entity.create_tween()
	tween.tween_property(entity, "position", target_pos, 0.1).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(entity, "position", pos, 0.15).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(callback)
