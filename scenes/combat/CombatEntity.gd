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
@export var spd = 0

@export var current_hp = 0
@export var headSprite : Texture2D = preload("res://assets/defaultplayer-portrait.png")
@export var isEnemy = true

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(300,300)
	current_hp = hp 
	$battlefieldSprite/HPLabel.text = "%s/%s" % [str(current_hp), str(hp)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func damage_number(dmg : int) -> void:
	var textDmg = Label.new()
	textDmg.text = "-" + str(dmg) + "!"
	textDmg.add_theme_color_override("", Color.BLACK)
	$battlefieldSprite.add_child(textDmg)
