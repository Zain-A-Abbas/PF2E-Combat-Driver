extends VBoxContainer

@onready var new_speed_field_button: Button = %NewSpeedFieldButton
@onready var speed_field_v_box: VBoxContainer = %SpeedFieldVBox

const SPEED_FIELD = preload("res://Custom/SpeedField.tscn")

func _on_new_speed_field_button_pressed() -> void:
	speed_field_v_box.add_child(SPEED_FIELD.instantiate())
