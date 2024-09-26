extends PlayerState

func enter(_msg := {}) -> void:
	%AnimationPlayer.play("move")

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		finished.emit("Air")
		return

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
	
	if Input.is_action_just_pressed("jump"):
		finished.emit("Air", {do_jump = true})
	elif is_equal_approx(input_direction_x, 0.0):
		finished.emit("Idle")
