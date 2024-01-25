extends CharacterBody3D

const LERP_VALUE : float = 0.25

var snap_vector : Vector3 = Vector3.DOWN
var speed : float

@export_group("Movement variables")
@export var walk_speed : float = 2.0
@export var run_speed : float = 5.0
@export var jump_strength : float = 15.0
@export var gravity : float = 50.0

const ANIMATION_BLEND : float = 7.0

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var animator : AnimationTree = $AnimationTree
@onready var skeleton : Skeleton3D = $Mesh/Armature/Skeleton3D
@onready var weapon = $Weapon
@onready var weapon_streaks : GPUParticles3D = %WeaponStreaks
@onready var spine_ik : SkeletonIK3D = $Mesh/Armature/Skeleton3D/SpineIK
@onready var weapon_ray : RayCast3D = $SpringArmPivot/SpringArm3D/Camera3D/RayCast3D

func _ready():
	weapon.shot_fired.connect(_on_shot_fired)
	spine_ik.start()

func _physics_process(delta):
	var move_direction : Vector3 = Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	velocity.y -= gravity * delta
	
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.z * speed
	
	if move_direction:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	
	var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	if is_jumping:
		velocity.y = jump_strength
		snap_vector = Vector3.ZERO
	elif just_landed:
		snap_vector = Vector3.DOWN
	
	apply_floor_snap()
	move_and_slide()
	animate(delta)

func animate(delta):
	if is_on_floor():
		animator.set("parameters/ground_air_transition/transition_request", "grounded")
		
		if velocity.length() > 0:
			if speed == run_speed:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			else:
				animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		else:
			animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	else:
		animator.set("parameters/ground_air_transition/transition_request", "air")

func check_streak_collision():
	var weapon_ray_tip : Vector3
	if weapon_ray.is_colliding() and (weapon_ray.get_collision_point() - weapon_ray.global_transform.origin).length() > 0.2:
		weapon_ray_tip = weapon_ray.get_collision_point()
	else:
		weapon_ray_tip = (weapon_ray.target_position.z * weapon_ray.global_transform.basis.z) + weapon_ray.global_transform.origin
	
	print (weapon_ray.get_collision_point())
	
	weapon_streaks.look_at(-weapon_ray_tip, Vector3.UP)

func _on_shot_fired():
	check_streak_collision()
	weapon_streaks.restart()
	#streaks_animation.play("streak")
	#weapon_streaks.playback_speed = clamp(1 / 0.15, 5, 10)
	#weapon_streaks.process_material.gravity.z = -8000 / (1 / 0.15)
