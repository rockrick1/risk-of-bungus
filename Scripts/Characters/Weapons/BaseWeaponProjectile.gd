class_name BaseWeaponProjectile
extends Area3D

@export var speed : float = 120
@export var damage := 10
@export var push_force := 90

var motion : Vector3
var target : Vector3 = Vector3.ZERO:
	set(value):
		target = value
		motion = (target - global_position).normalized()

func _physics_process(delta):
	if target != Vector3.ZERO:
		position += (motion * speed * delta)

func _on_body_entered(body):
	if body is BaseEnemy:
		body.character_component.take_damage(damage, (body.global_position - global_position).normalized() * push_force)
	queue_free()

func _on_life_timer_timeout():
	queue_free()
