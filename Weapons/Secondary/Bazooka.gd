extends BaseWeapon

func _init():
	action = "secondary_shoot"
	projectile_scene = preload("res://Scenes/Weapons/Projectiles/bazooka_projectile.tscn")
