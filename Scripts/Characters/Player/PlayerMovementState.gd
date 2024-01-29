class_name PlayerMovementState
extends State

@export var player : CharacterBody3D
@export var animator : AnimationTree
@export var cc : CharacterComponent
@export var spring_arm_pivot : Node3D

func physics_process(_delta):
	player.apply_floor_snap()
	player.move_and_slide()
