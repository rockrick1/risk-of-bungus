extends PlayerMovementState

const AIR_CONTROL := 2

func enter():
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO

func physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y).normalized()

	player.velocity.y -= player.gravity * delta

	var h_speed := cc.run_speed
	player.velocity.x += move_direction.x * h_speed * delta * AIR_CONTROL
	player.velocity.x = clamp(-h_speed, player.velocity.x, h_speed)
	player.velocity.z += move_direction.z * h_speed * delta * AIR_CONTROL
	player.velocity.z = clamp(-h_speed, player.velocity.z, h_speed)
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	if player.is_on_floor():
		player.snap_vector = Vector3.DOWN
		
		if move_direction == Vector3.ZERO:
			transitioned.emit(self, "idle")
		elif Input.is_action_pressed("run"):
			transitioned.emit(self, "running")
		else:
			transitioned.emit(self, "walking")
	elif player.is_on_wall_only() and Input.is_action_pressed("run"):
		transitioned.emit(self, "wallrunning")
	
	super.physics_process(delta)
