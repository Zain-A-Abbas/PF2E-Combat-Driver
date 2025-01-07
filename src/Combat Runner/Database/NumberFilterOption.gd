@tool
extends VBoxContainer
class_name NumberFilteringOption

@onready var spin_box = $SpinboxContainer/SpinBox
@onready var spin_box_2 = $SpinboxContainer/SpinBox2

@onready var label: Label = $HBoxContainer/Label
@export var filter_option: String = "Filter" : set = set_filter_option
@onready var menu_button: OptionButton = $HBoxContainer/MenuButton
@onready var spinbox_container: HBoxContainer = $SpinboxContainer

@export var has_dropdown : bool = false:
	set(val):
		has_dropdown = val
		if !is_node_ready():
			await ready
		menu_button.visible = has_dropdown

@export var has_spinboxes : bool = true:
	set(val):
		has_spinboxes = val
		if !is_node_ready():
			await ready
		spinbox_container.visible = has_spinboxes

const ABILITY_SCORES : Array[String] = ["Strength", "Dexterity", "Constitution", "Charisma", "Wisdom", "Intelligence"]
const SPEEDS : Array[String]= ["Land", "Fly", "Swim", "Climb", "Burrow"]
const ELEMENTS : Array[String] = ["None", "Acid", "All", "Bleed", "Bludgeoning", "Chaotic", "Cold", "Cold Iron", "Electricity", "Evil", "Fire", "Force", "Good", "Lawful", "Mental", "Negative", "Orichalum", "Physical", "Piercing", "Poison", "Positive", "Precision", "Silver", "Slashing", "Sonic", "Splash"]

enum ListFiltering { ABILITY_SCORES, SPEEDS, ELEMENTS }
@export var list_filtering : ListFiltering = ListFiltering.ABILITY_SCORES

@export var spinbox_characters: int = 2 :
	set(val):
		spinbox_characters = val
		if !is_node_ready():
			await ready
		spin_box.get_line_edit().add_theme_constant_override("minimum_character_width", spinbox_characters)
		spin_box_2.get_line_edit().add_theme_constant_override("minimum_character_width", spinbox_characters)

func _ready():
	menu_button.item_selected.connect(change_dropdown_text)
	label.text = filter_option
	menu_button.visible = has_dropdown
	match list_filtering: 
		ListFiltering.ABILITY_SCORES: 
			create_pop_ups(ABILITY_SCORES)
		ListFiltering.SPEEDS: 
			create_pop_ups(SPEEDS)
		ListFiltering.ELEMENTS: 
			create_pop_ups(ELEMENTS)

func create_pop_ups(options : Array[String]):
	menu_button.clear()
	for option in options:
		menu_button.add_item(option)
	menu_button.selected = 0

func return_filter() -> NumberFilterData:
	var return_value : NumberFilterData = NumberFilterData.new("", spin_box.value, spin_box_2.value)
	return_value.text = filter_option
	if has_dropdown:
		return_value.dropdown_option = menu_button.selected
	return return_value

func change_dropdown_text(x : int):
	print("Clicked is " + menu_button.get_popup().get_item_text(x))
	menu_button.text = menu_button.get_item_text(x)

func set_filter_option(val):
	filter_option = val
	if label:
		label.text = filter_option
		
