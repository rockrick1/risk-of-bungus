extends Node

var player
var projectile_manager

func _ready():
	for node in get_parent().get_children():
		if node is BaseMap:
			player = node.get_player()
			projectile_manager = node.get_projectile_manager()
