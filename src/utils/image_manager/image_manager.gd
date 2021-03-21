class_name ImageManager extends BaseNode

var Background = load("res://src/utils/image_manager/background.gd")
var images: Array
var images_loaded: Array
var current: int = 0
var transition: Transition

func _init(images):
	transition = Load.src("utils/image_manager/transition.gd")
	
	self.images = images
	load_images()
	config_transition()
	pass

func next()-> void:
	if current < images_loaded.size():
		transition.speed = 8
		transition.light_to_dark_to_light()

func show_next_image()-> void:
	remove_child(images_loaded[current])
	current += 1
	add_child(images_loaded[current])	

func load_images()-> void:
	for i in images.size():
		images_loaded.append(Background.new(images[i]))
	show_first()

func show_first()-> void:
	add_child(images_loaded[0])

func config_transition()-> void:
	transition.connect("on_blackout", self, "show_next_image")
	add_child(transition)
