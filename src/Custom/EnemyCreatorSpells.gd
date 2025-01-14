extends VBoxContainer

@onready var new_casting_entry_button: Button = %NewCastingEntryButton
@onready var delete_casting_entry_button: Button = %DeleteCastingEntryButton

@onready var casting_entry_tabs: TabContainer = %CastingEntryTabs

const CASTING_ENTRY = preload("res://Custom/CastingEntry.tscn")

func _on_new_casting_entry_button_pressed() -> void:
	casting_entry_tabs.add_child(CASTING_ENTRY.instantiate())

func _on_delete_casting_entry_button_pressed() -> void:
	if casting_entry_tabs.get_child_count() > 0:
		casting_entry_tabs.get_child(casting_entry_tabs.current_tab).queue_free()
	_on_visibility_changed()


func _on_visibility_changed() -> void:
	delete_casting_entry_button.disabled = casting_entry_tabs.get_child_count() == 0
