extends BaseWeapon

func _init():
	action = "primary_shoot"
	projectile_scene = preload("res://Scenes/Weapons/Projectiles/rifle_projectile.tscn")
