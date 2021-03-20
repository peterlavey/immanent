class_name Background extends Node2D

var background:Sprite = Sprite.new()
var image_url: String

func _init(image_url):
	self.image_url = image_url
	config_background()

func config_background()-> void:
	background.texture = load(image_url)
	background.centered = false
	
	add_child(background)
