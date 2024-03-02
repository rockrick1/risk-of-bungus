extends Node

@export var enemy_manager : EnemyManager

var points := 0

func _ready():
	enemy_manager.on_enemy_died.connect(_on_enemy_died)

func _on_enemy_died():
	points += 1
