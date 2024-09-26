extends CanvasLayer
class_name UI

@onready var progress_bar: ProgressBar = $Control/VBoxContainer/ProgressBar

func _ready() -> void:
	progress_bar.max_value = 1
	progress_bar.value = 1

func _on_draw_progress(progress) -> void:
	progress_bar.value = progress

func _on_draw_erase() -> void:
	progress_bar.value = 1
