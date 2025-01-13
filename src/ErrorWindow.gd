extends Window

@onready var error_text: Label = %ErrorText

func _ready() -> void:
	hide()
	EventBus.error_popup.connect(error_popup)

func error_popup(popup_text: String):
	error_text.text = popup_text
	show()
	grab_focus()

func _on_error_button_pressed() -> void:
	hide()
