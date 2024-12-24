extends CharacterBody3D

const WALK_SPEED = 4.5
const RUN_SPEED = 5.5
const CROUCH_SPEED = 2.0
const JUMP_VELOCITY = 2.5
const MOUSE_SENSITIVITY = 0.002
const ACCELERATION = 15.0
const DECELERATION = 10.0
const TILT_ANGLE = 15.0
const TILT_SPEED = 3.0
const STAND_HEIGHT = 1.0
const CROUCH_HEIGHT = 0.5
const TRANSITION_SPEED = 10.0

enum StanceState { STANDING, CROUCHING }

@onready var camera = $Camera3D
@onready var stamina_bar = $CanvasLayer/ProgressBar
@onready var footstep_player = AudioStreamPlayer3D.new()
@onready var collision_shape = $CollisionShape3D



var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = WALK_SPEED
var stamina = 100.0
var max_stamina = 100.0
var stamina_regen_rate = 10.0
var stamina_drain_rate = 20.0
var can_run = true
var is_running = false
var current_stance: StanceState = StanceState.STANDING
var footstep_timer = 0.0
var footstep_interval = 0.5
var is_footsteps_playing = false
var target_tilt = 0.0
var initial_camera_height = 0.0
var mouse_toggle : bool = false



	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -deg_to_rad(60), deg_to_rad(50))




func get_movement_direction():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# Get the forward and right vectors from the camera's basis
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	# Project these vectors onto the horizontal plane
	forward = Vector3(forward.x, 0, forward.z).normalized()
	right = Vector3(right.x, 0, right.z).normalized()
	
	# Combine the vectors based on input
	var direction = (right * input_dir.x + forward * input_dir.y)
	
	# Ensure the direction is normalized and horizontal
	if direction.length_squared() > 1:
		direction = direction.normalized()
	
	return direction

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_stance == StanceState.STANDING:
		velocity.y = JUMP_VELOCITY
	
	is_running = Input.is_action_pressed("run") and can_run and current_stance == StanceState.STANDING
	current_speed = CROUCH_SPEED if current_stance == StanceState.CROUCHING else (RUN_SPEED if is_running else WALK_SPEED)

	
	# Get movement direction using the new method
	var direction = get_movement_direction()
	var is_moving = direction.length() > 0
	
	# Apply horizontal movement
	if is_moving:
		velocity.x = lerp(velocity.x, direction.x * current_speed, ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, ACCELERATION * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = lerp(velocity.z, 0.0, DECELERATION * delta)
	
	move_and_slide()
	
