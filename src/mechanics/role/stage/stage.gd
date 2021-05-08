class_name Stage extends Node2D

var terrain: Array = [1, 3, "asd", 3]
var tileGreen = load("res://src/mechanics/role/assets/tile-green.png")
var tileGray = load("res://src/mechanics/role/assets/tile-gray.png")
var CONFIG = load("res://src/mechanics/role/constants/config.gd").new()
enum {
	B = 0,
	W = 1
}

func _draw():
	draw_terrain()

func draw_terrain():
	var tile
	for i in terrain.size():
		for j in terrain[i].size():
			match terrain[i][j]:
				B:
					tile = tileGreen
				W:
					tile = tileGray
			draw_texture(tile, Vector2(CONFIG.TILE_SIZE * j, CONFIG.TILE_SIZE * i))
