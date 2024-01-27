extends Label3D

const float_speed := .5

func _ready():
	var timer := get_tree().create_timer(2)
	timer.timeout.connect(queue_free)

func set_damage(amount: int):
	text = str(amount)

func _physics_process(delta):
	position += Vector3.UP * delta * float_speed
