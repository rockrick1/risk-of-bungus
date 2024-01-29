extends PlayerMovementState

func enter():
	animator.set("parameters/ground_air_transition/transition_request", "grounded")

func physics_process(delta):
	var wants_jump := Input.is_action_just_pressed("jump")
	var is_on_floor := player.is_on_floor()
	if wants_jump or not is_on_floor:
		if wants_jump:
			player.velocity.y = cc.base_jump_strength
		transitioned.emit(self, "jumping")
		super.physics_process(delta)
		return

	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	player.velocity.y -= player.gravity * delta

	var h_speed := cc.walk_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jumping")
	elif move_direction == Vector3.ZERO:
		transitioned.emit(self, "idle")
	elif Input.is_action_pressed("run"):
		transitioned.emit(self, "running")
	
	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)
