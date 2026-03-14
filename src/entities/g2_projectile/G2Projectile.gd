extends Area3D

@export var speed: float = 20.0
@export var damage: float = 1.0
@export var lifetime: float = 2.0

var _direction: Vector3 = Vector3.FORWARD
var _timer: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func launch(pos: Vector3, dir: Vector3) -> void:
	global_position = pos
	_direction = dir.normalized()
	if _direction != Vector3.ZERO:
		look_at(global_position + _direction, Vector3.UP)

func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()

func _on_area_entered(_area: Area3D) -> void:
	# For now we use body_entered for character bodies, but Area3D might be used for some targets.
	pass
