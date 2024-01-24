extends Node

signal shot_fired

@onready var shot_timer : Timer = $ShotTimer

var can_shoot : bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("primary_shoot") and can_shoot:
		shot_fired.emit()
		shot_timer.start()
		can_shoot = false

func _on_shot_timer_timeout():
	can_shoot = true
