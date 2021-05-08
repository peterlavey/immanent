class_name Game extends BaseNode

var prologue: Prologue
var evolution: Evolution

func _init():
	evolution = Load.src("scenes/evolution/evolution")

func _ready():
	add_child(evolution)
	evolution.start()
