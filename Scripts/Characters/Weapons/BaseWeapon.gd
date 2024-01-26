class_name BaseWeapon
extends Node

signal shot_fired

@onready var shot_timer : Timer = $ShotTimer

var action : String
var projectile_scene : PackedScene
var can_shoot : bool = true

func _process(_delta):
	if Input.is_action_pressed(action) and can_shoot:
		shot_fired.emit()
		shot_timer.start()
		can_shoot = false

func shoot(weapon_tip: Vector3, target: Vector3):
	var projectile_instance = projectile_scene.instantiate()
	GameController.projectile_manager.add_child(projectile_instance)
	projectile_instance.position = weapon_tip
	projectile_instance.target = target
	projectile_instance.look_at(target)

func _on_shot_timer_timeout():
	can_shoot = true
