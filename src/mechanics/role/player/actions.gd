class_name Actions extends Node

var player
var stage
var CONFIG = load("res://src/mechanics/role/constants/config.gd").new()
const OUT_OF_INDEX = 99
enum DIRECTION {UP, RIGHT, DOWN, LEFT}

func _input(event)-> void:
	if Input.is_action_pressed("ui_up"):
		move_up()
	elif Input.is_action_pressed("ui_right"):
		move_right()
	elif Input.is_action_pressed("ui_down"):
		move_down()
	elif Input.is_action_pressed("ui_left"):
		move_left()

func move_up()-> void:
	move(DIRECTION.UP)

func move_right()-> void:
	move(DIRECTION.RIGHT)

func move_down()-> void:
	move(DIRECTION.DOWN)

func move_left()-> void:
	move(DIRECTION.LEFT)

#todo: SPEED * ALGUN BUFF QUE TENGA EN DECIMALES PARA SIMULAR PORCENTAJE
func move(direction)-> void:
	var currentPosition: Vector2 = player.position

	match direction:
		DIRECTION.UP:
			currentPosition.y -= player.speed * CONFIG.TILE_SIZE
		DIRECTION.RIGHT:
			currentPosition.x += player.speed * CONFIG.TILE_SIZE
		DIRECTION.DOWN:
			currentPosition.y += player.speed * CONFIG.TILE_SIZE
		DIRECTION.LEFT:
			currentPosition.x -= player.speed * CONFIG.TILE_SIZE

	if(validate_move(currentPosition)):
		player.position = currentPosition

func validate_move(position)-> bool:
	var tileCode = get_tile_code(position)
	return tileCode != OUT_OF_INDEX && tileCode != 1

func get_tile_code(position)-> int:
	var y = position.y / CONFIG.TILE_SIZE
	var x = position.x / CONFIG.TILE_SIZE
	var maxY = stage.terrain.size() - 1
	var maxX = stage.terrain[0].size() - 1
	
	if y <= maxY && x <= maxX:
		return stage.terrain[y][x]
	else:
		return OUT_OF_INDEX
