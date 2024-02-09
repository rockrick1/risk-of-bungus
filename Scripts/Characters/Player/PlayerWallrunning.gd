extends PlayerMovementState

const WALL_INWARD_ANGLE_INFLUENCE := .02

@export var fall_gravity_multiplier := .3
@export var walljump_force_multiplier := 1.0
@export var jump_start_air_control := 1
@export var jump_end_air_control := 5
@export var jump_air_control_transition_time := .5

@onready var fall_timer := $FallTimer

var player_direction_on_enter : Vector3
var wall_normal : Vector3
var move_direction : Vector3
var is_wall_on_left : bool

func enter(_params: Dictionary):
	fall_timer.start()
	_setup_directions()
	_setup_animation()
	player.snap_vector = -wall_normal

func exit(_params: Dictionary):
	fall_timer.stop()

func _setup_directions():
	player_direction_on_enter = get_movement_direction()
	wall_normal = player.get_wall_normal()
	
	var angle_to_wall := xz_angle(player_direction_on_enter, wall_normal)
	var angle_to_rotate := (.5 * PI) + WALL_INWARD_ANGLE_INFLUENCE
	if angle_to_wall <= 0 or angle_to_wall >= PI:
		angle_to_rotate = -angle_to_rotate
	move_direction = wall_normal.rotated(Vector3.UP, angle_to_rotate).normalized()

func _setup_animation():
	var wall_right_direction = Vector3.UP.cross(wall_normal)
	is_wall_on_left = player_direction_on_enter.dot(wall_right_direction) > 0

	if is_wall_on_left:
		animator.set("parameters/ground_air_transition/transition_request", "wallrunningflip")
	else:
		animator.set("parameters/ground_air_transition/transition_request", "wallrunning")
	

func physics_process(delta):
	var wants_jump := Input.is_action_just_pressed("jump")
	var is_on_wall := player.is_on_wall_only()
	if wants_jump or not is_on_wall:
		var params := PlayerAirborneState.Params.new()
		if wants_jump:
			wall_normal.y = 1
			params.jump_force = wall_normal * cc.base_jump_strength * walljump_force_multiplier
			params.override_current_velocity = true
			params.start_air_control = jump_start_air_control
			params.end_air_control = jump_end_air_control
			params.air_control_transition_time = jump_air_control_transition_time
		transitioned.emit(self, "airborne", { airborne_params = params })
		super.physics_process(delta)
		return
	
	if not Input.is_action_pressed("run"):
		transitioned.emit(self, "wallsliding", { 
				move_direction = move_direction,
				is_wall_on_left = is_wall_on_left })
		super.physics_process(delta)
		return
	
	if fall_timer.is_stopped():
		player.velocity.y -= player.gravity * delta * fall_gravity_multiplier
		
	else:
		player.velocity.y = 0
		

	var h_speed := cc.run_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.mesh.rotation.y = lerp_angle(player.mesh.rotation.y,
				atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	animator.set("parameters/iwr_blend/blend_amount",
			lerp(animator.get("parameters/iwr_blend/blend_amount"),
			1.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)

func xz_angle(vec1: Vector3, vec2: Vector3) -> float:
	return Vector2(vec1.x, vec1.z).angle_to(Vector2(vec2.x, vec2.z))
