@tool
extends HBoxContainer
class_name LabelDataField

@onready var label: Label = $Label
@onready var line_edit: LabelDataLineEdit = $LineEdit

@export var label_text: String = "Label" : set = set_label_text
@export var numbers_only: bool = false
@export var minimum_character_width: int = 4 : set = set_minimum_character_width

func _ready() -> void:
	line_edit.add_theme_constant_override("minimum_character_width", minimum_character_width)

func set_value(val: String):
	line_edit.text = val

func set_value_num(val):
	line_edit.text = str(val)

func get_value() -> String:
	return line_edit.text

func set_label_text(val: String):
	label_text = val
	if is_node_ready():
		label.text = val
	else:
		await ready
		label.text = val

func set_minimum_character_width(val: int):
	minimum_character_width = val
	if is_node_ready():
		line_edit.add_theme_constant_override("minimum_character_width", val)
	else:
		await ready
		line_edit.add_theme_constant_override("minimum_character_width", val)
