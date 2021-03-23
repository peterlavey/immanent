class_name Responsive extends GDScript

static func sprite(img: Sprite, percentage = 100)-> Sprite:
	var viewportWidth: int = OS.get_window_size().x
	var viewportHeight: int = OS.get_window_size().y
	var scaleWidth = viewportWidth / img.texture.get_size().x
	var scaleHeight = viewportHeight / img.texture.get_size().y
	img.set_scale(Vector2(percentage(scaleWidth, percentage), percentage(scaleHeight, percentage)))
	return img

static func percentage(base: float, percentage: float)-> float:
	return base * percentage / 100
