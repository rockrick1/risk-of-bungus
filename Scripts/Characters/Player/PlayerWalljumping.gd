extends PlayerMovementState

@export var start_air_control := 2
@export var end_air_control := 5
@export var air_control_transition_time := .5

var air_control : float
var air_control_tween : Tween

func enter(_params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO
	setup_air_control()

func setup_air_control():
	air_control = start_air_control
	if air_control_tween:
		air_control_tween.kill()
	air_control_tween = create_tween()
	air_control_tween.tween_property(self, "air_control", end_air_control, air_control_transition_time)

func physics_process(delta):
	var move_direction = get_movement_direction()

	player.velocity.y -= player.gravity * delta
	
	var h_speed := cc.run_speed
	player.velocity.x += move_direction.x * h_speed * delta * air_control
	player.velocity.x = clamp(player.velocity.x, -h_speed, h_speed)
	player.velocity.z += move_direction.z * h_speed * delta * air_control
	player.velocity.z = clamp(player.velocity.z, -h_speed, h_speed)
	
	if move_direction:
		player.mesh.rotation.y = lerp_angle(player.mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
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
