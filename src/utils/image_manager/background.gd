class_name Background extends BaseNode

var background:Sprite = Sprite.new()
var image_url: String
var responsive

func _init(image_url):
	self.image_url = image_url
	responsive = Load.src("utils/image_manager/responsive")
	config_background()

func config_background()-> void:
	background.texture = load(image_url)
	background.centered = false
	background = responsive.sprite(background, 60)
	
	add_child(background)


