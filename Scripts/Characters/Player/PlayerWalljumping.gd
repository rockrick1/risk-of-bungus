extends PlayerMovementState

@export var start_air_control := 2
@export var end_air_control := 5
@export var air_control_transition_time := .5

var state_time := .0

func enter():
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO
	state_time = 0

func physics_process(delta):
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y).normalized()

	player.velocity.y -= player.gravity * delta
	state_time += delta
	
	var air_control = lerp(start_air_control, end_air_control, state_time / air_control_transition_time)
	air_control = clamp(air_control, start_air_control, end_air_control)
	print(air_control)

	var h_speed := cc.run_speed
	player.velocity.x += move_direction.x * h_speed * delta * air_control
	player.velocity.x = clamp(player.velocity.x, -h_speed, h_speed)
	player.velocity.z += move_direction.z * h_speed * delta * air_control
	player.velocity.z = clamp(player.velocity.z, -h_speed, h_speed)
	
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
