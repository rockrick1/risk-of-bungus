extends PlayerMovementState

func enter(_params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "grounded")

func physics_process(delta):
	var wants_jump := Input.is_action_just_pressed("jump")
	var is_on_floor := player.is_on_floor()
	if wants_jump or not is_on_floor:
		var params := PlayerAirborneState.Params.new()
		if wants_jump:
			params.jump_force = Vector3.UP * cc.base_jump_strength
		transitioned.emit(self, "airborne", { airborne_params = params })
		super.physics_process(delta)
		return
	
	var move_direction = get_movement_direction()
	
	player.velocity.y -= player.gravity * delta

	var h_speed := cc.walk_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.mesh.rotation.y = lerp_angle(player.mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	if move_direction == Vector3.ZERO:
		transitioned.emit(self, "idle")
	elif Input.is_action_pressed("run"):
		transitioned.emit(self, "running")
	
	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)
