extends BaseWeapon

@export var grapple_range : float = 35.0
@export var base_force := 25.0
@export var air_control := 5.0
@export var upward_force := 10.0

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
	
	var jump_force = player.position.direction_to(target) * base_force
	jump_force.y += upward_force
	
	var params := PlayerAirborneState.Params.new()
	params.jump_force = jump_force
	params.override_current_velocity = true
	params.clamp_speed = false
	params.start_air_control = air_control
	
	player.push(params)
	$VanishTimer.start()

func _on_vanish_timer_timeout():
	rope.visible = false
