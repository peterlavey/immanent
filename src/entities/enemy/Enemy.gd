extends CharacterBody3D

class_name Enemy

enum State { IDLE, MOVING_TO_TARGET, PERFORMING_ACTION, ESCAPING }

@export var move_speed: float = 3.0
@export var health: float = 1.0
@export var defragmentation_scene: PackedScene = preload("res://src/entities/enemy/defragmentation_effect/DefragmentationEffect.tscn")

var current_state: State = State.IDLE
var target: Node3D = null

func _ready() -> void:
	add_to_group("enemies")
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		# Use G2 sfx for enemy arrival but lower volume and higher pitch for creepiness
		audio_manager.play_sfx("res://assets/audio/sfx/G2.mp3", -10.0)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_find_target()
		State.MOVING_TO_TARGET:
			if is_instance_valid(target):
				_move_towards_target(delta)
			else:
				current_state = State.IDLE
		State.PERFORMING_ACTION:
			_perform_action(delta)

func _find_target() -> void:
	# Overridden by subclasses
	pass

func _move_towards_target(delta: float) -> void:
	if not target: return
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * move_speed
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	move_and_slide()
	
	if global_position.distance_to(target.global_position) < 1.0:
		current_state = State.PERFORMING_ACTION

func _perform_action(_delta: float) -> void:
	# Overridden by subclasses
	pass

func take_damage(amount: float) -> void:
	health -= amount
	# Visual feedback: flash red
	var mesh = $MeshInstance3D
	if mesh:
		var mat = mesh.get_surface_override_material(0)
		if mat:
			var tween = get_tree().create_tween()
			tween.tween_property(mat, "albedo_color", Color.WHITE, 0.05)
			tween.tween_property(mat, "albedo_color", Color.RED, 0.05)
	
	if health <= 0:
		_disperse()

func _disperse() -> void:
	if defragmentation_scene:
		var effect = defragmentation_scene.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		# Higher pitch sfx for dispersal
		audio_manager.play_sfx("res://assets/audio/sfx/G1.mp3", -5.0)
		
	queue_free()
