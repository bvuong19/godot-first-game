extends Control

var selected_entity = null
var selected_tile = []
@export var is_select_enemy = false
var is_active = false

var fire_fx = preload("res://scenes/combat/fire_spell_effect.tscn")

signal onSelect(x: int, y: int, isEnemy: bool)
signal onCancel()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#TODO: add new forms of targeting.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_cancel"):
			onCancel.emit()
			return
		
		var selected_grid = $enemygrid if is_select_enemy else $playergrid
		var new_tile = []
		
		if not selected_tile:
			selected_tile = [0,0]
			selected_grid.select_tile(selected_tile[0], selected_tile[1])
		else:
			new_tile = handleUserTargetingInput(selected_tile, selected_grid)
		if new_tile:
			selected_grid.unselect_tile(selected_tile[0], selected_tile[1])
			selected_tile = new_tile
			selected_grid.select_tile(new_tile[0], new_tile[1])
		
		if Input.is_action_just_pressed("confirm"):
			selected_grid.confirm_tile(selected_tile[0], selected_tile[1])
			onSelect.emit(selected_tile[0], selected_tile[1], is_select_enemy)
	


func refresh_selections() -> void:
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

func refresh_entity_position(entity: CombatEntity, is_enemy : bool) -> void:
	var grid = $playergrid
	if is_enemy:
		grid = $enemygrid
	entity.position = grid.get_tile_pos(entity.x, entity.y)

func set_active(active : bool) -> void:
	is_active = active

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
	
func animate_entity_spell(x : int, y : int, callback : Callable) -> void:
	var pos = $enemygrid.get_tile_pos(x, y)
	var fire = fire_fx.instantiate()
	var callback_free = func():
		fire.queue_free()
		callback.call()
	fire.position = pos
	fire.animation_finished.connect(callback_free)
	add_child(fire)
