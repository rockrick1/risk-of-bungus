class_name Player
extends CharacterBody3D

const LERP_VALUE : float = 0.25
const ANIMATION_BLEND : float = 7

@export var gravity : float = 50.0

@onready var character_component := $CharacterComponent
@onready var player_mesh : Node3D = $Mesh
@onready var skeleton : Skeleton3D = $Mesh/Armature/Skeleton3D
@onready var spine_ik : SkeletonIK3D = $Mesh/Armature/Skeleton3D/SpineIK

#TODO get these dynamically
@onready var primary_weapon : BaseWeapon = $Rifle
@onready var secondary_weapon : BaseWeapon = $Bazooka

@onready var weapon_tip : Node3D = $Mesh/Armature/Skeleton3D/NeckBone/WeaponTip
@onready var weapon_ray : RayCast3D = $SpringArmPivot/SpringArm3D/Camera3D/RayCast3D
@onready var projectile_manager : Node = get_parent().get_node("ProjectileManager")

var cc : CharacterComponent:
	get:
		return character_component
var snap_vector : Vector3 = Vector3.DOWN
var h_speed : float

func _ready():
	cc.died.connect(_on_died)
	primary_weapon.shot_fired.connect(_on_primary_shot_fired)
	secondary_weapon.shot_fired.connect(_on_secondary_shot_fired)
	spine_ik.start()

#func _physics_process(delta):
	#var move_direction : Vector3 = Vector3.ZERO
	#move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	#move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
#
	#velocity.y -= gravity * delta
	#
	#if Input.is_action_pressed("run"):
		#h_speed = cc.run_speed
	#else:
		#h_speed = cc.walk_speed
	#
	#velocity.x = move_direction.x * h_speed
	#velocity.z = move_direction.z * h_speed
	#
	#if move_direction:
		#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	#
	#var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	#var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	#if is_jumping:
		#velocity.y = cc.base_jump_strength 
		#snap_vector = Vector3.ZERO
	#elif just_landed:
		#snap_vector = Vector3.DOWN
	#
	#apply_floor_snap()
	#move_and_slide()
	#animate(delta)
#
#func animate(delta):
	#if not is_on_floor():
		#animator.set("parameters/ground_air_transition/transition_request", "air")
		#return
	#
	#animator.set("parameters/ground_air_transition/transition_request", "grounded")
	#
	#if velocity.length() > 0:
		#if h_speed == cc.run_speed:
			#animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
		#else:
			#animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
	#else:
		#animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))

func get_weapon_target_vector() -> Vector3:
	var target : Vector3
	if weapon_ray.is_colliding() and (weapon_ray.get_collision_point() - weapon_ray.global_transform.origin).length() > 0.2:
		target = weapon_ray.get_collision_point()
	else:
		target = (weapon_ray.target_position.z * weapon_ray.global_transform.basis.z) + weapon_ray.global_transform.origin
	return target

func _on_primary_shot_fired():
	primary_weapon.spawn_projectiles(weapon_tip.global_position, get_weapon_target_vector())

func _on_secondary_shot_fired():
	secondary_weapon.spawn_projectiles(weapon_tip.global_position, get_weapon_target_vector())

func _on_died():
	print("YOU DIED!!!")