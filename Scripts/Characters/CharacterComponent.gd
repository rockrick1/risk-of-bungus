class_name CharacterComponent
extends Node

const damage_indicator_scene = preload("res://Scenes/Effects/damage_indicator.tscn")

signal stats_updated
signal died

@export var base_health := 15
@export var base_speed := 2.0
@export var base_run_speed := 5.0
@export var base_jump_strength := 15.0
@export var base_damage := 15.0
@export var base_passive_healing := 15.0

@onready var character : PhysicsBody3D = get_parent()
@onready var current_health := base_health

var _max_health_buff : int
var _speed_buff : float
var _damage_buff : float
var _passive_healing_buff : float
var _attack_speed_buff : float

var items : Array[ItemResource]

var max_health : int:
	get:
		return base_health * _max_health_buff
var walk_speed : float:
	get:
		return base_speed * _speed_buff
var run_speed : float:
	get:
		return base_run_speed * _speed_buff
var damage_buff : float:
	get:
		return _damage_buff
var passive_healing : float:
	get:
		return base_passive_healing * _passive_healing_buff
var attack_speed_buff : float:
	get:
		return _attack_speed_buff

func _ready():
	reset_stats()

func reset_stats():
	_max_health_buff = 0
	_speed_buff = 1.0
	_damage_buff = 1.0
	_passive_healing_buff = 1.0
	_attack_speed_buff = 1.0
	stats_updated.emit()

func recalculate_stats():
	reset_stats()
	for item in items:
		for buff in item.buffs:
			add_buff(buff.type, buff.amount)
	stats_updated.emit()

func add_buff(type: BuffInfo.Type, amount: float):
	match type:
		BuffInfo.Type.ATTACK_SPEED:
			_attack_speed_buff *= amount
		BuffInfo.Type.MAX_HEALTH:
			_max_health_buff += int(amount)
		BuffInfo.Type.SPEED:
			_speed_buff *= amount
		BuffInfo.Type.DAMAGE:
			_damage_buff *= amount
		BuffInfo.Type.PASSIVE_HEALING:
			_passive_healing_buff *= amount

func add_item(item: ItemResource):
	items.append(item)
	for buff in item.buffs:
		add_buff(buff.type, buff.amount)
	stats_updated.emit()

func take_damage(amount: int, push_force: Vector3 = Vector3.ZERO):
	current_health -= amount
	if character is RigidBody3D:
		character.apply_force(push_force)
	elif character is CharacterBody3D:
		character.snap_vector = Vector3.ZERO
		character.velocity += push_force * Vector3(.015, .02, .015)
	show_damage_indicator(amount)
	if current_health <= 0:
		died.emit()

func show_damage_indicator(amount: int):
	var instance = damage_indicator_scene.instantiate()
	get_node("/root/Prototype").add_child(instance)
	instance.set_damage(amount)
	instance.position = character.global_position + Vector3.UP

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
