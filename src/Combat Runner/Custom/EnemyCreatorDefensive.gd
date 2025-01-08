extends VBoxContainer

const ENEMY_ABILITY = preload("res://Custom/EnemyAbility.tscn")
const WEAKNESS_RESISTANCE_FIELD = preload("res://Custom/WeaknessResistanceField.tscn")

@onready var weaknesses_v_box: VBoxContainer = %WeaknessesVBox
@onready var resistances_v_box: VBoxContainer = %ResistancesVBox
@onready var immunities_v_box: VBoxContainer = %ImmunitiesVBox
@onready var defensive_abilities_v_box: VBoxContainer = %DefensiveAbilitiesVBox
@onready var new_defensive_ability_button: Button = %NewDefensiveAbilityButton

func unfocused_new_resist(new_resist: HBoxContainer):
	if new_resist.get_child(0).text == "":
		new_resist.queue_free()

func unfocused_immunity(immunity: LineEdit):
	if immunity.text == "":
		immunity.queue_free()

func add_new_resist(vbox: VBoxContainer):
	var new_resist_field: HBoxContainer = WEAKNESS_RESISTANCE_FIELD.instantiate()
	vbox.add_child(new_resist_field)
	vbox.move_child(new_resist_field, vbox.get_child_count() - 2)
	new_resist_field.get_child(0).grab_focus()
	new_resist_field.get_child(0).focus_exited.connect(unfocused_new_resist.bind(new_resist_field))

func add_new_immunity():
	var new_immunity: LineEdit = LineEdit.new()
	immunities_v_box.add_child(new_immunity)
	immunities_v_box.move_child(new_immunity, immunities_v_box.get_child_count() - 2)
	new_immunity.grab_focus()
	new_immunity.focus_exited.connect(unfocused_immunity.bind(new_immunity))

# Used when a new one is added through the customize menu
func setup_new_resist(new_resist: Control):
	new_resist.get_child(0).focus_exited.connect(unfocused_new_resist.bind(new_resist))

func setup_new_immunity(new_immunity: LineEdit):
	new_immunity.focus_exited.connect(unfocused_immunity.bind(new_immunity))

func _on_add_weakness_button_pressed() -> void:
	add_new_resist(weaknesses_v_box)


func _on_add_resistance_button_pressed() -> void:
	add_new_resist(resistances_v_box)


func _on_add_immunity_button_pressed() -> void:
	add_new_immunity()


func _on_new_defensive_ability_button_pressed() -> void:
	defensive_abilities_v_box.add_child(ENEMY_ABILITY.instantiate())
