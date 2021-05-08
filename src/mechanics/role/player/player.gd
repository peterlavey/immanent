class_name RolePlayer extends Node2D

var speed: int = 1
var movementRange: int
var currentPosition: Vector2 = Vector2(0, 0)
var texture
var CONFIG = load("res://src/mechanics/role/constants/config.gd").new()
var movementRangeImage = load("res://src/mechanics/role/assets/tile-purple-alpha.png")

export var id: int = 0
export var nickname: String = ""
#enum LINEAGE {WARRIOR, WIZARD}
enum {UP, RIGHT, DOWN, LEFT}

func _ready():
	add_to_group("players")

func _draw():
	set_texture()

func set_texture()-> void:
	draw_texture(texture, currentPosition)

#todo: SPEED * ALGUN BUFF QUE TENGA EN DECIMALES PARA SIMULAR PORCENTAJE
func move(direction):
	print(direction)
	var currentPosition: Vector2 = position
	match direction:
		UP:
			currentPosition.y += speed
		RIGHT:
			currentPosition.x += speed
		DOWN:
			currentPosition.y -= speed
		LEFT:
			currentPosition.x -= speed
	emit_signal("set_position", currentPosition)
