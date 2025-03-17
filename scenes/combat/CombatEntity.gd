extends Node2D

class_name CombatEntity



# unit's position on grid
@export var x = 0
@export var y = 0

# unit's base stats.
# TODO: add other stats that we think would be cool and poggers.
@export var atk = 0
@export var def = 0
@export var hp = 0

@export var current_hp = 0

# other
signal damage_taken(Node2D, float)


# apply incoming damage 
func apply_damage(dmg: float) -> void:
	var post_mit_dmg = dmg - def
	if (post_mit_dmg > 0):
		current_hp -= post_mit_dmg
	print(name + " took " + str(post_mit_dmg) + ", now has " + str(current_hp) + " HP")
	damage_taken.emit(self, post_mit_dmg)
	damage_number(post_mit_dmg)
	$battlefieldSprite/HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]
	
	if (current_hp <= 0):
		print(name + " has been defeated!")
		#queue_free()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	damage_taken.connect(get_parent().get_parent()._on_damage_taken)
	current_hp = hp 
	$battlefieldSprite/HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func damage_number(dmg : int) -> void:
	var textDmg = Label.new()
	textDmg.text = "-" + str(dmg) + "!"
	textDmg.add_theme_color_override("", Color.BLACK)
	$battlefieldSprite.add_child(textDmg)
