extends PlayerState


func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		%AnimationPlayer.play("jump")
		player.velocity.y = -player.jump_impulse
	else:
		%AnimationPlayer.play("fall")


func physics_update(delta: float) -> void:
	var input_direction_x: float = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)
	player.velocity.x = player.speed * input_direction_x
	player.velocity.y += player.gravity * delta
	player.set_velocity(player.velocity)
	player.set_up_direction(Vector2.UP)
	player.move_and_slide()
	
	if not is_equal_approx(input_direction_x, 0.0):
		%Sprite.flip_h = input_direction_x < 0

	if player.is_on_floor():
		if is_equal_approx(player.velocity.x, 0.0):
			finished.emit("Idle")
		else:
			finished.emit("Run")
