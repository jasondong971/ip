extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@onready var camera_pivot: Node3D = $CameraPivot

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _pitch: float = 0.0

func _ready() -> void:
	_register_input()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _register_input() -> void:
	_register_action("move_forward", Key.W)
	_register_action("move_back", Key.S)
	_register_action("move_left", Key.A)
	_register_action("move_right", Key.D)
	_register_action("jump", Key.SPACE)

func _register_action(action_name: String, key: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var key_event := InputEventKey.new()
	key_event.keycode = key
	if not InputMap.action_has_event(action_name, key_event):
		InputMap.action_add_event(action_name, key_event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		_pitch = clamp(_pitch - event.relative.y * mouse_sensitivity, -1.2, 1.2)
		camera_pivot.rotation.x = _pitch
		return

	if event is InputEventKey and event.pressed and event.keycode == Key.ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x
	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	move_and_slide()
