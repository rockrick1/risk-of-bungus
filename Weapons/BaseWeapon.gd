class_name BaseWeapon
extends Node

signal shot_fired

@onready var shot_timer := $ShotTimer
@onready var base_reload_time = shot_timer.wait_time
@onready var player := get_parent()
@onready var player_character_component := player.get_node("CharacterComponent")

var action : String
var projectile_scene : PackedScene
var can_shoot := true
var is_shooting := false

func _ready():
	player_character_component.stats_updated.connect(_on_stats_updated)

func _process(_delta):
	if Input.is_action_pressed(action) and can_shoot:
		shot_fired.emit()
		shot_timer.start()
		can_shoot = false
		is_shooting = true
	if Input.is_action_just_released(action):
		is_shooting = false

func spawn_projectiles(weapon_tip: Vector3, target: Vector3):
	var projectile_instance = projectile_scene.instantiate()
	GameController.projectile_manager.add_child(projectile_instance)
	projectile_instance.position = weapon_tip
	projectile_instance.target = target
	projectile_instance.damage_buff = player_character_component.damage_buff
	projectile_instance.look_at(target)

func _on_shot_timer_timeout():
	can_shoot = true

func _on_stats_updated():
	shot_timer.wait_time = base_reload_time / player_character_component.attack_speed_buff
