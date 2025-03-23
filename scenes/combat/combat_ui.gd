extends Control

var activeCombatEntity = null
signal userInput(Dictionary)

var buttons = ['%ATTACK', '%SKILL', '%DEFEND', '%MOVE', '%ITEM', '%FLEE']
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	userInput.connect(get_parent()._on_user_input_selected)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func dmg_text(entity: CombatEntity, post_mit_dmg: int) -> void:
	var dmgTextLabel = DamageText.new()
	dmgTextLabel.position = entity.position
	add_child(dmgTextLabel)

func make_active(entity : CombatEntity) -> void:
	show()
	$actionmenu.show()
	$actionmenu.get_node('%ATTACK').grab_focus()
	activeCombatEntity = entity

func make_inactive() -> void:
	$actionmenu.release_focus()
	
func reset() -> void:
	#%MOVE._toggled(false)
	for b in buttons:
		$actionmenu.get_node(b).set_pressed(false)
		#b._toggled(false)

func _on_attack_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.ATTACK})

func _on_move_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.MOVE})

func _on_defend_pressed() -> void:
	userInput.emit({"entity": activeCombatEntity, "type": Combat_Action.DEFEND})
