extends Node

signal sheet_created

@onready var name_field: LabelDataField = %NameField
@onready var level_field: LabelDataField = %LevelField
@onready var perception_field: LabelDataField = %PerceptionField
@onready var senses_field: LabelDataField = %SensesField
@onready var languages_field: LabelDataField = %LanguagesField
@onready var traits_text_edit: TextEdit = %TraitsTextEdit
@onready var notes_text_edit: TextEdit = %NotesTextEdit
@onready var speed_field_v_box: VBoxContainer = %SpeedFieldVBox

@onready var str_field: LabelDataField = %STRField
@onready var dex_field: LabelDataField = %DEXField
@onready var con_field: LabelDataField = %CONField
@onready var int_field: LabelDataField = %INTField
@onready var wis_field: LabelDataField = %WISField
@onready var cha_field: LabelDataField = %CHAField

@onready var hp_field: LabelDataField = %HPField
@onready var ac_field: LabelDataField = %ACField
@onready var fortitude_save_field: LabelDataField = %FortitudeSaveField
@onready var reflex_save_field: LabelDataField = %ReflexSaveField
@onready var will_save_field: LabelDataField = %WillSaveField
@onready var weaknesses_v_box: VBoxContainer = %WeaknessesVBox
@onready var resistances_v_box: VBoxContainer = %ResistancesVBox
@onready var immunities_v_box: VBoxContainer = %ImmunitiesVBox
@onready var defensive_abilities_v_box: VBoxContainer = %DefensiveAbilitiesVBox

@onready var strikes_vbox: VBoxContainer = %StrikesVbox
@onready var offensive_abilities_v_box: VBoxContainer = %OffensiveAbilitiesVBox

const CUSTOM_ENEMIES_LOCATION: String = "res://Data/Enemies/custom-enemies/"
const EnemySheetExample = preload("res://EnemySheet/EnemySheetExample.gd")

func create_enemy():
	var new_enemy_sheet: Dictionary = {}
	var example = EnemySheetExample.new()
	new_enemy_sheet = example.DEFAULT.duplicate(true)
	example.queue_free()
	
	var system: Dictionary = new_enemy_sheet["system"]
	var details: Dictionary = system["details"]
	var attributes: Dictionary = system["attributes"]
	var traits: Dictionary = system["traits"]
	
	#region General
	
	new_enemy_sheet["name"] = name_field.get_value()
	details["level"]["value"] = int(level_field.get_value())
	attributes["perception"]["value"] = int(perception_field.get_value())
	traits["senses"]["value"] = senses_field.get_value()
	new_enemy_sheet["notes"] = notes_text_edit.text
	
	# Languages
	var languages_string: String = languages_field.get_value().replace(", ", ",")
	var languages_array: PackedStringArray = languages_string.split(",", false)
	for language in languages_array:
		traits["languages"]["value"].append(language)
	
	# Traits
	var traits_string: String = traits_text_edit.text.replace(", ", ",")
	var traits_array: PackedStringArray = traits_string.split(",", false)
	for enemy_trait in traits_array:
		if ["tiny",  "small", "medium", "large", "huge", "gargantuan"].has(enemy_trait.to_lower()):
			traits["size"]["value"] = enemy_trait.to_lower()
			continue
		traits["value"].append(enemy_trait)
	
	# Ability Modifiers
	new_enemy_sheet["system"]["abilities"]["str"]["mod"] = int(str_field.get_value())
	new_enemy_sheet["system"]["abilities"]["dex"]["mod"] = int(dex_field.get_value())
	new_enemy_sheet["system"]["abilities"]["con"]["mod"] = int(con_field.get_value())
	new_enemy_sheet["system"]["abilities"]["int"]["mod"] = int(int_field.get_value())
	new_enemy_sheet["system"]["abilities"]["wis"]["mod"] = int(wis_field.get_value())
	new_enemy_sheet["system"]["abilities"]["cha"]["mod"] = int(cha_field.get_value())
	
	# Speeds
	for speed_field in speed_field_v_box.get_children():
		if speed_field is SpeedField:
			if speed_field.option_button.selected == 0:
				attributes["speed"]["value"] = int(speed_field.speed_amount.text)
			elif speed_field.option_button.selected != 5:
				attributes["speed"]["otherSpeeds"].append({"type": speed_field.option_button.get_item_text(speed_field.option_button.selected), "value": int(speed_field.speed_amount.text)})
			else:
				attributes["speed"]["otherSpeeds"].append({"type": speed_field.custom_speed_line.text, "value": int(speed_field.speed_amount.text)})
	
	#endregion
	
	#region Defense
	
	attributes["hp"]["max"] = int(hp_field.get_value())
	attributes["ac"]["value"] = int(ac_field.get_value())
	system["saves"]["fortitude"]["value"] = int(fortitude_save_field.get_value())
	system["saves"]["reflex"]["value"] = int(reflex_save_field.get_value())
	system["saves"]["will"]["value"] = int(will_save_field.get_value())

	# Weaknesses, resistances, immunities
	for weakness_field in weaknesses_v_box.get_children():
		if weakness_field is WeaknessResistanceField:
			if weakness_field.damage_type_name.text != "":
				attributes["weaknesses"].append({"type": weakness_field.damage_type_name.text, "value": weakness_field.resist_value.value})
	for resistance_field in resistances_v_box.get_children():
		if resistance_field is WeaknessResistanceField:
			if resistance_field.damage_type_name.text != "":
				attributes["resistances"].append({"type": resistance_field.damage_type_name.text, "value": resistance_field.resist_value.value})
	for immunity_field in immunities_v_box.get_children():
		if immunity_field is LineEdit:
			if immunity_field.text != "":
				attributes["immunities"].append({"type": immunity_field.text})
	
	
	ability_formatter(defensive_abilities_v_box.get_children(), new_enemy_sheet["items"], true)
	
	#endregion
	
	#region Offense
	for strike_container in strikes_vbox.get_children():
		if strike_container is EnemyCreatorStrikeContainer:
			var strike_data: EnemyCreatorStrike = strike_container.strike_data
			if strike_data.strike_name == "":
				continue
			
			var new_attack: Dictionary = EnemySheetExample.ATTACK_TEMPLATE.duplicate(true)
			new_attack["name"] = strike_data.strike_name
			new_attack["system"]["bonus"]["value"] = strike_data.strike_bonus
			new_attack["system"]["oneLineDamageRoll"] = strike_data.strike_damage
			
			if strike_data.strike_type == EnemyCreatorStrike.StrikeType.RANGED:
				strike_data.traits.append("ranged") # To qualify for showing up as "ranged" on the sheet
			
			for attack_trait in strike_data.traits:
				new_attack["system"]["traits"]["value"].append(attack_trait)
			
			new_enemy_sheet["items"].append(new_attack)
	
	ability_formatter(offensive_abilities_v_box.get_children(), new_enemy_sheet["items"], false)
	
	#endregion
	
	var file_name: String = new_enemy_sheet["name"]
	var base_file_name: String = file_name
	var directory := DirAccess.open(CUSTOM_ENEMIES_LOCATION)
	var i: int = 1
	while has_file_name(file_name, directory):
		file_name = base_file_name + "-" + str(i)
		print(file_name)
		i += 1
	
	var new_file = FileAccess.open(CUSTOM_ENEMIES_LOCATION + file_name + ".json", FileAccess.WRITE)
	new_file.store_line(JSON.stringify(new_enemy_sheet, "\t"))
	new_file.close()
	emit_signal("sheet_created")

# If defense is false, then offense
func ability_formatter(ability_nodes: Array[Node], items_array: Array, defense: bool = true):
	for ability in ability_nodes:
		if ability is EnemyAbility:
			if ability.name_field.get_value() == "":
				continue
			
			var new_ability: Dictionary = EnemySheetExample.ABILITY_TEMPLATE.duplicate(true)
			new_ability["name"] = ability.name_field.get_value()
			match ability.action_option.selected:
				0, 1, 2:
					new_ability["system"]["actions"]["value"] = str(ability.action_option.selected)
				3:
					new_ability["system"]["actionType"]["value"] = "free"
				4:
					new_ability["system"]["actionType"]["value"] = "reaction"
			
			if ability.action_option.selected == 3:
				new_ability["system"]["description"]["value"] = "<strong>Trigger</strong> " + ability.trigger_text_edit.text + "; <strong>Effect</strong> " + ability.effect_text_edit.text
			else:
				new_ability["system"]["description"]["value"] = ability.effect_text_edit.text
		
			if defense:
				new_ability["system"]["category"] = "defensive"
			
			items_array.append(new_ability)

func has_file_name(file_name: String, folder: DirAccess):
	return folder.get_files().has(file_name + ".json")
