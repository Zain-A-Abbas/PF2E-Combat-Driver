extends FilteringMenu

@onready var grid_container: GridContainer = %GridContainer


func _ready():
	visible = false
	filter_container = find_children("", "FilterButton", true, true)

# If there are no filters, this returns true to skip unneeded iterations entirely
func has_no_filters() -> bool:
	for filter_node in filter_container:
		if filter_node.filter_state != 0:
			return false
	return true

func get_number_filter_data() -> Array[NumberFilterData]:
	var number_filters = grid_container.get_children()
	var return_data : Array[NumberFilterData] = []
	for child in number_filters:
		return_data.append(child.return_filter())
	return return_data

func _on_apply_button_pressed():
	emit_signal("apply_filter")
