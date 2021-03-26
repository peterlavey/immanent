class_name ImageManager extends BaseNode

var Picture
var images: Array
var images_loaded: Array
var current: int = 0
var transition: Transition
var options

func _init(images, options = false):
	self.options = options
	Picture = Load.ref("utils/image_manager/picture")
	transition = Load.src("utils/image_manager/transition")
	self.images = images

func _ready():
	load_images()
	config_transition()

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
		var image = config_image(Picture.new(images[i])) if options else Picture.new(images[i])
		images_loaded.append(image)
	show_first()

func show_first()-> void:
	add_child(images_loaded[0])

func config_transition()-> void:
	transition.connect("on_blackout", self, "show_next_image")
	add_child(transition)

func config_image(image):
	image.set_percentage(options.scale)
	image.set_h_align(options.h_align)
	image.set_v_align(options.v_align)
	image.set_padding(options.padding)
	return image
