class_name Picture extends Sprite

var image_url: String
var POSITION = {
	"CENTER": 0,
	"TOP": 1,
	"RIGHT": 2,
	"DOWN": 3,
	"LEFT": 4
}
var width: float
var height: float
var screen_width = OS.get_window_size().x
var screen_height = OS.get_window_size().y

func _init(image_url):
	self.image_url = image_url
	config_background()

func config_background()-> void:
	texture = load(image_url)
	centered = false

func set_percentage(scale)-> void:
	var picture_scale = Responsive.sprite(self, scale)
	width = texture.get_width() * picture_scale.x
	height = texture.get_height() * picture_scale.y
	set_scale(picture_scale)

func set_h_align(_position)-> void:
	if _position == POSITION.LEFT:
		position.x = 0
	elif _position == POSITION.CENTER:
		position.x = (screen_width * .5) - (width * .5)
	elif _position == POSITION.RIGHT:
		position.x = screen_width - width

func set_v_align(_position)-> void:
	if _position == POSITION.TOP:
		position.y = 0
	elif _position == POSITION.CENTER:
		position.y = (screen_height * .5) - (height * .5)
	elif _position == POSITION.DOWN:
		position.y = screen_height - height

func set_padding(padding)-> void:
	if position.x == 0:
		position.x += padding
	elif position.x == screen_width - width:
		position.x -= padding
	
	if position.y == 0:
		position.y += padding
	elif screen_height - height:
		position.y -= padding
