extends Node

signal died

@export var max_health := 15

@onready var character : PhysicsBody3D = get_parent()
@onready var current_health := max_health

func take_damage(amount: int, push_force: Vector3 = Vector3.ZERO):
	current_health -= amount
	character.velocity += push_force
	if current_health <= 0:
		died.emit()
