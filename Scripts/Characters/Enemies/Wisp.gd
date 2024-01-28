extends BaseEnemy

var vector2player : Vector3

func _physics_process(delta):
	vector2player = (global_position - player.global_position).normalized()
	look_at(player.global_position)
	move_and_collide(-vector2player * character_component.walk_speed * delta * Vector3(1, 0.15, 1))
