extends Node3D

class_name Combat3D
const scene : PackedScene = preload("res://scenes/combat/combat_3d.tscn")

#control flow state
enum {
	PLANNING,
	TURNSTART,
	TARGET,
	BATTLING,
	END
}

var event_queue: Array = []
var turn_queue: Array[CombatEntity] = []
signal turn_queue_updated(Array)
var debug = true

var current_phase = BATTLING
var is_phase_change = true
var eventBuilder = {}
var animation_locked = false
var debug_add_event = false

func process_turn_queue() -> void:
	if not turn_queue:
		reset_turn_queue()
	eventBuilder = {}
	if turn_queue:
		var e : CombatEntity = turn_queue[0]
		print("turn queue updated, current turn is %s" % e.name)
		e.on_turn_start()
		turn_queue_updated.emit(turn_queue)
		if e.is_enemy:
			if debug_add_event:
				debug_add_event = false
				event_queue.append({'entity': e, 'type': CombatDetail.ACTION_TYPE.SKILL, 'skillDetail': preload("res://scenes/combat/skills/skills_list/silence.gd").new(), 'targetEntity': get_players().front()})
			# TODO: more support for enemy actions. Currently we just let them attack.
			else:
				event_queue.append({'entity': e, 'action': preload("res://scenes/combat/skills/basic_actions_list/attack.gd").new(), 'targetEntity': get_players().front()})
			change_phase(BATTLING)
		else:
			# start player turn
			updateEventBuilder({'entity': e})
			change_phase(TURNSTART)

func reset_turn_queue() -> void:
	for c in $combatants.get_children():
		turn_queue.append(c)
	turn_queue.sort_custom(sort_entity_priority)
	
func sort_entity_priority(a : CombatEntity, b: CombatEntity) -> bool:
	return a.spd > b.spd

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if current_phase == BATTLING:
		#print("event queue %s \nanim locked%s" % [event_queue, animation_locked])
		if not animation_locked and event_queue:
			eventBuilder = {}
			$battlefield.refresh_selections()
			# process the next event
			if event_queue:
				var event = event_queue.pop_front()
				event['battlefield'] = $battlefield
				animation_locked = true
				event.callback = _on_battle_anim_complete
				event['action'].play_action(event)

# callback for when battle animation is complete
func _on_battle_anim_complete() -> void:
	animation_locked = false
	if not event_queue and current_phase != END:
		turn_queue.pop_front()
		process_turn_queue()

# signal onSelect(targetTile : Vector2, targetPosition : Vector3i, aoeTargetPositions : Array[Array], isEnemy : bool)
# Called when grid selected. Provides the eventBuilder with the following fields:
# targetTile - x/y coord of original tile
# targetPosiiton - 3D grid coord of original tile
# targetEntity - entiy at targeted tile, if it exists
# aoeTargetPositions - aoe Target positions in range
# aoeTargetEntities - aoe Targeted entities in range
func _on_grid_selected(targetTile : Vector2i, targetPosition : Vector3i, aoeTargetPositions: Array, is_enemy : bool) -> void:
	var properties = {'targetTile': targetTile, 'targetPosition' : targetPosition, 'aoeTargetPositions': aoeTargetPositions}
	
	var targetRange = eventBuilder['action'].targetRange if eventBuilder.has('action') else null
	if targetRange:
		var targetEntities = []
		var x = targetTile[0]
		var y = targetTile[1]
		var tilePositions : Array[Array] = []
		var mask = targetRange.aoe
		var orig_x = targetRange.origin[0]
		var orig_y = targetRange.origin[1]
		for i in range(len(mask)):
			var col = []
			for j in range(len(mask[0])):
				var entityAtTile : CombatEntity = getEntityAtPosition(x+j-orig_x, y+i-orig_y, is_enemy)
				col.append(entityAtTile)
			targetEntities.append(col)
		properties['aoeTargetEntities'] = targetEntities
	
	print("getting enemy at %s" % targetTile)
	var cursorEntity = getEntityAtPosition(targetTile[0], targetTile[1], is_enemy)
	print("found %s" % cursorEntity)
	if cursorEntity:
		properties['targetEntity'] = cursorEntity
	updateEventBuilder(properties)

func _on_grid_cancel() -> void:
	eventBuilder = { 'entity': eventBuilder.entity }
	$battlefield.refresh_selections()
	updateEventBuilder({})

func _on_user_input_selected(properties: Dictionary) -> void:
	updateEventBuilder(properties)

# The eventBuilder contains the action that the user is planning.
# entity: the CombatEntity making the move
# type: the type of action that the user is taking.
# targetEntity: for single-target actions, a targeted entity
# targetPosition: a targeted tile
# targetTiles: targeted tiles covered by an AoE, if the player was targeting an AoE skill.
# targetEntities: all entities within targetTiles, if the player was targeting an AoE skill.
# skillDetail: details for the skill. Refer to combat_action.gd for more info
# TODO: use combat action detail to determine how to handle control flow
func updateEventBuilder(properties: Dictionary) -> void:
	eventBuilder.merge(properties)
	if not eventBuilder.has('entity'):
		return
	$battlefield.highlight_entity(eventBuilder['entity'])
	if not eventBuilder.has('action'):
		change_phase(TURNSTART)
		return
	
	match eventBuilder['action'].actionType:
		CombatDetail.ACTION_TYPE.ATTACK:
			if eventBuilder.has('targetEntity') and eventBuilder['targetEntity']:
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			else:
				$battlefield.is_select_enemy = true
				change_phase(TARGET)
		CombatDetail.ACTION_TYPE.SKILL:
			# should check targeting type.
			# 1: does not need targeting
			var skillDetail : CombatAction = eventBuilder['action']
			if (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.NONE, CombatSkillDetail.TARGET_TYPE.SELF, CombatSkillDetail.TARGET_TYPE.GLOBAL]):
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 2: has target
			# 2a: targets a unit
			elif (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ALLY, CombatSkillDetail.TARGET_TYPE.ENEMY]) and eventBuilder.has('targetEntity') and eventBuilder['targetEntity']:
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 2b: targets an area
			elif (skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ALLY_RANGE, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]) and eventBuilder.has('aoeTargetPositions') and eventBuilder['aoeTargetPositions']:
				$battlefield.targetRange = null
				event_queue.append(eventBuilder)
				change_phase(BATTLING)
			# 3: needs target
			else:
				$battlefield.is_select_enemy = skillDetail.targetType in [CombatSkillDetail.TARGET_TYPE.ENEMY, CombatSkillDetail.TARGET_TYPE.ENEMY_RANGE]
				if skillDetail.targetRange:
					$battlefield.targetRange = skillDetail.targetRange
				change_phase(TARGET)
				
		CombatDetail.ACTION_TYPE.DEFEND:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		CombatDetail.ACTION_TYPE.FLEE:
			change_phase(BATTLING)
			event_queue.append(eventBuilder)
		CombatDetail.ACTION_TYPE.MOVE:
			if eventBuilder.has('targetPosition') and eventBuilder['targetPosition']:
				# check valid location
				if not getEntityAtPosition(eventBuilder['targetPosition'].x, eventBuilder['targetPosition'].y, eventBuilder['entity'].is_enemy):
					event_queue.append(eventBuilder)
					change_phase(BATTLING)
				# invalid location
				else:
					eventBuilder.erase('targetPosition')
			else:
				$battlefield.is_select_enemy = false
				change_phase(TARGET)

func change_phase(new_phase : int):
	#	show and hide UI elements depending on phase of control flow
	match new_phase:
		PLANNING:
			$combatUI.release_focus()
			$combatUI.make_inactive()
			$battlefield.grab_focus()
			$battlefield.is_select_enemy = false
		TURNSTART:
			$combatUI.make_active(eventBuilder['entity'])
			$battlefield.release_focus()
		TARGET:
			$combatUI.release_focus()
			$battlefield.grab_focus()
		BATTLING:
			$combatUI.make_inactive()
			$combatUI.reset()
			$combatUI.release_focus()
			$battlefield.release_focus()
	current_phase = new_phase

func getEntityAtPosition(x: int, y: int, is_enemy: bool) -> CombatEntity:
	if not is_enemy:
		for player in get_players():
			if player.x == x and player.y == y:
				return player
	else:
		for enemy in get_enemies():
			if enemy.x == x and enemy.y == y:
				return enemy
	return null

func get_enemies() -> Array[CombatEntity]:
	var result : Array[CombatEntity] = []
	for c in $combatants.get_children():
		if c.is_enemy:
			result.append(c)
	return result
	
func get_players() -> Array[CombatEntity]:
	var result : Array[CombatEntity] = []
	for c in $combatants.get_children():
		if !c.is_enemy:
			result.append(c)
	return result
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Combat initiated with player characters: ")
	$battlefield.onSelect.connect(_on_grid_selected)
	$battlefield.onCancel.connect(_on_grid_cancel)
	$combatUI/actionmenu.userInput.connect(_on_user_input_selected)
	turn_queue_updated.connect($combatUI.on_turn_queue_change)

	for entity in $combatants.get_children():
		entity.damage_taken.connect(_on_damage_taken)
		entity.entity_death.connect(_on_entity_death)
	
	for entity in get_players():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity)
		$combatUI.add_entity(entity, false)
		#entity.skills.append(preload("res://scenes/combat/skills/skills_list/heal.gd").new())
		#entity.skills.append(load("res://scenes/combat/skills/skills_list/fire_t1.gd").new())
		#entity.skills.append(preload("res://scenes/combat/skills/skills_list/fire_t2.gd").new())
		#entity.skills.append(preload("res://scenes/combat/skills/skills_list/silence.gd").new())
		#entity.skills.append(preload("res://scenes/combat/skills/skills_list/shove.gd").new())
		
	print("...and enemy characters: ")
	for entity in get_enemies():
		print("\n" + entity.name + ' [' + str(entity.current_hp) + "/" + str(entity.hp) + "]")
		$battlefield.add_entity(entity)
		$combatUI.add_entity(entity, true)
	process_turn_queue()
	
func _on_damage_taken(entity : CombatEntity, dmg : int) -> void:
	if not entity.is_enemy:
		$combatUI.update_party_bar()
	$combatUI.dmg_text(entity, dmg)
	
func _on_entity_death(entity : CombatEntity) -> void:
	turn_queue.erase(entity)
	entity.queue_free()
	turn_queue_updated.emit(turn_queue)
	check_combat_end()
	
# checks if all players or enemies are dead
func check_combat_end() -> void:
	var player_wipe = true
	for player in get_players():
		if player.current_hp > 0:
			player_wipe = false
	var enemy_wipe = true
	for enemy in get_enemies():
		if enemy.current_hp > 0:
			enemy_wipe = false
	if player_wipe:
		current_phase = END
		print("Party was defeated!")
	if enemy_wipe:
		current_phase = END
		print("Victory!")
		
		
static func init(entities : Array[CombatEntity]) -> Combat3D:
	var node : Combat3D = scene.instantiate()
	for entity in entities:
		node.get_node("combatants").add_child(entity)
		print(entity)
	return node
