class_name BaseItem
extends Node3D

@export var resource : ItemResource

func _ready():
	var rotation_tween = create_tween()
	rotation_tween.set_loops()
	rotation_tween.tween_property($MeshInstance3D, "rotation:y", 2 * PI, 3)
	rotation_tween.tween_callback(func(): $MeshInstance3D.rotation.y = 0)
	
	#var float_tween = create_tween()
	#float_tween.set_loops()
	#float_tween.set_ease(Tween.EASE_IN_OUT)
	#float_tween.tween_property($MeshInstance3D, "position:y", $MeshInstance3D.position.y + .5, 1)
	#float_tween.tween_property($MeshInstance3D, "position:y", $MeshInstance3D.position.y - .5, 1)

func _on_pickup_zone_body_entered(body):
	if not body is Player:
		return
	body.character_component.add_item(resource)
	queue_free()
