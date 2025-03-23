extends Control

var selected_entity = null
var selected_tile = []
@export var is_select_enemy = false
var is_active = false

signal onSelect(x: int, y: int, isEnemy: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	onSelect.connect(get_parent()._on_grid_selected)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if has_focus():
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
