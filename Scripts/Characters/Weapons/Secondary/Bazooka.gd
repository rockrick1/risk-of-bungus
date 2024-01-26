extends BaseWeapon

func _init():
	action = "secondary_shoot"
	projectile_scene = preload("res://Scenes/Characters/Weapons/Effects/bazooka_projectile.tscn")
