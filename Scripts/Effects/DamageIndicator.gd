extends RigidBody3D

const LIFE_TIME := .7

@onready var force := Vector3(randf() - .5, 2, randf() - .5) * 100

func _ready():
	apply_force(force)
	var timer := get_tree().create_timer(LIFE_TIME)
	timer.timeout.connect(queue_free)

func set_damage(amount: int):
	$Damage.text = str(amount)
	$Heal.visible = false

func set_heal(amount: int):
	$Heal.text = str(amount)
	$Damage.visible = false
