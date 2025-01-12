extends Node

signal sheet_created(file_address: String)

@onready var source_field: LabelDataField = %SourceField
@onready var name_field: LabelDataField = %NameField
@onready var level_field: LabelDataField = %LevelField
@onready var perception_field: LabelDataField = %PerceptionField
@onready var senses_field: LabelDataField = %SensesField
@onready var languages_field: LabelDataField = %LanguagesField
@onready var traits_text_edit: TextEdit = %TraitsTextEdit
@onready var notes_text_edit: TextEdit = %NotesTextEdit
@onready var speed_field_v_box: VBoxContainer = %SpeedFieldVBox
@onready var size_option: OptionButton = %SizeOption

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
@onready var extra_save_notes: LabelDataField = %ExtraSaveNotes
@onready var weaknesses_v_box: VBoxContainer = %WeaknessesVBox
@onready var resistances_v_box: VBoxContainer = %ResistancesVBox
@onready var immunities_v_box: VBoxContainer = %ImmunitiesVBox
@onready var defensive_abilities_v_box: VBoxContainer = %DefensiveAbilitiesVBox

@onready var strikes_vbox: VBoxContainer = %StrikesVbox
@onready var offensive_abilities_v_box: VBoxContainer = %OffensiveAbilitiesVBox

@onready var skills_vbox: VBoxContainer = %SkillsVbox

@onready var spell_list_box: OptionButton = %SpellListBox
@onready var casting_type_box: OptionButton = %CastingTypeBox
@onready var spell_dc_field: LabelDataField = %SpellDCField
@onready var spell_attack_field: LabelDataField = %SpellAttackField
@onready var cantrips_field: LabelDataField = %CantripsField
@onready var spell_fields_container: VBoxContainer = %SpellFieldsContainer
'@onready var _1_st_rank_field: LabelDataField = %"1stRankField"
@onready var _2_nd_rank_field: LabelDataField = %"2ndRankField"
@onready var _3_rd_rank_field: LabelDataField = %"3rdRankField"
@onready var _4_th_rank_field: LabelDataField = %"4thRankField"
@onready var _5_th_rank_field: LabelDataField = %"5thRankField"
@onready var _6_th_rank_field: LabelDataField = %"6thRankField"
@onready var _7_th_rank_field: LabelDataField = %"7thRankField"
@onready var _8_th_rank_field: LabelDataField = %"8thRankField"
@onready var _9_th_rank_field: LabelDataField = %"9thRankField"
@onready var _10_th_rank_field: LabelDataField = %"10thRankField"'
@onready var constant_spells_field: LabelDataField = %ConstantSpellsField

const CUSTOM_ENEMIES_LOCATION: String = "user://Enemies/custom-enemies/"
const EnemySheetExample = preload("res://EnemySheet/EnemySheetExample.gd")

func create_enemy(editing: bool = false):
	#region Error checking
	
	if name_field.get_value().strip_edges() == "":
		EventBus.error_popup.emit("Name is required to save enemy.")
		return
	
	for character in ["\\", "/", ":", "*", "?", "\"", "<", ">", "|"]:
		if name_field.get_value().contains(character):
			EventBus.error_popup.emit("Name cannot contain the following characters: \\ / : * ? \" < > |")
			return
	
	
	#endregion
	
	var new_enemy_sheet: Dictionary = {}
	var example = EnemySheetExample.new()
	new_enemy_sheet = example.DEFAULT.duplicate(true)
	example.queue_free()
	
	var system: Dictionary = new_enemy_sheet["system"]
	var details: Dictionary = system["details"]
	var attributes: Dictionary = system["attributes"]
	var traits: Dictionary = system["traits"]
	
	#region General
	
	if source_field.get_value().strip_edges() == "":
		source_field.set_value("Custom Enemy")
	system["details"]["source"]["value"] = source_field.get_value()
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
	
	traits["size"]["value"] = size_option.get_item_text(size_option.selected).to_upper()
	
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
	attributes["allSaves"]["value"] = extra_save_notes.get_value()
	
	
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
				new_attack["system"]["weaponType"] = "ranged"
				strike_data.traits.append("ranged") # To qualify for showing up as "ranged" on the sheet
			
			for attack_trait in strike_data.traits:
				new_attack["system"]["traits"]["value"].append(attack_trait)
			
			new_enemy_sheet["items"].append(new_attack)
	
	ability_formatter(offensive_abilities_v_box.get_children(), new_enemy_sheet["items"], false)
	
	#endregion
	
	#region Skills
	
	for skill in skills_vbox.get_children():
		if skill is EnemyCreatorSkill:
			if int(skill.label_data_field.get_value()) > 0:
				var skill_name: String = skill.skill_name
				var new_skill: Dictionary = EnemySheetExample.SKILL_TEMPLATE.duplicate(true)
				new_skill["name"] = skill_name
				new_skill["system"]["mod"]["value"] = int(skill.label_data_field.get_value())
				new_enemy_sheet["items"].append(new_skill)
	
	#endregion
	
	#region Spellcasting
	
	var i: int = 0
	if spell_list_box.selected != 0:
		var spells_found: bool = false
		var spell_field_value: String = ""
		for spell_field in spell_fields_container.get_children():
			if spell_field is LabelDataField:
				var constant: bool = spell_field == constant_spells_field
				spell_field_value = spell_field.get_value()
				if spell_field_value != "":
					spells_found = true
					add_spell_entry(i, spell_field_value, new_enemy_sheet["items"], constant)
			i += 1
		
		if spells_found:
			var new_casting_entry: Dictionary = EnemySheetExample.SPELLCASTING_TEMPLATE.duplicate(true)
			new_casting_entry["name"] = spell_list_box.get_item_text(spell_list_box.selected) + " " + casting_type_box.get_item_text(casting_type_box.selected) + " Spells"
			new_casting_entry["system"]["spelldc"]["dc"] = int(spell_dc_field.get_value())
			new_casting_entry["system"]["spelldc"]["value"] = int(spell_attack_field.get_value())
			new_casting_entry["system"]["tradition"]["value"] = spell_list_box.get_item_text(spell_list_box.selected).to_lower()
			new_casting_entry["system"]["prepared"]["value"] = casting_type_box.get_item_text(casting_type_box.selected).to_lower()
			new_enemy_sheet["items"].append(new_casting_entry)
	
	
	#endregion
	
	var file_name: String = new_enemy_sheet["name"]
	file_name.replace("\"", "")
	var base_file_name: String = file_name
	var directory := DirAccess.open(CUSTOM_ENEMIES_LOCATION)
	i = 0
	if !editing:
		while has_file_name(file_name, directory):
			file_name = base_file_name + "-" + str(i + 1)
			print(file_name)
			i += 1
	
	var file_address: String = CUSTOM_ENEMIES_LOCATION + file_name + ".json"
	var new_file = FileAccess.open(file_address, FileAccess.WRITE)
	new_file.store_line(JSON.stringify(new_enemy_sheet, "\t"))
	new_file.close()
	sheet_created.emit(file_address)

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
					new_ability["system"]["actions"]["value"] = str(1 + ability.action_option.selected)
					new_ability["system"]["actionType"]["value"] = "action"
				3:
					new_ability["system"]["actionType"]["value"] = "free"
				4:
					new_ability["system"]["actionType"]["value"] = "reaction"
				5:
					new_ability["system"]["actionType"]["value"] = "passive"
			
			if ability.action_option.selected == 4:
				new_ability["system"]["description"]["value"] = "<strong>Trigger</strong> " + ability.trigger_text_edit.text + " <strong>Effect</strong> " + ability.effect_text_edit.text
			else:
				new_ability["system"]["description"]["value"] = ability.effect_text_edit.text
		
			if defense:
				new_ability["system"]["category"] = "defensive"
			
			for ability_trait in ability.traits_field.get_value().split(",", false):
				new_ability["system"]["traits"]["value"].append(ability_trait.strip_edges())
			
			items_array.append(new_ability)

func add_spell_entry(spell_level: int, spell_field_value: String, items_array: Array, constant: bool = false):
	spell_field_value = spell_field_value.replace(", ", ",")
	var spells: PackedStringArray = spell_field_value.split(",", false)
	for spell in spells:
		var new_spell_entry: Dictionary = EnemySheetExample.SPELL_TEMPLATE.duplicate(true)
		new_spell_entry["name"] = spell
		if constant:
			new_spell_entry["name"] += " (Constant)"
		new_spell_entry["system"]["level"]["value"] = spell_level
		if spell_level == 0:
			new_spell_entry["system"]["traits"]["value"].append("cantrip")
		items_array.append(new_spell_entry)

func has_file_name(file_name: String, folder: DirAccess):
	return folder.get_files().has(file_name + ".json")
