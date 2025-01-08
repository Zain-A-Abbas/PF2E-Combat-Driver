extends RichTextLabel
class_name SheetContent

enum InfoTypes {
	NULL,
	SENSE,
	SPELL,
	SKILL,
	TRAIT
}

@export var info_type: InfoTypes

var enemy_name: String

func _make_custom_tooltip(for_text):
	var tooltip
	match info_type:
		InfoTypes.SENSE:
			var tooltip_header = for_text.split("|")[0]
			var tooltip_description = for_text.split("|")[1]
			tooltip = preload("res://Tooltips/SenseTooltip.tscn").instantiate()
			tooltip.get_node("MarginContainer").get_node("VBoxContainer").get_node("Header").get_node("TooltipHeader").text = tooltip_header
			tooltip.get_node("MarginContainer").get_node("VBoxContainer").get_node("TooltipText").text = tooltip_description
		
		InfoTypes.TRAIT:
			var tooltip_header = for_text.split("|")[0]
			var tooltip_description = for_text.split("|")[1].strip_edges()
			tooltip = preload("res://Tooltips/TraitTooltip.tscn").instantiate()
			tooltip.get_node("MarginContainer").get_node("VBoxContainer").get_node("Header").get_node("TooltipHeader").text = tooltip_header
			tooltip.get_node("MarginContainer").get_node("VBoxContainer").get_node("TooltipText").text = tooltip_description
	return tooltip


func _on_meta_clicked(meta):
	EventBus.emit_signal("d20_rolled", meta.to_int(), enemy_name)
