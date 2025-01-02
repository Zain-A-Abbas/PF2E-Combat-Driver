extends HBoxContainer
class_name SpeedField

@onready var option_button: OptionButton = $OptionButton
@onready var custom_speed_line: LineEdit = $CustomSpeedLine
@onready var speed_amount: LineEdit = $SpeedAmount
@onready var exit_button: Button = $Button


func _on_option_button_item_selected(index: int) -> void:
	custom_speed_line.visible = index == 5


func _on_button_pressed() -> void:
	queue_free()
