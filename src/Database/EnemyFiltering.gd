extends PanelContainer
class_name FilteringMenu

@export var filter_type: String
var filter_container: Array[Node]

signal apply_filter

func _ready():
	visible = false
	filter_container = find_children("", "FilterButton", true, true)

# If there are no filters, this returns true to skip unneeded iterations entirely
func has_no_filters() -> bool:
	for filter_node in filter_container:
		if filter_node.filter_state != 0:
			return false
	return true

func _on_apply_button_pressed():
	apply_filter.emit()
