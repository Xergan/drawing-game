extends Node2D

signal draw_progress(progress)

var line_scene: PackedScene = preload("res://scenes/line.tscn")

@export var max_line_size: float = 100.0
@export var segment: float = 1.0
@export var ui: UI

var pressed: bool = false
var last_is_erased: bool = false
var ghost_line: Line2D
var last_position: Vector2
var ghost_line_size: float = 0.0

var lines: Array = []
var to_erase: Array = []

var progress: float = 0.0 :
	get: return progress
	set(value):
		progress = value
		draw_progress.emit(1 - (progress / max_line_size))
		

func _ready() -> void:
	last_position = get_local_mouse_position()
	draw_progress.connect(ui._on_draw_progress)

func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		var mouse_pos = get_local_mouse_position()
		var distance_to_mouse = mouse_pos.distance_to(last_position)
		var can_draw = (progress < max_line_size and distance_to_mouse >= segment)
		
		if pressed and can_draw:
			if distance_to_mouse >= max_line_size:
				var direction = (mouse_pos - last_position).normalized()
				var remaining_size = max_line_size - progress
				var caped_pos = mouse_pos + direction * remaining_size
				
				ghost_line.add_point(caped_pos)
				progress = max_line_size
				ghost_line_size = remaining_size
			else:
				ghost_line.add_point(mouse_pos)
				progress += distance_to_mouse
				ghost_line_size += distance_to_mouse
			
			last_position = mouse_pos

	if event.is_action_pressed("draw"):
		last_is_erased = false
		
		for instance: Dictionary in to_erase:
			var line = instance["line"]
			line.queue_free()
			to_erase.erase(instance)
		
		pressed = event.pressed
		ghost_line = Line2D.new()
		ghost_line.default_color = Color("1010109b")
		ghost_line.width = 16.0
		last_position = get_local_mouse_position()
		ghost_line.add_point(last_position)
		add_child(ghost_line)

	if event.is_action_released("draw"):
		if not ghost_line: return
		
		pressed = false
			
		var new_line = line_scene.instantiate()
		new_line.points = ghost_line.points
		add_child(new_line)
		lines.append({"line": new_line, "size": ghost_line_size})
		ghost_line_size = 0
		ghost_line.queue_free()

	if event.is_action_pressed('undo'):
		if last_is_erased:
			if to_erase.is_empty(): return
			
			for instance: Dictionary in to_erase.duplicate():
				var line: Line2D = instance["line"]
				var size: float = instance["size"]
				
				to_erase.erase(instance)
				lines.append(instance)
				
				line.enable()
				progress += size
		else:
			if lines.is_empty(): return
			
			var instance: Dictionary = lines.back()
			
			var line: Line2D = instance["line"]
			var size: float = instance["size"]
			
			lines.erase(instance)
			to_erase.append(instance)
			
			line.disable()
			progress -= size
			

	if event.is_action_pressed('redo'):
		if last_is_erased:
			if not to_erase.is_empty(): return
			
			for instance: Dictionary in lines.duplicate():
				var line: Line2D = instance["line"]
				line.disable()
				
				lines.erase(instance)
				to_erase.append(instance)
				progress = 0
		else:
			if to_erase.is_empty(): return
			
			var instance: Dictionary = to_erase.back()
			var line: Line2D = instance["line"]
			var size: float = instance["size"]
			line.enable()
			
			to_erase.erase(instance)
			lines.append(instance)
			progress += size

	if event.is_action_pressed('delete'):
		if lines.is_empty(): return
		
		last_is_erased = true
		
		for instance: Dictionary in lines.duplicate():
			var line: Line2D = instance["line"]
			line.disable()
			
			lines.erase(instance)
			to_erase.append(instance)
		progress = 0
