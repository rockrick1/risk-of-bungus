extends PlayerMovementState

const FALL_GRAVITY_MULTIPLIER := .3
const WALL_INWARD_ANGLE_INFLUENCE := .01

@onready var fall_timer := $FallTimer

var player_direction_on_enter : Vector3
var wall_normal : Vector3

func enter():
	animator.set("parameters/ground_air_transition/transition_request", "grounded")
	fall_timer.start()
	
	player_direction_on_enter = Vector3.ZERO
	player_direction_on_enter.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player_direction_on_enter.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	player_direction_on_enter = player_direction_on_enter.rotated(Vector3.UP, spring_arm_pivot.rotation.y).normalized()
	
	wall_normal = player.get_wall_normal()

func exit():
	fall_timer.stop()

func physics_process(delta):
	if Input.is_action_just_pressed("jump"):
		wall_normal.y = 1
		player.velocity = wall_normal * cc.base_jump_strength
		transitioned.emit(self, "walljumping")
		super.physics_process(delta)
		return
	if not player.is_on_wall_only():
		transitioned.emit(self, "idle")
		super.physics_process(delta)
		return
	
	var angle_to_wall := xz_angle(player_direction_on_enter, wall_normal)
	var angle_to_rotate := (.5 * PI) + WALL_INWARD_ANGLE_INFLUENCE
	if angle_to_wall <= 0 or angle_to_wall >= PI:
		angle_to_rotate = -angle_to_rotate
	var move_direction := wall_normal.rotated(Vector3.UP, angle_to_rotate).normalized()
	
	if fall_timer.is_stopped():
		player.velocity.y -= player.gravity * delta * FALL_GRAVITY_MULTIPLIER
	else:
		player.velocity.y = 0

	var h_speed := cc.run_speed
	player.velocity.x = move_direction.x * h_speed
	player.velocity.z = move_direction.z * h_speed
	
	if move_direction:
		player.player_mesh.rotation.y = lerp_angle(player.player_mesh.rotation.y, atan2(player.velocity.x, player.velocity.z), player.LERP_VALUE)
	
	animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * player.ANIMATION_BLEND))
	super.physics_process(delta)

func xz_angle(vec1: Vector3, vec2: Vector3) -> float:
	return Vector2(vec1.x, vec1.z).angle_to(Vector2(vec2.x, vec2.z))
