class_name CharacterComponent
extends Node

const health_indicator_scene = preload("res://Scenes/Effects/health_indicator.tscn")

signal stats_updated
signal died

@export var base_health := 15.0
@export var base_speed := 2.0
@export var base_run_speed := 5.0
@export var base_jump_strength := 15.0
@export var base_damage := 15.0
@export var base_passive_healing := 15.0

@onready var character : PhysicsBody3D = get_parent()
@onready var current_health := base_health
@onready var heal_cooldown := $HealCooldown
@onready var heal_timer := $HealTimer

var _max_health_buff : float
var _speed_buff : float
var _damage_buff : float
var _passive_healing_buff : float
var _attack_speed_buff : float

var items := {}

var max_health : float:
	get:
		return base_health + _max_health_buff
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
	apply_new_stats()

func recalculate_stats():
	reset_stats()
	for item in items.keys():
		for buff in item.buffs:
			add_buff(buff.type, buff.get_amount(items[item]))
	apply_new_stats()

func add_buff(type: BuffInfo.Type, amount: float):
	match type:
		BuffInfo.Type.ATTACK_SPEED:
			_attack_speed_buff += amount
		BuffInfo.Type.MAX_HEALTH:
			_max_health_buff += amount
		BuffInfo.Type.SPEED:
			_speed_buff += amount
		BuffInfo.Type.DAMAGE:
			_damage_buff += amount
		BuffInfo.Type.PASSIVE_HEALING:
			_passive_healing_buff += amount

func add_item(item: ItemResource):
	#TODO this is horrible, rewrite this later
	if not items.has(item):
		items[item] = 0
	else:
		for buff in item.buffs:
			add_buff(buff.type, -buff.get_amount(items[item]))
	items[item] += 1
	for buff in item.buffs:
		add_buff(buff.type, buff.get_amount(items[item]))
	apply_new_stats()

func apply_new_stats():
	#TODO improve this, healing more that 1 unit per heal is not currently possible
	heal_timer.wait_time = 1 / passive_healing
	stats_updated.emit()

func take_damage(amount: float, push_force: Vector3 = Vector3.ZERO):
	current_health -= amount
	heal_timer.stop()
	heal_cooldown.start()
	
	if character is Player:
		var params = PlayerAirborneState.Params.new()
		params.jump_force = push_force * Vector3(.005, .02, .005)
		params.start_air_control = 5
		character.push(params)
	if character is RigidBody3D:
		character.apply_force(push_force)
	elif character is CharacterBody3D:
		character.snap_vector = Vector3.ZERO
		character.velocity = push_force
	
	show_health_indicator(-ceilf(amount))
	
	if current_health <= 0:
		died.emit()

func show_health_indicator(amount: int):
	var instance = health_indicator_scene.instantiate()
	get_node("/root/Prototype").add_child(instance)
	if amount < 0:
		instance.set_damage(-amount)
	else:
		instance.set_heal(amount)
	instance.position = character.global_position + Vector3.UP

func heal(amount: float):
	amount = min(amount, max_health - current_health)
	if amount == 0:
		return
	
	current_health += amount
	show_health_indicator(amount)

func _on_heal_cooldown_timeout():
	heal_timer.start()

func _on_heal_timer_timeout():
	heal(1)
