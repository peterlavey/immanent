extends BaseNode

var world: Node
var game: Game

func _init():
	game = Load.src("game/game")

func _ready():
	config_world()

func config_world()-> void:
	world = Node.new()
	add_child(world)
	
	init_game()

func init_game()-> void:
	world.add_child(game)
