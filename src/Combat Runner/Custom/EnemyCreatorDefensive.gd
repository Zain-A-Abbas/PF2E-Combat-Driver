extends VBoxContainer

const DEFENSIVE_ABILITY = preload("res://Custom/DefensiveAbility.tscn")

@onready var weaknesses_v_box: VBoxContainer = %WeaknessesVBox
@onready var resistances_v_box: VBoxContainer = %ResistancesVBox
@onready var immunities_v_box: VBoxContainer = %ImmunitiesVBox
@onready var defensive_abilities_v_box: VBoxContainer = %DefensiveAbilitiesVBox
@onready var new_defensive_ability_button: Button = %NewDefensiveAbilityButton

func unfocused_new_resist(new_resist: LineEdit):
	if new_resist.text == "":
		new_resist.queue_free()

func add_new_resist(vbox: VBoxContainer):
	var newLineEdit: LineEdit = LineEdit.new()
	vbox.add_child(newLineEdit)
	vbox.move_child(newLineEdit, vbox.get_child_count() - 2)
	newLineEdit.grab_focus()
	newLineEdit.focus_exited.connect(unfocused_new_resist.bind(newLineEdit))


func _on_add_weakness_button_pressed() -> void:
	add_new_resist(weaknesses_v_box)


func _on_add_resistance_button_pressed() -> void:
	add_new_resist(resistances_v_box)


func _on_add_immunity_button_pressed() -> void:
	add_new_resist(immunities_v_box)


func _on_new_defensive_ability_button_pressed() -> void:
	defensive_abilities_v_box.add_child(DEFENSIVE_ABILITY.instantiate())
