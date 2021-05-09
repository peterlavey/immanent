class_name EvolutionTest extends BaseNode

var Benign = load("res://src/mechanics/role/player/benign.gd")
var players: Array
var actions = load("res://src/mechanics/role/player/actions.gd").new()
var stage

func _init():
	stage = load("res://src/mechanics/role/stage/theWay.gd").new()

func start()-> void:
	add_stage()
	add_players()
	add_huds()

func add_stage()-> void:
	add_child(stage)

func add_players()-> void:
	var player1 = Benign.new()
	
	player1.id = 1
	player1.nickname = "Peter"
	add_child(player1)
	
	players = get_tree().get_nodes_in_group("players")

func config_signals()-> void:
	for player in players:
		player.connect("set_position", self, "set_position")

func set_position(position, que=true):
	print("emited")
	if stage.terrain[position.y][position.x] == 0:
		players[0].position = position
		print(players[0].position)

#todo: aca hay que pasarle el player que este de turno
func add_huds()-> void:
	add_actions()

func add_actions()-> void:
	actions.player = players[0]
	actions.stage = stage
	add_child(actions)
