extends VBoxContainer

@onready var spell_list_box: OptionButton = %SpellListBox
@onready var casting_type_box: OptionButton = %CastingTypeBox
@onready var spell_dc_field: LabelDataField = %SpellDCField
@onready var spell_attack_field: LabelDataField = %SpellAttackField
@onready var spell_fields_panel: PanelContainer = %SpellFieldsPanel

func _ready() -> void:
	_on_spell_list_box_item_selected(0)

func _on_spell_list_box_item_selected(index: int) -> void:
	casting_type_box.visible = index != 0
	spell_dc_field.visible = index != 0
	spell_attack_field.visible = index != 0
	spell_fields_panel.visible = index != 0
