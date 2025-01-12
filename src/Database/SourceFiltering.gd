extends FilteringMenu

const FILTER_BUTTON = preload("res://Database/FilterButton.tscn")

@onready var sources_container: HFlowContainer = %GridContainer

func setup(sources: Array):
	for source in sources:
		var new_source_filter: FilterButton = FILTER_BUTTON.instantiate()
		new_source_filter.set_trait(source)
		sources_container.add_child(new_source_filter)
	set_filter_container()

func set_filter_container():
	filter_container = find_children("", "FilterButton", true, false)

# If there are no filters, this returns true to skip unneeded iterations entirely
func has_no_filters() -> bool:
	for filter_node in sources_container.get_children():
		if filter_node is FilterButton:
			if filter_node.filter_state != 0:
				return false
	return true

func _on_apply_button_pressed():
	super()

func _on_source_search_text_changed(new_text: String) -> void:
	for filter_button in sources_container.get_children():
		if filter_button is FilterButton:
			if new_text == "":
				filter_button.visible = true
			else:
				filter_button.visible = filter_button.trait_name.to_lower().contains(new_text.to_lower())
