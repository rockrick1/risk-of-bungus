extends Node

signal died

@export var max_health := 15

@onready var character : PhysicsBody3D = get_parent()
@onready var current_health := max_health

func take_damage(amount: int, push_force: Vector3 = Vector3.ZERO):
	current_health -= amount
	if character is RigidBody3D:
		character.apply_force(push_force)
	elif character is CharacterBody3D:
		character.snap_vector = Vector3.ZERO
		character.velocity += push_force * Vector3(.015, .02, .015)
	if current_health <= 0:
		died.emit()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
