extends Control

class_name PartyBarItem

var entity : CombatEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setEntity(x : CombatEntity) -> void:
	entity = x
	if entity:
		%namelabel.text = entity.name
	%sprite.texture = entity.headSprite
	updateHP()

func refresh() -> void:
	updateHP()
	updateMP()

func updateHP() -> void:
	if entity:
		%hplabel.text = "%d / %d" % [entity.current_hp, entity.hp]
		%hpbar.value = entity.current_hp
		%hpbar.min_value = 0
		%hpbar.max_value = entity.hp

func updateMP() -> void:
	if entity:
		%hplabel.text = "%d / %d" % [entity.current_hp, entity.hp]
		%hpbar.value = entity.current_hp
		%hpbar.min_value = 0
		%hpbar.max_value = entity.hp


func set_active(active : bool) -> void:
	if active:
		%partybarpanel.theme_type_variation = 'Panel_active'
		%namelabel.theme_type_variation = 'Label_active'
		%hplabel.theme_type_variation = 'Label_active'
		%profilePanelActive.show()
	else:
		%partybarpanel.theme_type_variation = ''
		%namelabel.theme_type_variation = ''
		%hplabel.theme_type_variation = ''
		%profilePanelActive.hide()
