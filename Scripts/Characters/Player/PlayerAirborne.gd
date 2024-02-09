class_name PlayerAirborneState
extends PlayerMovementState

var air_control : float
var air_control_tween : Tween
var clamp_speed : bool

func enter(params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO
	var airborne_params : Params = params.airborne_params
	
	_setup_air_control(airborne_params)
	_setup_initial_velocity(airborne_params)
	
	clamp_speed = airborne_params.clamp_speed

func _setup_air_control(params: Params):
	air_control = params.start_air_control
	
	if params.end_air_control < 0:
		return
	
	if air_control_tween:
		air_control_tween.kill()
	air_control_tween = create_tween()
	air_control_tween.tween_property(self, "air_control",
			params.end_air_control, params.air_control_transition_time)

func _setup_initial_velocity(params: Params):
	if params.override_current_velocity:
		player.velocity = params.jump_force
	else:
		player.velocity += params.jump_force

func physics_process(delta):
	var move_direction = get_movement_direction()
	
	player.velocity.y -= player.gravity * delta
	
	var h_speed := cc.run_speed
	if air_control < 0:
		player.velocity.x = move_direction.x * h_speed
		player.velocity.z = move_direction.z * h_speed
	else:
		player.velocity.x += move_direction.x * h_speed * delta * air_control
		player.velocity.z += move_direction.z * h_speed * delta * air_control
		if clamp_speed:
			player.velocity.x = clamp(player.velocity.x, -h_speed, h_speed)
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

class Params:
	var clamp_speed : bool = true
	var jump_force : Vector3 = Vector3.ZERO
	var start_air_control : float = -1
	var end_air_control : float = -1
	var air_control_transition_time : float = 0
	var override_current_velocity : bool = false
