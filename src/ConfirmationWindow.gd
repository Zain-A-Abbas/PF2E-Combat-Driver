extends Window


@onready var confirm_text: Label = %ConfirmText
@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton

func _ready() -> void:
	hide()
	EventBus.confirm_popup.connect(confirm_popup)

func confirm_popup(popup_text: String, confirm_button_text: String, cancel_button_text: String):
	confirm_text.text = popup_text
	yes_button.text = confirm_button_text
	no_button.text = cancel_button_text
	show()


func _on_yes_button_pressed() -> void:
	EventBus.popup_confirmed.emit(true)
	hide()


func _on_no_button_pressed() -> void:
	EventBus.popup_confirmed.emit(false)
	hide()
