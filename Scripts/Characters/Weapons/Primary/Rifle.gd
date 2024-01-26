extends BaseWeapon

func _init():
	action = "primary_shoot"
	projectile_scene = preload("res://Scenes/Characters/Weapons/Effects/rifle_projectile.tscn")
