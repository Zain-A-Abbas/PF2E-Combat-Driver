extends VBoxContainer

@onready var attack_editor_window: Window = %AttackEditorWindow
@onready var strikes_vbox: VBoxContainer = %StrikesVbox

@onready var strike_name_field: LabelDataField = %StrikeNameField
@onready var strike_type_options: OptionButton = %StrikeTypeOptions
@onready var strike_traits_field: LabelDataField = %StrikeTraitsField
@onready var strike_bonus_field: LabelDataField = %StrikeBonusField
@onready var strike_damage_field: LabelDataField = %StrikeDamageField
@onready var attack_save_button: Button = %AttackSaveButton
@onready var offensive_abilities_v_box: VBoxContainer = %OffensiveAbilitiesVBox

const ENEMY_ABILITY = preload("res://Custom/EnemyAbility.tscn")
const ENEMY_CREATOR_STRIKE_CONTAINER = preload("res://Custom/EnemyCreatorStrikeContainer.tscn")

var current_editing_container: EnemyCreatorStrikeContainer = null
var current_editing_data: EnemyCreatorStrike

func _ready() -> void:
	for child in strikes_vbox.get_children():
		if child is EnemyCreatorStrikeContainer:
			child.edit_button_clicked.connect(strike_edit)

func strike_edit(strike_container: EnemyCreatorStrikeContainer):
	current_editing_container = strike_container
	if current_editing_container == null:
		current_editing_data = EnemyCreatorStrike.new()
	else:
		current_editing_data = strike_container.strike_data
	
	strike_name_field.set_value(current_editing_data.strike_name)
	strike_type_options.select(current_editing_data.strike_type)
	
	var traits_text: String = ""
	for i in current_editing_data.traits.size():
		traits_text += current_editing_data.traits[i]
		if i < current_editing_data.traits.size() - 1:
			traits_text += ", "
	strike_traits_field.set_value(traits_text)
	
	strike_bonus_field.set_value(str(current_editing_data.strike_bonus))
	strike_damage_field.set_value(current_editing_data.strike_damage)
	
	attack_editor_window.show()

func _on_attack_editor_window_close_requested() -> void:
	attack_editor_window.hide()
	if current_editing_container == null:
		current_editing_data.free()

func _on_strike_creator_pressed() -> void:
	strike_edit(null)

func _on_attack_save_button_pressed() -> void:
	current_editing_data.strike_name = strike_name_field.get_value()
	current_editing_data.strike_type = strike_type_options.selected
	
	var traits_string: String = strike_traits_field.get_value().replace(", ", ",")
	current_editing_data.traits = traits_string.split(",", false)
	
	current_editing_data.strike_bonus = int(strike_bonus_field.get_value())
	current_editing_data.strike_damage = strike_damage_field.get_value()
	
	if current_editing_container == null:
		var new_strike: EnemyCreatorStrikeContainer = ENEMY_CREATOR_STRIKE_CONTAINER.instantiate()
		strikes_vbox.add_child(new_strike)
		new_strike.edit_button_clicked.connect(strike_edit)
		new_strike.fill_data(current_editing_data)
	else:
		current_editing_container.fill_data(current_editing_data)
	attack_editor_window.hide()


func _on_new_offensive_ability_button_pressed() -> void:
	offensive_abilities_v_box.add_child(ENEMY_ABILITY.instantiate())
