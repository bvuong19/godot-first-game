extends Control

var activeCombatEntity = null
signal userInput(Dictionary)

var damagetext = preload('res://scenes/combat/damage_text.tscn')
var partyBarItem = preload('res://scenes/combat/ui/partybar.tscn')
var buttons = ['%ATTACK', '%SKILL', '%DEFEND', '%MOVE', '%ITEM', '%FLEE']
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
func initialize_turn_queue(turn_queue : Array[CombatEntity]) -> void:
	for e in turn_queue:
		var turnqueuechild = TextureRect.new()
		turnqueuechild.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		turnqueuechild.size = Vector2(40,40)
		turnqueuechild.texture = e.headSprite
		%turnqueue.add_child(turnqueuechild)

func next_turn_queue() -> void:
	%turnqueue.remove_child(%turnqueue.get_child(0))

func add_entity(entity : CombatEntity, isEnemy: bool) -> void:
	if not isEnemy:
		var item = partyBarItem.instantiate()
		item.setEntity(entity)
		$partybarcontainer/partybar.add_child(item)
	#print($partybarcontainer/partybar.get_children())
	
func update_party_bar() -> void:
	for party in %partybar.get_children():
		party.updateHP()

func dmg_text(entity: CombatEntity, post_mit_dmg: int) -> void:
	var dmgTextLabel = damagetext.instantiate()
	dmgTextLabel.set_damage(post_mit_dmg)
	entity.add_child(dmgTextLabel)

func make_active(entity : CombatEntity) -> void:
	$actionmenu.show()
	$actionmenu.get_node('%ATTACK').grab_focus()
	activeCombatEntity = entity
	$actionmenu.initialize_menu(entity)

func make_inactive() -> void:
	$actionmenu.release_focus()
	$actionmenu.hide()
	
func reset() -> void:
	for b in buttons:
		$actionmenu.get_node(b).set_pressed(false)

func _on_attack_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.ATTACK})

func _on_move_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.MOVE})

func _on_defend_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.DEFEND})

func _on_skill_pressed() -> void:
	pass
	
func _on_skill_selected() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.SKILL, "skill_detail": {}})
