extends Node2D
class_name GridTile

func _animate_select() -> void:
	$Gridtile1.animation = "selected"
	

func _animate_unselect() -> void:
	$Gridtile1.animation = "default"

func _animate_confirm() -> void:
	$Gridtile1.animation = "confirm"
