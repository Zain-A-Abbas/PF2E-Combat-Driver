extends VBoxContainer
class_name Subfilter

const TRAIT_FILTER_BUTTON = preload("res://Database/TraitFilterButton.tscn")

@onready var subfilter_label := $HBoxContainer/SubfilterLabel
@export var filter_buttons_container: Container

# The name of the thing being filtered; Also used as the actual filter check
@export var subfilter_name: String = "Sizes" : set = set_subfilter
@export var filter_options: Array[Node]

# This variable is used to hold a number of traits inserted as a variable instead
var traits: PackedStringArray : set = set_traits

func _ready():
	subfilter_label.text = subfilter_name
	var other_subfilters: bool = false
	for child in get_parent().get_children():
		if child is Subfilter:
			if child != self:
				other_subfilters = true
	subfilter_label.visible = other_subfilters

func set_subfilter(val):
	subfilter_name = val
	if subfilter_label:
		subfilter_label.text = val

func _on_reset_button_pressed():
	reset_filters()

# Turns every filter back to neutral
func reset_filters():
	for child in filter_buttons_container.get_children():
		if child is FilterButton:
			child.reset()

func set_traits(val):
	traits = val
	for child in filter_buttons_container.get_children():
		#remove_child(child)
		child.queue_free()
	for trait_filter in traits:
		var new_filter_button = TRAIT_FILTER_BUTTON.instantiate()
		filter_buttons_container.add_child(new_filter_button)
		new_filter_button.trait_name = trait_filter


# Behavior when clicking on include and exclude button
func _on_include_button_pressed():
	for child in filter_buttons_container.get_children():
		if child is FilterButton:
			child.filter_state = FilterButton.FilterState.INCLUDE

func _on_exclude_button_pressed():
	for child in filter_buttons_container.get_children():
		if child is FilterButton:
			child.filter_state = FilterButton.FilterState.EXCLUDE
