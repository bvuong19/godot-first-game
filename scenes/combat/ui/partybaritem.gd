extends Control

class_name PartyBar

const scene : PackedScene = preload("res://scenes/combat/ui/partybaritem3.tscn")
var entity : CombatEntity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_active(false)
	pass # Replace with function body.

func refresh() -> void:
	%nametag.set_text("[b][i]%s" % entity.name)
	updateHP()
	updateMP()

func updateMP() -> void:
	if entity:
		if entity.mp > 0:
			%mpbar/label.set_text("[b]" + str(entity.mp) + " / " + str(entity.current_mp))
			%mpbar.value = entity.current_mp
			%mpbar.min_value = 0
			%mpbar.max_value = entity.mp
		else:
			%mpbar.hide()


func updateHP() -> void:
	if entity:
		%hpbar.value = entity.current_hp
		%hpbar.min_value = 0
		%hpbar.max_value = entity.hp

		var label : String = "[b]" + str(entity.hp) + " / " + str(entity.current_hp)
		%hpbar/label.set_text(label)
		print(label)

func set_active(active : bool) -> void:
	pass
	#if active:
		#%partybarpanel.theme_type_variation = 'Panel_active'
		#%namelabel.theme_type_variation = 'Label_active'
		#%hplabel.theme_type_variation = 'Label_active'
		#%profilePanelActive.show()
	#else:
		#%partybarpanel.theme_type_variation = ''
		#%namelabel.theme_type_variation = ''
		#%hplabel.theme_type_variation = ''
		#%profilePanelActive.hide()

static func from_Entity(entity : CombatEntity) -> PartyBar:
	var node : PartyBar = scene.instantiate()
	node.entity = entity
	node.refresh()
	#node.get_node("%sprite").texture = entity.headSprite
	#entity.on_changed.connect(update_ui)
	node.scale = Vector2(0.5,0.5)
	return node
	
