extends Node3D

var interaction_label: Label3D
var player = null
var display_text = "Press F to pick up"
var detection_range = 1.5
var camera_rock
var is_picked_up = false

# Gravity-related variables
var velocity = Vector3.ZERO
var gravity = -9.8
var is_on_ground = false

func _ready():
	await get_tree().create_timer(0.1).timeout
	
	player = get_node("../Player")
	camera_rock = get_node("../Player/Camera3D/Rock")
	
	if camera_rock:
		camera_rock.visible = false
		print("Camera rock node found and initialized")
		
	if player:
		print("Player node found and initialized")
	
	interaction_label = Label3D.new()
	add_child(interaction_label)
	
	interaction_label.text = display_text
	interaction_label.position = Vector3(0, 1, 0)
	interaction_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	interaction_label.font_size = 12
	interaction_label.modulate = Color(1, 1, 1, 1)
	interaction_label.outline_size = 2
	interaction_label.outline_modulate = Color(0, 0, 0, 1)
	interaction_label.no_depth_test = true
	interaction_label.hide()

func get_drop_position():
	var camera = get_node("../Player/Camera3D")
	var from = camera.global_position
	var to = from + camera.global_transform.basis.z * -2.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	else:
		return from + camera.global_transform.basis.z * -1.5

func _physics_process(delta):
	if !player:
		return
		
	if !is_picked_up and !is_on_ground:
		velocity.y += gravity * delta
		global_position += velocity * delta
		
		if global_position.y <= 0:
			global_position.y = 0
			velocity.y = 0
			is_on_ground = true
	
	var distance = global_position.distance_to(player.global_position)
	if distance < detection_range and !is_picked_up:
		interaction_label.show()
	else:
		interaction_label.hide()

func _input(event):
	if !camera_rock or !player:
		return
		
	var distance = global_position.distance_to(player.global_position)
	if event.is_action_pressed("pickup"):
		if distance < detection_range and !is_picked_up:
			camera_rock.visible = true
			visible = false
			is_picked_up = true
			print("Picked up rock")
		elif is_picked_up:
			camera_rock.visible = false
			visible = true
			global_position = get_drop_position()
			is_picked_up = false
			velocity = Vector3.ZERO
			is_on_ground = false
			print("Dropped rock")
