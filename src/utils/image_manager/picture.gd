class_name Picture extends Sprite

var image_url: String
var POSITION = {
	"TOP": 1,
	"RIGHT": 2,
	"DOWN": 3,
	"LEFT": 4
}

func _init(image_url):
	self.image_url = image_url
	config_background()

func config_background()-> void:
	texture = load(image_url)
	centered = false

func set_percentage(scale):
	return Responsive.sprite(self, scale)
