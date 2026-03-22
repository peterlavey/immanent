extends Node3D

@onready var hardware_ui: CanvasLayer = $HardwareUI
@onready var monitor_screen: MeshInstance3D = $Monitor/Screen
@onready var godheads_camera: Camera3D = $GodheadsCamera
@onready var sub_viewport: SubViewport = $Monitor/SubViewport
@onready var room: Node3D = $Room
@onready var monitor: StaticBody3D = $Monitor
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun: DirectionalLight3D = $DirectionalLight3D

var is_zoomed_into_simulation: bool = false # Start in Godheads view
var genezis_world: Node3D = null
var genezis_camera: Camera3D = null
var is_world_initializing: bool = false

@onready var initial_camera_transform: Transform3D = godheads_camera.transform

func _ready() -> void:
	print("GodheadsWorld ready")
	add_to_group("godheads_world")
	# Show hardware UI when in Godheads view
	hardware_ui.show() 
	
	# Initial state: Godheads camera is current
	godheads_camera.make_current()
	
	# Load global simulation state (Hardware, Core progress) initially
	if SaveManager:
		SaveManager.load_game()
	
	# Switch monitor to Log mode by default
	monitor_screen.set_surface_override_material(0, load("res://src/core/godheads/GodheadsWorld.tscn::StandardMaterial3D_screen"))
	
	print("GodheadsWorld initialization finished")

func _on_genezis_zoom_limit_reached() -> void:
	# This should now be handled by HUD button or other means, 
	# but keeping it for compatibility if something else calls it.
	if SaveManager:
		SaveManager.save_game()
	get_tree().change_scene_to_file("res://src/core/godheads/GodheadsWorld.tscn")

func _transition_to_simulation() -> void:
	if is_world_initializing: return
	
	is_world_initializing = true
	print("[GodheadsWorld] Transitioning to Genezis World...")
	
	# Zoom godheads camera into the monitor before switching
	# Look at the screen specifically
	var screen_pos = monitor_screen.global_position
	var target_transform = godheads_camera.global_transform.looking_at(screen_pos)
	# Push forward towards screen
	var forward = -target_transform.basis.z
	target_transform.origin = screen_pos - forward * 0.4
	
	var tween = get_tree().create_tween()
	tween.tween_property(godheads_camera, "global_transform", target_transform, 0.8).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	if SaveManager:
		SaveManager.save_game()
	
	get_tree().change_scene_to_file("res://src/core/world/World.tscn")

func _on_monitor_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("Monitor clicked! Transitioning...")
			_transition_to_simulation()
	
	# Always push input to LogViewport when in godheads
	if has_node("Monitor/LogViewport"):
		$Monitor/LogViewport.push_input(event)
