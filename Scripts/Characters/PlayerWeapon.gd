extends Node

signal shot_fired

@onready var shot_timer : Timer = $ShotTimer
@onready var streak_scene = preload("res://Scenes/Effects/weapon_streak_basic.tscn")

var can_shoot : bool = true

func _process(_delta):
	if Input.is_action_pressed("primary_shoot") and can_shoot:
		shot_fired.emit()
		shot_timer.start()
		can_shoot = false

func _on_shot_timer_timeout():
	can_shoot = true
