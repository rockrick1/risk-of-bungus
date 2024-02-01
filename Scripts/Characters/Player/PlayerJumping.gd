extends PlayerMovementState

func enter(_params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO

func physics_process(delta):
	var move_direction = get_movement_direction()

	player.velocity.y -= player.gravity * delta

	var h_speed : float
	if Input.is_action_pressed("run"):
		h_speed = cc.run_speed
	else:
		h_speed = cc.walk_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
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
