extends CharacterBody3D

signal selected(genezis: CharacterBody3D)

enum State { PATROL, PROTECT_CORE, PROTECT_G1, INTERCEPT_THREAT, ATTACKING }

@export var move_speed: float = 8.0
@export var patrol_radius: float = 15.0
@export var detection_radius: float = 10.0
@export var attack_damage: float = 1.0
@export var projectile_scene: PackedScene = preload("res://src/entities/G2Projectile.tscn")
@export var attack_cooldown: float = 0.5

var current_state: State = State.PATROL
var core_node: Node3D = null
var target_to_protect: Node3D = null
var threat_target: Node3D = null
var patrol_target: Vector3 = Vector3.ZERO
var _wait_timer: float = 0.0
var _attack_timer: float = 0.0

func _ready() -> void:
	add_to_group("genezis_g2")
	# Find core
	var cores = get_tree().get_nodes_in_group("core")
	if cores.size() > 0:
		core_node = cores[0]
	
	_set_new_patrol_target()

func _physics_process(delta: float) -> void:
	# Priority: Detect threats
	_check_for_threats()
	
	match current_state:
		State.PATROL:
			if global_position.distance_to(patrol_target) < 1.0:
				_wait_timer += delta
				if _wait_timer > 2.0:
					_set_new_patrol_target()
					_wait_timer = 0.0
			else:
				move_towards(patrol_target, delta)
		
		State.PROTECT_CORE:
			if is_instance_valid(core_node):
				var target_pos = core_node.global_position + Vector3(0, 3, 0) # Float above core
				move_towards(target_pos, delta)
		
		State.PROTECT_G1:
			if is_instance_valid(target_to_protect):
				var target_pos = target_to_protect.global_position + Vector3(0, 1.5, 0)
				move_towards(target_pos, delta)
			else:
				current_state = State.PATROL
		
		State.INTERCEPT_THREAT:
			if is_instance_valid(threat_target):
				move_towards(threat_target.global_position, delta)
				if global_position.distance_to(threat_target.global_position) < 2.0:
					current_state = State.ATTACKING
			else:
				current_state = State.PATROL
		
		State.ATTACKING:
			if is_instance_valid(threat_target):
				_attack_threat(delta)
			else:
				current_state = State.PATROL

func _check_for_threats() -> void:
	if current_state == State.ATTACKING: return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest: Node3D = null
	var min_dist = detection_radius
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var d = global_position.distance_to(enemy.global_position)
			if d < min_dist:
				min_dist = d
				closest = enemy
	
	if closest:
		threat_target = closest
		current_state = State.INTERCEPT_THREAT

func _attack_threat(delta: float) -> void:
	if is_instance_valid(threat_target):
		_attack_timer += delta
		if _attack_timer >= attack_cooldown:
			_shoot()
			_attack_timer = 0.0
		
		# Face threat
		look_at(threat_target.global_position, Vector3.UP)
		# Maintain small distance
		if global_position.distance_to(threat_target.global_position) > 5.0:
			move_towards(threat_target.global_position, delta)
		elif global_position.distance_to(threat_target.global_position) < 3.0:
			# Back away slightly if too close
			var dir = (global_position - threat_target.global_position).normalized()
			move_towards(global_position + dir * 2.0, delta)
	else:
		threat_target = null
		current_state = State.PATROL

func _shoot() -> void:
	if not projectile_scene or not is_instance_valid(threat_target): return
	var p = projectile_scene.instantiate()
	get_parent().add_child(p)
	var dir = (threat_target.global_position - global_position).normalized()
	p.launch(global_position + dir * 1.0, dir)
	p.damage = attack_damage

func _set_new_patrol_target() -> void:
	var center = Vector3.ZERO
	if is_instance_valid(core_node):
		center = core_node.global_position
	
	var angle = randf() * TAU
	var elevation = randf_range(-PI/4, PI/4)
	var dist = randf() * patrol_radius
	patrol_target = center + Vector3(
		cos(angle) * cos(elevation) * dist,
		sin(elevation) * dist,
		sin(angle) * cos(elevation) * dist
	)

func move_towards(target_pos: Vector3, delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	move_and_slide()

func get_stats() -> Dictionary:
	return {
		"type": "Genezis G2",
		"speed": move_speed,
		"extraction": 0,
		"capacity": 0,
		"load": 0,
		"state": State.keys()[current_state]
	}

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
			get_viewport().set_input_as_handled()
