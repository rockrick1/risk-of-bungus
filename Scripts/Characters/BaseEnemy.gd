class_name BaseEnemy
extends RigidBody3D

@export var move_speed := 0.5

@onready var character_component := $CharacterComponent

var player
var vector2player : Vector3

func _ready():
	player = GameController.player
	character_component.died.connect(_on_died)

func _physics_process(delta):
	vector2player = (global_position - player.global_position).normalized()
	look_at(player.global_position)
	move_and_collide(-vector2player * move_speed * delta * Vector3(1, 0.15, 1))

func _on_died():
	queue_free()
