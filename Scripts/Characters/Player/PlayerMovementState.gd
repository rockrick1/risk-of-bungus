class_name PlayerMovementState
extends State

@export var player : CharacterBody3D
var animator : AnimationTree:
	get:
		return player.animator
var cc : CharacterComponent:
	get:
		return player.cc
var spring_arm_pivot : Node3D:
	get:
		return player.spring_arm_pivot

func physics_process(_delta):
	player.apply_floor_snap()
	player.move_and_slide()

func get_movement_direction() -> Vector3:
	var move_direction := Vector3.ZERO
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_direction.z = Input.get_action_strength("move_backwards") - Input.get_action_strength("move_forwards")
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y).normalized()
	return move_direction

func grapple(params: Dictionary):
	transitioned.emit(self, "airborne", params)
