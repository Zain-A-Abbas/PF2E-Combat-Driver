@tool
extends FilterButton
class_name TraitFilterButton

const regular_trait = preload("res://Themes/TraitStyleboxes/RegularTrait.tres")
const uncommon_trait = preload("res://Themes/TraitStyleboxes/UncommonTrait.tres")
const rare_trait = preload("res://Themes/TraitStyleboxes/RareTrait.tres")
const size_trait = preload("res://Themes/TraitStyleboxes/SizeTrait.tres")
const alignment_trait = preload("res://Themes/TraitStyleboxes/AlignmentTrait.tres")
const unique_trait = preload("res://Themes/TraitStyleboxes/UniqueTrait.tres")

func _ready():
	super._ready()



func set_trait(val):
	trait_name = val
	if trait_text:
		trait_text.text = val
	size.x = 0
	position = Vector2.ZERO
	add_theme_stylebox_override("panel", get_trait_type())

func get_trait_type():
	match trait_name:
		"RARE":
			return rare_trait
		"UNCOMMON":
			return uncommon_trait
		"TINY", "SMALL", "MEDIUM", "LARGE", "HUGE", "GARGANTUAN":
			return size_trait
		"LG", "NG", "CG", "LN", "N", "CN", "LE", "NE", "CE":
			return alignment_trait
		"UNIQUE":
			return unique_trait
		_:
			return regular_trait




func _on_button_mouse_entered():
	# print("mouse in the house")
	var new_stylebox = get_trait_type().duplicate()
	new_stylebox.border_color = Color(0, 0, 0, 1.0)
	add_theme_stylebox_override("panel", new_stylebox)



func _on_button_mouse_exited():
	#print("mouse out the house")
	add_theme_stylebox_override("panel", get_trait_type())
