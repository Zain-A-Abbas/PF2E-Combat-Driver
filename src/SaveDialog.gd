extends FileDialog


func choose_save_directory():
	visible = true



func _on_file_selected(path: String) -> void:
	visible = false
	EventBus.emit_signal("encounter_save_directory_chosen", path)
