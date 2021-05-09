class_name Game extends BaseNode

var prologue: Prologue
var terminal: Terminal

func _init():
	prologue = Load.src("scenes/prologue/prologue")
	

func _ready():
	init_prologue()

func init_prologue():
	add_child(prologue)
	prologue.connect("next", self, "next")
	prologue.start()

func next():
	print("next")
	remove_child(prologue)
	terminal = Load.src("scenes/evolution/terminal")
	add_child(terminal)
