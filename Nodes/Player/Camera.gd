extends Camera2D

func _process(delta):
	# Old code that moves camera a bit so u can see where u are going
#	var direction = Input.get_axis("move_left", "move_right")
#	offset.x = lerp(offset.x, (direction * 350), 0.01)

	var mouse = get_global_mouse_position()
	var direction_to_target = self.global_position.direction_to(mouse).normalized()

	offset.x = clamp((mouse.x - owner.global_position.x) / (get_viewport().size.x / 100) * 2, -300, 300)
	offset.y = clamp((mouse.y - owner.global_position.y) / (get_viewport().size.y / 100) * 2, -300, 300)
