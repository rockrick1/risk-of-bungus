extends BaseWeapon

@export var grapple_range : float = 35.0

@onready var rope : Node3D = $Rope

func _init():
	action = "secondary_shoot"

func _ready():
	super._ready()
	rope.visible = false

func spawn_projectiles(weapon_tip: Vector3, target: Vector3):
	var distance = weapon_tip.distance_to(target)
	if distance > grapple_range:
		return
	rope.visible = true
	rope.position = weapon_tip
	rope.scale.z = distance
	rope.look_at(target)
	player.grapple(target)
	$VanishTimer.start()

func _on_vanish_timer_timeout():
	rope.visible = false
