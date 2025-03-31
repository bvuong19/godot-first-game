extends Control

class_name PartyBarItem

var entity : CombatEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_children())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setEntity(x : CombatEntity) -> void:
	entity = x
	if entity:
		%namelabel.text = entity.name
	updateHP()

func updateHP() -> void:
	if entity:
		%hplabel.text = "%d / %d" % [entity.current_hp, entity.hp]
		%hpbar.value = entity.current_hp
		%hpbar.max_value = entity.hp
