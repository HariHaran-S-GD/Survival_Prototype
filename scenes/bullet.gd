extends StaticBody3D

@export var speed = 30.0
@export var lifetime = 2.0

func _ready():
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_timeout)

func _physics_process(delta):
	position += -transform.basis.z * speed * delta

func _on_lifetime_timeout():
	queue_free()
 
