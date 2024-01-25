extends Area3D

var target : Vector3 = Vector3.ZERO
const speed : float = 100

func _physics_process(delta):
	var distance := target - global_position
	var motion := distance.normalized()
	if target != Vector3.ZERO:
		position += (motion * speed * delta)

func _on_body_entered(body):
	print("hit")
	queue_free()

func _on_life_timer_timeout():
	queue_free()
