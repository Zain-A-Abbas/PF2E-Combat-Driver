extends MarginContainer
class_name CastingEntry

@onready var entry_name_field: LabelDataField = %EntryNameField
@onready var spell_dc_field: LabelDataField = %SpellDCField
@onready var spell_attack_field: LabelDataField = %SpellAttackField
@onready var spell_fields_container: VBoxContainer = %SpellFieldsContainer

@onready var constant_spells_field: LabelDataField = %ConstantSpellsField


func _on_line_edit_text_changed(new_text: String) -> void:
	name = new_text
