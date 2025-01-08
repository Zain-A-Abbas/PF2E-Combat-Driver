@tool
extends PanelContainer
class_name FilterButton

@onready var trait_text := $MarginContainer/HBoxContainer/TraitText
@onready var toggle_texture := $MarginContainer/HBoxContainer/ToggleTexture
@export var trait_name: String = "UNCOMMON" : set = set_trait

const FilterButtonTexture = preload ("res://Icons/FilterButton.tres")

enum FilterState {
	NONE,
	INCLUDE,
	EXCLUDE
}

var filter_state: FilterState = FilterState.NONE : set = set_filter_state

func _ready():
	trait_text.text = trait_name
	toggle_texture.texture = FilterButtonTexture.duplicate()


func set_trait(val):
	trait_name = val
	if trait_text:
		trait_text.text = val
	size.x = 0
	position = Vector2.ZERO

func set_filter_state(val):
	var new_val = val
	if new_val > 2:
		new_val = 0
	toggle_texture.texture.region.position.x = 64 * new_val
	filter_state = new_val

func reset():
	filter_state = FilterState.NONE

func _on_button_pressed():
	filter_state += 1
