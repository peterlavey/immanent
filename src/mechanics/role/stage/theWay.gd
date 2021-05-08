class_name TheWay extends Stage

func _init():
	init_terrain()

func init_terrain()-> void:
	terrain = [
		[B, B, B, B, B, B, B, B, B, B, B, W, B, B, B, B, W, B, B, B, B, B, B, B, B, B, B, B, B, B, B],
		[B, B, B, B, B, B, B, B, B, B, B, W, B, B, B, B, W, B, B, B, W, B, B, B, B, B, W, B, B, B, B],
		[B, B, B, B, B, B, W, B, B, B, B, W, B, B, B, B, B, B, B, B, B, B, W, B, B, B, W, B, B, B, B],
		[B, B, B, B, B, B, W, B, B, B, B, W, B, B, B, B, W, B, B, B, B, B, W, B, B, B, W, B, B, B, B],
		[B, B, B, B, B, B, W, B, B, B, B, B, B, B, B, B, W, B, B, B, B, B, B, B, B, B, W, B, B, B, B]
	]
