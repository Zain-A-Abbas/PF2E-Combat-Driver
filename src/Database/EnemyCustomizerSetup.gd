extends Node

#region Onreadies

@onready var source_field: LabelDataField = %SourceField
@onready var name_field: LabelDataField = %NameField
@onready var level_field: LabelDataField = %LevelField
@onready var perception_field: LabelDataField = %PerceptionField
@onready var rarity_button: OptionButton = %RarityButton
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

@onready var casting_entry_tabs: TabContainer = %CastingEntryTabs

@onready var attacks: VBoxContainer = %Attacks
@onready var spells: VBoxContainer = %Spells

@onready var option_button: OptionButton = %OptionButton
@onready var autofill_button: Button = %AutofillButton

#endregion

@onready var enemy_creator: EnemyCreator = $".."
@onready var defensive: VBoxContainer = %Defensive
@onready var skills_vbox: VBoxContainer = %SkillsVbox

const SPEEDS : Array[String] = ["Land", "Fly", "Swim", "Climb", "Burrow"]
const SPEED_FIELD = preload("res://Custom/SpeedField.tscn")
const ELEMENTS : Array[String] = ["None", "Acid", "All", "Bleed", "Bludgeoning", "Chaotic", "Cold", "Cold Iron", "Electricity", "Evil", "Fire", "Force", "Good", "Lawful", "Mental", "Negative", "Orichalum", "Physical", "Piercing", "Poison", "Positive", "Precision", "Silver", "Slashing", "Sonic", "Splash"]

const WEAKNESS_RESISTANCE_FIELD = preload("res://Custom/WeaknessResistanceField.tscn")
const ENEMY_ABILITY = preload("res://Custom/EnemyAbility.tscn")
const ENEMY_CREATOR_STRIKE_CONTAINER = preload("res://Custom/EnemyCreatorStrikeContainer.tscn")
const CASTING_ENTRY = preload("res://Custom/CastingEntry.tscn")
var sheet: Sheet

func customize_current_enemy(editing: bool):
	
	if sheet == null:
		return
	if sheet.enemy_data == {}:
		return
	
	enemy_creator.editing = editing
	
	var ability_interpreter: TextInterpreter = TextInterpreter.new()
	
	var enemy_data: Dictionary = sheet.enemy_data
	var enemy_system: Dictionary = sheet.enemy_system
	var enemy_abilities: Array = sheet.enemy_abilities
	var enemy_attributes: Dictionary = sheet.enemy_attributes
	
	var old_sheet: bool = enemy_system["details"].has("source")
	
	#region General
	
	if old_sheet:
		source_field.set_value(enemy_system["details"]["source"]["value"])
	else:
		source_field.set_value(enemy_system["details"]["publication"]["title"])
	name_field.set_value(enemy_data["name"])
	name_field.line_edit.editable = !editing # Can't change if just editing sheet
	level_field.set_value_num(enemy_system["details"]["level"]["value"])
	
	var size: String = Trait.trait_interpreter(enemy_system["traits"]["size"]["value"])
	match size:
		"TINY":
			size_option.select(0)
		"SMALL":
			size_option.select(1)
		"MEDIUM":
			size_option.select(2)
		"LARGE":
			size_option.select(3)
		"HUGE":
			size_option.select(4)
		"GARGANTUAN":
			size_option.select(5)
	
	str_field.set_value_num(enemy_system["abilities"]["str"]["mod"])
	dex_field.set_value_num(enemy_system["abilities"]["dex"]["mod"])
	con_field.set_value_num(enemy_system["abilities"]["con"]["mod"])
	int_field.set_value_num(enemy_system["abilities"]["int"]["mod"])
	wis_field.set_value_num(enemy_system["abilities"]["wis"]["mod"])
	cha_field.set_value_num(enemy_system["abilities"]["cha"]["mod"])
	
	if old_sheet:
		perception_field.set_value_num(enemy_system["attributes"]["perception"]["value"])
	else:
		perception_field.set_value_num(enemy_system["perception"]["mod"])
	
	if old_sheet:
		if enemy_system["traits"]["senses"] is Array:
			senses_field.set_value(
				", ".join(PackedStringArray(enemy_system["traits"]["senses"]))
			)
		else:
			senses_field.set_value(enemy_system["traits"]["senses"]["value"])
	else:
		var senses_array: Array = enemy_system["perception"]["senses"]
		var senses_text: PackedStringArray = [] 
		for sense in senses_array:
			var sense_text: String = sense["type"]
			sense_text.replace("-", " ")
			if sense.has("acuity"):
				sense_text += " (" + sense["acuity"] + ")"
			if sense.has("range"):
				sense_text += " " + str(sense["range"])
			senses_text.append(sense_text)
		senses_field.set_value(
				", ".join(senses_text)
			)
	if old_sheet:
		languages_field.set_value(", ".join(PackedStringArray(enemy_system["traits"]["languages"]["value"])))
	else:
		languages_field.set_value(", ".join(PackedStringArray(enemy_system["details"]["languages"]["value"])))
	traits_text_edit.text = ", ".join(PackedStringArray(enemy_system["traits"]["value"]))
	
	# Rarity
	var rarity_text: String
	if !enemy_system["traits"].has("rarity"):
		rarity_button.select(3)
		rarity_text = "unique"
	else:
		rarity_text = enemy_system["traits"]["rarity"].to_lower()
		match rarity_text:
			"common":
				rarity_button.select(0)
			"uncommon":
				rarity_button.select(1)
			"rare":
				rarity_button.select(2)
			"unique":
				rarity_button.select(3)
			_:
				rarity_button.select(0)
	'if !enemy_system["traits"]["value"].has(rarity_text):
			if traits_text_edit.text != "":
				traits_text_edit.text += ", "
			traits_text_edit.text += rarity_text'
	
	# Speeds
	for child in speed_field_v_box.get_children():
		child.queue_free()
	var speed: Dictionary = enemy_attributes["speed"]
	if speed["value"] != null:
		if speed["value"] > 0:
			var new_land_speed: SpeedField = SPEED_FIELD.instantiate()
			speed_field_v_box.add_child(new_land_speed)
			new_land_speed.option_button.select(0)
			new_land_speed.speed_amount.text = str(speed["value"])
	
	var other_speeds: Array[Dictionary] = []
	if speed.has("otherSpeeds"):
		for speed_type in speed["otherSpeeds"]:
			other_speeds.append(speed_type)
	
	for other_speed in other_speeds:
		var new_speed: SpeedField = SPEED_FIELD.instantiate()
		speed_field_v_box.add_child(new_speed)
		if SPEEDS.has(other_speed["type"].capitalize()):
			new_speed.option_button.select(SPEEDS.find(other_speed["type"].capitalize()))
		else:
			new_speed.option_button.select(5)
			new_speed.custom_speed_line.visible = true
			new_speed.custom_speed_line.text = other_speed["type"]
		new_speed.speed_amount.text = str(other_speed["value"])
	
	#endregion
	
	#region Defensive
	
	hp_field.set_value_num(enemy_attributes["hp"]["max"])
	ac_field.set_value_num(enemy_attributes["ac"]["value"])
	fortitude_save_field.set_value_num(enemy_system["saves"]["fortitude"]["value"])
	reflex_save_field.set_value_num(enemy_system["saves"]["reflex"]["value"])
	will_save_field.set_value_num(enemy_system["saves"]["will"]["value"])
	
	var add_resistances_or_weaknesses = func(vbox: VBoxContainer, key: String):
		for child in vbox.get_children():
			if child is Button:
				continue
			child.queue_free()
		if enemy_attributes.has(key):
			for element in enemy_attributes[key]:
				var element_name: String = element["type"]
				var element_amount: String = str(element["value"])
				var new_element: WeaknessResistanceField = WEAKNESS_RESISTANCE_FIELD.instantiate()
				vbox.add_child(new_element)
				vbox.move_child(new_element, vbox.get_child_count() - 2)
				new_element.damage_type_name.text = element_name
				new_element.resist_value.value = int(element_amount)
				defensive.setup_new_resist(new_element)
	
	add_resistances_or_weaknesses.call(weaknesses_v_box, "weaknesses")
	add_resistances_or_weaknesses.call(resistances_v_box, "resistances")
	
	for child in immunities_v_box.get_children():
		if child is Button:
			continue
		child.queue_free()
	if enemy_attributes.has("immunities"):
		for immunity in enemy_attributes["immunities"]:
			var new_immunity: LineEdit = LineEdit.new()
			immunities_v_box.add_child(new_immunity)
			immunities_v_box.move_child(new_immunity, immunities_v_box.get_child_count() - 2)
			new_immunity.text = immunity["type"]
			defensive.setup_new_immunity(new_immunity)
	
	if enemy_attributes["allSaves"]["value"] != "" && enemy_attributes["allSaves"]["value"] != null:
		extra_save_notes.set_value(enemy_attributes["allSaves"]["value"])
	
	#endregion
	
	#region Strikes
	
	for strike in strikes_vbox.get_children():
		if strike is EnemyCreatorStrikeContainer:
			strike.queue_free()
	for ability in enemy_abilities:
		if ability["type"] != "melee":
			continue
		var attack_traits_array: Array[String] = []
		if ability["system"]["traits"]["value"] is Array[String]:
			attack_traits_array = ability["system"]["traits"]["value"]
		else:
			for attack_trait in ability["system"]["traits"]["value"]:
				attack_traits_array.append(str(attack_trait))
		
		var ranged: bool = false
		if ability["system"].has("weaponType"):
				if ability["system"]["weaponType"]["value"] == "ranged":
					ranged = true
		if !ranged:
			for attack_trait in attack_traits_array:
				if attack_trait.contains("range-increment") || attack_trait.contains("ranged"):
					ranged = true
		
		# Damage
		var damage_text: String = ""
		var i: int = 0
		for damage_roll in ability["system"]["damageRolls"].keys():
			if i > 0:
				damage_text += " plus "
			damage_text += ability["system"]["damageRolls"][damage_roll]["damage"] + " " + ability["system"]["damageRolls"][damage_roll]["damageType"] 
			i += 1
		if ability["system"].has("oneLineDamageRoll"):
			damage_text += ability["system"]["oneLineDamageRoll"]

		attacks.new_data_attack(
			str(ability["system"]["bonus"]["value"]),
			damage_text,
			ranged,
			ability["name"],
			attack_traits_array
			)
	
	#endregion
	
	#region Special Abilities
	# Add special abilities, both offensive and defensive
	for child in defensive_abilities_v_box.get_children():
		child.queue_free()
	for child in offensive_abilities_v_box.get_children():
		child.queue_free()
	for ability in enemy_abilities:
		var defensive_ability: bool = true
		var valid_ability: bool = false
		if ability["system"].has("category"):
			if ability["system"]["category"] is String:
				if (ability["system"]["category"] == "defensive") || (ability["system"]["category"] == "interaction" && ability["system"]["actionType"]["value"] == "reaction" || ability["system"]["category"] == "offensive"):
					valid_ability = true
					if ability["system"]["category"] == "offensive":
						defensive_ability = false
		if ability["system"].has("rules"):
			if !ability["system"]["rules"].is_empty():
				if ability["system"]["rules"][0]["key"] == "FlatModifier":
					valid_ability = false
		if !valid_ability:
			continue
		
		var new_ability: EnemyAbility = ENEMY_ABILITY.instantiate()
		if defensive_ability:
			defensive_abilities_v_box.add_child(new_ability)
		else:
			offensive_abilities_v_box.add_child(new_ability)
		new_ability.name_field.set_value(ability["name"])
		
		var ability_traits: String = ""
		var i: int = 0
		for ability_trait in ability["system"]["traits"]["value"]:
			ability_traits += ability_trait
			i += 1
			if i < ability["system"]["traits"]["value"].size():
				ability_traits += ", "
		new_ability.traits_field.set_value(ability_traits)
		
		var ability_description: String = ability_interpreter.ability_parser(
			ability["system"]["description"]["value"]
		)
		
		new_ability.effect_text_edit.text = ability_description
		
		var action_type: String = ability["system"]["actionType"]["value"]
		if action_type == "reaction":
			new_ability.action_option.select(4)
			new_ability._on_action_option_item_selected(4)
			
			var regex: RegEx = RegEx.new()
			regex.compile("\\[b\\]Trigger\\[\\/b\\](.*)\\[b\\]Effect\\[\\/b\\](.*)")
			var reaction_data: RegExMatch = regex.search(ability_description)
			if reaction_data:
				new_ability.trigger_text_edit.text = reaction_data.strings[1].strip_edges()
				new_ability.effect_text_edit.text = reaction_data.strings[2].strip_edges()
		elif action_type == "action":
			# -1 as index 0 is 1 action
			var action_count: int = int(ability["system"]["actions"]["value"]) - 1
			new_ability.action_option.select(action_count)
			new_ability._on_action_option_item_selected(action_count)
		elif action_type == "passive":
			new_ability.action_option.select(5)
			new_ability._on_action_option_item_selected(5)
			
		else:
			new_ability.action_option.select(3)
			new_ability._on_action_option_item_selected(3)
	
	#endregion
	
	#region Skills
	
	for skill in skills_vbox.get_children():
		if skill is EnemyCreatorSkill:
			skill.label_data_field.set_value_num("")
	for ability in enemy_abilities:
		if ability["type"] != "lore":
			continue
		for skill in skills_vbox.get_children():
			if skill is EnemyCreatorSkill:
				if skill.skill_name == ability["name"]:
					skill.label_data_field.set_value_num(ability["system"]["mod"]["value"])
	
	#endregion
	
	#region Spellcasting
	for child in casting_entry_tabs.get_children():
		child.queue_free()
	
	for ability in enemy_abilities:
		if ability["type"] != "spellcastingEntry":
			continue
		var new_casting_entry: CastingEntry = CASTING_ENTRY.instantiate()
		casting_entry_tabs.add_child(new_casting_entry)
		new_casting_entry.name = ability["name"]
		new_casting_entry.entry_name_field.set_value(ability["name"])
		new_casting_entry.spell_dc_field.set_value_num(ability["system"]["spelldc"]["dc"])
		new_casting_entry.spell_attack_field.set_value_num(ability["system"]["spelldc"]["value"])
		if !ability.has("_id"):
			ability["_id"] = ""
		if ability["_id"] == "":
			ability["_id"] = ability["name"]
		
		
		for spell_ability in enemy_abilities:
			if spell_ability["type"] != "spell":
				continue
			# If spell is not associated with any spell list then associate it with this one
			if spell_ability["system"]["location"]["value"] == "":
				spell_ability["system"]["location"]["value"] = ability["_id"]
			# If spell is associated with a spell list but not this one then move on
			if spell_ability["system"]["location"]["value"] != ability["_id"]:
				continue
			
			var spell_rank: int
			var spell_name: String = spell_ability["name"]
			
			if spell_ability["system"]["location"].has("heightenedLevel"):
				spell_rank = spell_ability["system"]["location"]["heightenedLevel"]
			else:
				spell_rank = spell_ability["system"]["level"]["value"]
			
			var spell_field: LabelDataField
			if spell_ability["system"]["traits"]["value"].has("cantrip"):
				spell_field = new_casting_entry.spell_fields_container.get_child(0)
			elif spell_ability["name"].to_lower().contains("(constant)"):
				spell_field = new_casting_entry.constant_spells_field
				spell_name = spell_name.replace("(Constant)", "")
				spell_name = spell_name.replace("(constant)", "")
				spell_name = spell_name.strip_edges()
			else:
				spell_field = new_casting_entry.spell_fields_container.get_child(spell_rank)
			
			var spell_text: String = spell_field.get_value()
			if spell_text == "":
				spell_field.set_value(spell_name)
			else:
				spell_field.set_value(spell_text + ", " + spell_name)
	
	
	var parent: Node = enemy_creator.get_parent()
	if parent is Window:
		parent.show()
		return
