extends StaticBody2D

func _die():
	#queue_free()
	
	$box.queue_free()
	$collision.queue_free()
	$fumaca.play()
	
	for f in get_children():
		if f is RigidBody2D:
			
			f.bounce = .05
			f.angular_velocity = randf() * 10
			var dir = randf() * (PI * 2)
			f.apply_impulse(Vector2.ZERO, Vector2(cos(dir), sin(dir)) * 200 + Vector2(0,50))

