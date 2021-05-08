class_name Benign extends RolePlayer

func _init():
	set_images()
	set_initial_stats()

func set_images()-> void:
	texture = load("res://src/mechanics/role/assets/token.png")

func set_initial_stats()-> void:
	speed = 1
	movementRange = 2
