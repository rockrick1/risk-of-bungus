extends PlayerMovementState

@export var fall_gravity_multiplier := .15
@export var walljump_force_multiplier := 1.0
@export var break_force := 5.0

var move_direction : Vector3

func enter(params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "grounded")
	move_direction = params["move_direction"]

func physics_process(delta):
	if player.is_on_floor():
		transitioned.emit(self, "idle")
		super.physics_process(delta)
		return
	
	var wall_normal = player.get_wall_normal()
	var wants_jump := Input.is_action_just_pressed("jump")
	var is_on_wall := player.is_on_wall_only()
	if wants_jump or not is_on_wall:
		if wants_jump:
			wall_normal.y = 1
			player.velocity = wall_normal * cc.base_jump_strength * walljump_force_multiplier
		transitioned.emit(self, "walljumping")
		super.physics_process(delta)
		return
	
	player.velocity.y -= player.gravity * delta * fall_gravity_multiplier
	
	move_direction = move_direction.lerp(Vector3.ZERO, delta * break_force)
	
	var h_speed := cc.run_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)
