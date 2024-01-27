class_name BaseWeaponProjectile
extends Area3D

@export var base_speed := 120.0
@export var base_damage := 10
@export var push_force := 90

var speed_buff := 1.0 #currently unused
var damage_buff := 1.0

var _speed : float:
	get:
		return base_speed * speed_buff
var _damage : int:
	get:
		return base_damage * damage_buff 

var motion : Vector3
var target := Vector3.ZERO:
	set(value):
		target = value
		motion = (target - global_position).normalized()

func _physics_process(delta):
	if target != Vector3.ZERO:
		position += (motion * _speed * delta)

func _on_body_entered(body):
	if body is BaseEnemy:
		body.character_component.take_damage(_damage, motion * push_force)
	queue_free()

func _on_life_timer_timeout():
	queue_free()
