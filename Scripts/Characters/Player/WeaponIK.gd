class_name WeaponIK
extends SkeletonIK3D

const transition_time_in := .2
const transition_time_out := .6

@onready var timer := $Timer

var interpolation_tween : Tween

func _ready():
	interpolation = 0
	start()

func startIK():
	if timer.is_stopped():
		tween_interpolation(1, transition_time_in)
	timer.start()

func tween_interpolation(value: float, time: float):
	if interpolation_tween:
		interpolation_tween.kill()
	interpolation_tween = create_tween()
	interpolation_tween.tween_property(self, "interpolation", value, time)

func _on_timer_timeout():
	tween_interpolation(0, transition_time_out)
