class_name ImageManager extends Node2D

var Background = load("res://src/utils/image_manager/background.gd")
var images: Array
var images_loaded: Array
var current: int = 0

func _init(images):
	self.images = images
	load_images()
	pass

func next()-> void:
	if current < images_loaded.size():
		remove_child(images_loaded[current])
		current += 1
		add_child(images_loaded[current])

func back()-> void:
	if current > 0:
		remove_child(images_loaded[current])
		current -= 1
		add_child(images_loaded[current])

func load_images()-> void:
	for i in images.size():
		images_loaded.append(Background.new(images[i]))
	show_first()

func show_first()-> void:
	add_child(images_loaded[0])
