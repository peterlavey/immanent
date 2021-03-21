class_name Game extends BaseNode

var prologue: Prologue

func _init():
	prologue = Load.src("scenes/prologue/prologue.gd")

func _ready():
	add_child(prologue)
	prologue.start()
