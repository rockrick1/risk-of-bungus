class_name EnemyManager
extends Node

const enemy_scenes_path := "res://Scenes/Characters/Enemies/"

const MIN_ENEMY_SPAWN_COUNT := 2
const MAX_ENEMY_SPAWN_COUNT := 5
const INTRA_GROUP_SPAWN_INTERVAL := .3

signal on_enemy_died

@onready var spawn_area := $EnemySpawnArea

var all_enemies := {}

func _ready():
	load_all_enemies()

func load_all_enemies():
	for file_name in DirAccess.get_files_at(enemy_scenes_path):
		if "base_enemy" in file_name:
			continue
		
		var enemy_scene := load(enemy_scenes_path + file_name)
		var temp_instance = enemy_scene.instantiate()
		all_enemies[temp_instance.name] = enemy_scene
		temp_instance.queue_free()
	return

func _on_group_spawn_timer_timeout():
	var size = all_enemies.size()
	var random_key = all_enemies.keys()[randi() % size]
	for i in range(randi_range(MIN_ENEMY_SPAWN_COUNT, MAX_ENEMY_SPAWN_COUNT)):
		_setup_and_spawn_enemy(all_enemies[random_key])

func _setup_and_spawn_enemy(enemy_scene: PackedScene):
	var enemy_instance = enemy_scene.instantiate()
	add_child(enemy_instance)
	enemy_instance.character_component.died.connect(_on_enemy_died)
	enemy_instance.position = _get_spawn_point()
	await get_tree().create_timer(INTRA_GROUP_SPAWN_INTERVAL).timeout

func _get_spawn_point() -> Vector3:
	var aabb : AABB = spawn_area.get_aabb()
	var random_x = randf()
	var random_y = randf()
	var random_z = randf()
	var aabb_size = aabb.size
	var random_point = Vector3(
		aabb.position.x + random_x * aabb_size.x,
		aabb.position.y + random_y * aabb_size.y,
		aabb.position.z + random_z * aabb_size.z
	)
	return random_point + spawn_area.position

func _on_enemy_died():
	on_enemy_died.emit()
