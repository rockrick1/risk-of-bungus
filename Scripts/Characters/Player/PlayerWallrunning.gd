extends PlayerMovementState

@onready var fall_timer := $FallTimer

var player_direction_on_enter : Vector2

func enter():
	animator.set("parameters/ground_air_transition/transition_request", "grounded")
	fall_timer.start()
	
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y).normalized()
	player_direction_on_enter = Vector2(move_direction.x, move_direction.z)

func exit():
	fall_timer.stop()

func physics_process(delta):
	var wall_normal3 := player.get_wall_normal()
	
	if Input.is_action_just_pressed("jump"):
		player.velocity = Vector3(wall_normal3.x, 1, wall_normal3.z) * cc.base_jump_strength
		transitioned.emit(self, "jumping")
		super.physics_process(delta)
		return
	if not player.is_on_wall_only():
		transitioned.emit(self, "idle")
		super.physics_process(delta)
		return
	
	var move_direction := Vector3.ZERO
	var wall_normal := Vector2(wall_normal3.x, wall_normal3.z)
	var angle = player_direction_on_enter.angle_to(wall_normal)
	if angle >= 0 and angle <= PI:
		move_direction = wall_normal3.rotated(Vector3.UP, PI/2).normalized()
	else:
		move_direction = wall_normal3.rotated(Vector3.UP, -PI/2).normalized()
	move_direction.y = 0
	
	if fall_timer.is_stopped():
		player.velocity.y -= player.gravity * delta * .3
	else:
		player.velocity.y = 0

	var h_speed := cc.run_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	if Input.is_action_just_pressed("jump"):
		transitioned.emit(self, "jumping")
	elif move_direction == Vector3.ZERO:
		transitioned.emit(self, "idle")
	
	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)
