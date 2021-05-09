class_name Danger extends BaseNode

var dangerParticle

func _init():
	dangerParticle = Load.particle("particles/danger")
	dangerParticle.process_material.scale = 3
	add_child(dangerParticle)
	danger_top()

func danger_top():
	var screen_weigth = OS.get_window_size().x
	dangerParticle.process_material.set_emission_box_extents(Vector3(screen_weigth, 0, 0))
	dangerParticle.position = Vector2(screen_weigth * 0.5, 0)
	dangerParticle.process_material.set_gravity(Vector3(0, 500, 0))

func danger_bottom():
	var screen_weigth = OS.get_window_size().x
	var screen_height = OS.get_window_size().y
	dangerParticle.process_material.set_emission_box_extents(Vector3(screen_weigth, 0, 0))
	dangerParticle.position = Vector2(screen_weigth * 0.5, screen_height)
	dangerParticle.process_material.set_gravity(Vector3(0, -500, 0))

func danger_left():
	var screen_weigth = OS.get_window_size().x
	var screen_height = OS.get_window_size().y
	dangerParticle.process_material.set_emission_box_extents(Vector3(0, screen_height, 0))
	dangerParticle.position = Vector2(0, screen_height * 0.5)
	dangerParticle.process_material.set_gravity(Vector3(500, 0, 0))
	
func danger_right():
	var screen_weigth = OS.get_window_size().x
	var screen_height = OS.get_window_size().y
	dangerParticle.process_material.set_emission_box_extents(Vector3(0, screen_height, 0))
	dangerParticle.position = Vector2(screen_weigth, screen_height * 0.5)
	dangerParticle.process_material.set_gravity(Vector3(-500, 0, 0))
