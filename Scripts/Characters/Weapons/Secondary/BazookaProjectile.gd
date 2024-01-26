extends BaseWeaponProjectile

func _on_body_entered(_body):
	for body in $ExplosionArea.get_overlapping_bodies():
		if not "character_component" in body:
			continue
		
		var vector2body = body.global_position - $ExplosionArea.global_position
		body.character_component.take_damage(damage, vector2body.normalized() * push_force)
	queue_free()
