extends PlayerMovementState

func enter(_params: Dictionary):
	player.velocity = Vector3.ZERO
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
	
	var move_direction = get_movement_direction()
	
	player.velocity.y -= player.gravity * delta
	
	if move_direction != Vector3.ZERO:
		if Input.is_action_pressed("run"):
			transitioned.emit(self, "running")
		else:
			transitioned.emit(self, "walking")

	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)
