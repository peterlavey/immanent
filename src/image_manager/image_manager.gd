class_name ImageManager extends Node2D

var background = load("res://src/image_manager/background.gd").new("res://assets/prologue/1.png")

func _init():
	config_background()
	pass

func config_background()-> void:
	add_child(background)
