class_name BaseEnemy
extends RigidBody3D

@onready var character_component := $CharacterComponent

var player

func _ready():
	player = GameController.player
	character_component.died.connect(_on_died)

func _on_died():
	queue_free()
