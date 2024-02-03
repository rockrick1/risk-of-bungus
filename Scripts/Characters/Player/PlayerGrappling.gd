extends PlayerMovementState

@export var base_force := 2.0
@export var air_control := 3.0
@export var upward_force := 2.0

var target : Vector3
var just_entered := true

func enter(params: Dictionary):
	animator.set("parameters/ground_air_transition/transition_request", "air")
	player.snap_vector = Vector3.ZERO
	target = params.target
	player.velocity = player.position.direction_to(target) * base_force
	player.velocity.y += upward_force
	
	just_entered = true

func physics_process(delta):
	var move_direction = get_movement_direction()

	player.velocity.y -= player.gravity * delta
	
	var h_speed := cc.run_speed
	player.velocity.x += move_direction.x * h_speed * delta * air_control
	player.velocity.z += move_direction.z * h_speed * delta * air_control
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	if player.is_on_floor() and not just_entered:
		player.snap_vector = Vector3.DOWN
		
		if move_direction == Vector3.ZERO:
			transitioned.emit(self, "idle")
		elif Input.is_action_pressed("run"):
			transitioned.emit(self, "running")
		else:
			transitioned.emit(self, "walking")
	elif player.is_on_wall_only() and Input.is_action_pressed("run"):
		transitioned.emit(self, "wallrunning")
	
	just_entered = false
	super.physics_process(delta)
