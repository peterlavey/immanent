class_name Game extends BaseNode

var prologue: Prologue
var evolution_first: EvolutionFirst

func _init():
	prologue = Load.src("scenes/prologue/prologue")
	

func _ready():
	init_evolution_first()

func init_prologue():
	add_child(prologue)
	prologue.connect("next", self, "init_evolution_first")
	prologue.start()

func init_evolution_first():
	remove_child(prologue)
	evolution_first = Load.src("scenes/evolution/evolutionFirst")
	add_child(evolution_first)
	evolution_first.start()
