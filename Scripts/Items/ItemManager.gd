extends Node

const item_scenes_path := "res://Scenes/Items/"

var all_items := {}

func _ready():
	load_all_items()
	spawn_random_item($SpawnPoint1.position)

func load_all_items():
	for file_name in DirAccess.get_files_at(item_scenes_path):
		var item_scene := load(item_scenes_path + file_name)
		var temp_instance = item_scene.instantiate()
		if (temp_instance.resource != null):
			all_items[temp_instance.resource.name] = item_scene
		temp_instance.queue_free()
	return

func spawn_random_item(position: Vector3):
	var size = all_items.size()
	var random_key = all_items.keys()[randi() % size]
	spawn_item(random_key, position)

func spawn_item(item_name: String, position: Vector3):
	var instance = all_items[item_name].instantiate()
	add_child(instance)
	instance.position = position
