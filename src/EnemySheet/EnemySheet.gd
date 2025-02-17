extends Control
class_name Sheet

const trait_template := preload("res://Trait.tscn")
const SHEET_CONTENT := preload("res://EnemySheet/SheetContent.tscn")

const ONE_ACTION := "[img=24]res://Icons/Action.png[/img]"
const TWO_ACTIVITY := "[img=24]res://Icons/2Activity.png[/img]"
const THREE_ACTIVITY := "[img=24]res://Icons/3Activity.png[/img]"
const REACTION := "[img=24]res://Icons/Reaction.png[/img]"
const FREE_ACTION := "[img=24]res://Icons/FreeAction.png[/img]"

@onready var enemy_name := $SheetData/SheetScroller/SheetInfo/Header/EnemyName
@onready var enemy_level := $SheetData/SheetScroller/SheetInfo/Header/EnemyLevel
@onready var trait_container := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Traits
@onready var enemy_source := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Source
@onready var senses = $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Senses
@onready var languages := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Languages
@onready var skills := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Skills
@onready var abilities := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Abilities
@onready var ac_saves := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/ACSaves
@onready var hp_resistances := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/HPResistances
@onready var defensive_abilities := $SheetData/SheetScroller/SheetInfo/SheetMargin/Data/DefensiveAbilities
@onready var attacks := $"SheetData/SheetScroller/SheetInfo/SheetMargin/Data/Speed&OffensiveAbilities"

# A lot of these are their own variable just for faster referencing
var enemy_data: Dictionary = {}
var enemy_system: Dictionary = {}
var enemy_abilities: Array = []
var enemy_attributes: Dictionary = {}

var old_sheet: bool = false

# For zooming during runtime
static var sheet_theme: Theme = load("res://Themes/EnemySheetContext.tres")

func _ready() -> void:
	senses.meta_clicked.connect(sheet_content_clicked)

func setup(enemy_file, conditions = {}):
	# Gets the enemy sheet data
	enemy_data = enemy_file
	
	enemy_system = enemy_data["system"]
	enemy_abilities = enemy_data["items"]
	enemy_attributes = enemy_system["attributes"]
	
	old_sheet = enemy_system["details"].has("source")
	
	# Set up name and level
	if !conditions.has("custom_name"):
		enemy_name.text = enemy_data["name"]
	else:
		enemy_name.text = conditions["custom_name"]
	enemy_level.text = "CREATURE " + str(enemy_system["details"]["level"]["value"])
	
	
	
	# Set up traits
	setup_traits()
	# Enemy Source
	var source: String
	if old_sheet:
		source = enemy_system["details"]["source"]["value"]
	else:
		source = enemy_system["details"]["publication"]["title"]
	enemy_source.text = "[b]Source[/b] [i]" + source + "[/i]"
	
	# Enemy Senses
	setup_senses()
	
	# Enemy Languages
	setup_languages()
	
	# Enemy Skills
	setup_skills()
	
	# Enemy Ability Mods
	setup_ability_mods()
	
	# Enemy Defensive Abilities
	setup_defensive_abilities()
	
	# Enemy Speed
	setup_speed()
	
	# Enemy Attacks
	setup_attacks()
	
	# Enemy Spells
	setup_spells()
	
	# Other offensive abilities
	setup_offensive_abilities()
	
	finalize_sheet_content()

func finalize_sheet_content():
	for child in find_children("", "SheetContent", true, false):
		child.enemy_name = enemy_data["name"]

func setup_traits():
	# Clean up anything already there
	var trait_data = enemy_system["traits"]
	var i: int = 0
	for child in trait_container.get_children():
		if i > 0:
			child.queue_free()
		i += 1
	
	# Rarity
	# It has the if-else because to designate if an enemy is unique or not sometimes it will 
		# have the rarity set to "unique". other times it will not have a rarity variable at all.
			# these are the mysteries
	if trait_data.has("rarity"):
		if trait_data["rarity"] != "common":
			insert_trait(trait_data["rarity"].to_upper())
	else:
		insert_trait("UNIQUE")
	
	# Alignment
	if enemy_system["details"].has("alignment"):
		if enemy_system["details"]["alignment"].has("value"):
			if enemy_system["details"]["alignment"]["value"] != "":
				insert_trait(enemy_system["details"]["alignment"]["value"])
	
	# Size
	insert_trait(trait_data["size"]["value"])
	
	# Remaining traits
	for regular_trait in trait_data["value"]:
		insert_trait(regular_trait.to_upper())

func insert_trait(trait_name: String):
	var new_trait = trait_template.instantiate()
	trait_container.add_child(new_trait)
	new_trait.trait_name = trait_name

func setup_senses():
	var i: int = 0
	senses.text = ""
	var perception_value: int
	if old_sheet:
		perception_value = enemy_system["attributes"]["perception"]["value"]
	else:
		perception_value = enemy_system["perception"]["mod"]
	var perception: String = "[b]Perception[/b] " + "+" + get_d20_meta(perception_value, "Perception")
	
	var enemy_senses: Array[String] = []
	
	if !old_sheet:
		var senses_array: Array = enemy_system["perception"]["senses"]
		for sense in senses_array:
			var sense_text: String = sense["type"]
			sense_text.replace("-", " ")
			if sense.has("acuity"):
				sense_text += " (" + sense["acuity"] + ")"
			if sense.has("range"):
				sense_text += " " + str(sense["range"])
			enemy_senses.append(sense_text)
	else:
		if enemy_system["traits"]["senses"] is Array:
			enemy_senses.assign(enemy_system["traits"]["senses"])
		else:
			enemy_senses.assign(enemy_system["traits"]["senses"]["value"].split(","))
		
		if !enemy_senses.is_empty():
			if enemy_senses[0] != "":
				for sense in enemy_senses:
					if sense[0] == " ":
						enemy_senses[i] = sense.substr(1)
					i += 1
	
	senses.text += perception
	if !enemy_senses.is_empty():
		if enemy_senses[0] != "":
			senses.text += "; "
	
	# Add tooltips to the senses
	i = 0
	for sense in enemy_senses:
		# A few random enemies have this. What the hell? They don't even use <i> otherwise, it's <em>.
		enemy_senses[i] = enemy_senses[i].replace("<i>", "[i]")
		enemy_senses[i] = enemy_senses[i].replace("</i>", "[/i]")
		#enemy_senses[i] = get_sheet_tooltip("sense", sense) + sense + "[/hint]"
		senses.text += enemy_senses[i]
		if enemy_senses.size() > i + 1:
			senses.text += ", "
		i += 1

func setup_languages():
	var languages_array: Array
	if old_sheet:
		languages_array = enemy_system["traits"]["languages"]["value"]
	else:
		languages_array = enemy_system["details"]["languages"]["value"]
	if languages_array.is_empty():
		languages.visible = false
		return
	languages.visible = true
	languages.text = "[b]Languages[/b] "
	var monster_languages: Array = languages_array
	var i: int = 0
	for language in monster_languages:
		languages.text += "[i]" + language.capitalize() + "[/i]"
		i += 1
		if i < monster_languages.size():
			languages.text += ", "

func setup_skills():
	skills.text = "[b]Skills[/b] "
	var enemy_skills: Array = []
	for ability in enemy_abilities:
		if ability["type"] == "lore":
			enemy_skills.append(ability)
	
	var i: int = 0
	for skill in enemy_skills:
		var skill_text = "[i]" + skill["name"] + "[/i]" + " +" + get_d20_meta(skill["system"]["mod"]["value"], skill["name"])
		skills.text += skill_text
		i += 1
		if i < enemy_skills.size():
			skills.text += ", "

func setup_ability_mods():
	abilities.text = ""
	# This code is horrible but I would do this faster than finding a way to make it look better
	var positive_negative := "+"
	if enemy_system["abilities"]["str"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Str[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["str"]["mod"], "STR") + ", "
	if enemy_system["abilities"]["dex"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Dex[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["dex"]["mod"], "DEX") + ", "
	if enemy_system["abilities"]["con"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Con[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["con"]["mod"], "CON") + ", "
	if enemy_system["abilities"]["int"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Int[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["int"]["mod"], "INT") + ", "
	if enemy_system["abilities"]["wis"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Wis[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["wis"]["mod"], "WIS") + ", "
	if enemy_system["abilities"]["cha"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Cha[/b] " + positive_negative + get_d20_meta(enemy_system["abilities"]["cha"]["mod"], "CHA")

func setup_defensive_abilities():
	# AC and Saving Throws
	setup_ac_saves()
	
	# HP and Resistances
	setup_hp_immunities_weaknesses()
	
	# All other defensive abilities
	setup_other_defensive_abilities()

func setup_ac_saves():
	ac_saves.text = "[b]AC[/b] " + str(enemy_attributes["ac"]["value"]) + "; "
	var positive_negative := "+"
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Fort[/b] " + positive_negative + get_d20_meta(enemy_system["saves"]["fortitude"]["value"], "Fortitude") + ", "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Ref[/b] " + positive_negative + get_d20_meta(enemy_system["saves"]["reflex"]["value"], "Reflex") + ", "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Will[/b] " + positive_negative + get_d20_meta(enemy_system["saves"]["will"]["value"], "Will")
	
	if enemy_attributes["allSaves"]["value"] != "" && enemy_attributes["allSaves"]["value"] != null:
		ac_saves.text += "; " + enemy_attributes["allSaves"]["value"]

func setup_hp_immunities_weaknesses():
	hp_resistances.text = "[b]HP[/b] " + str(enemy_attributes["hp"]["max"])
	if enemy_attributes["hp"].has("details"):
		var extra_hp_info: String = " (" + enemy_attributes["hp"]["details"] + ")"
		if extra_hp_info != " ()":
			hp_resistances.text += " (" + enemy_attributes["hp"]["details"] + ")"
	
	if enemy_attributes.has("immunities"):
		if enemy_attributes["immunities"].size() > 0:
			hp_resistances.text += "; "
			hp_resistances.text += "[b]Immunities[/b] "
			var i: int = 0
			for immunity in enemy_attributes["immunities"]:
				hp_resistances.text += "[i]" + immunity["type"] + "[/i]"
				i += 1
				if i < enemy_attributes["immunities"].size():
					hp_resistances.text += ", "
	
	
	if enemy_attributes.has("resistances"):
		if enemy_attributes["resistances"].size() > 0:
			hp_resistances.text += "; "
			hp_resistances.text += "[b]Resistances[/b] "
			# Enabled at different points so double vs can show up with or without weakness exceptions
			var double_vs: bool = false
			var i: int = 0
			for resistance in enemy_attributes["resistances"]:
				hp_resistances.text += resistance["type"] + " " + str(resistance["value"])
				var j: int = 0
				if resistance.has("exceptions"):
					if resistance["exceptions"].size() > 0:
						hp_resistances.text += " (except "
						for exception in resistance["exceptions"]:
							hp_resistances.text += exception
							j += 1
							if j < resistance["exceptions"].size():
								hp_resistances.text += ", "
							else:
								if resistance.has("doubleVs"):
									if resistance["doubleVs"].size() > 0:
										double_vs = true
										hp_resistances.text += "; double resistance vs. "
										var k: int = 0
										for double_versus in resistance["doubleVs"]:
											hp_resistances.text += double_versus
											k += 1
											if k < resistance["doubleVs"].size():
												hp_resistances.text += ", "
						hp_resistances.text += ")"
				
				if resistance.has("doubleVs") && !double_vs:
					if resistance["doubleVs"].size() > 0:
						double_vs = true
						hp_resistances.text += "(double resistance vs. "
						var k: int = 0
						for double_versus in resistance["doubleVs"]:
							hp_resistances.text += double_versus
							k += 1
							if k < resistance["doubleVs"].size():
								hp_resistances.text += ", "
							else:
								hp_resistances.text += ")"
				i += 1
				if i < enemy_attributes["resistances"].size():
					hp_resistances.text += ", "
	
	
	if enemy_attributes.has("weaknesses"):
		if enemy_attributes["weaknesses"].size() > 0:
			hp_resistances.text += "; "
			hp_resistances.text += "[b]Weaknesses[/b] "
			var i: int = 0
			for weakness in enemy_attributes["weaknesses"]:
				hp_resistances.text += weakness["type"] + " " + str(weakness["value"])
				i += 1
				if i < enemy_attributes["weaknesses"].size():
					hp_resistances.text += ", "

func setup_other_defensive_abilities():
	var text_interpreter: TextInterpreter = TextInterpreter.new()
	defensive_abilities.visible = false
	for child in defensive_abilities.get_children():
		child.queue_free()
	
	for ability in enemy_abilities:
		var valid_ability: bool = false
		if ability["system"].has("category"):
			if ability["system"]["category"] is String:
				if (ability["system"]["category"] == "defensive") || (ability["system"]["category"] == "interaction" && ability["system"]["actionType"]["value"] == "reaction"):
					valid_ability = true
		if ability["system"].has("rules"):
			if !ability["system"]["rules"].is_empty():
				if ability["system"]["rules"][0]["key"] == "FlatModifier":
					valid_ability = false
		if !valid_ability:
			continue
		
		# Initialize ability
		var new_ability_entry = create_sheet_content()
		new_ability_entry.info_type = SheetContent.InfoTypes.TRAIT
		
		# Add name and reaction icon if applicable
		var ability_name = "[b]" + ability["name"] + "[/b] "
		var action_icon: String = ""
		if ability["system"]["actionType"]["value"] == "reaction":
			action_icon = REACTION + " "
		elif ability["system"]["actionType"]["value"] == "free":
			action_icon = FREE_ACTION + " "
		elif ability["system"]["actions"]["value"] != null:
			var action_count = ability["system"]["actions"]["value"]
			match int(action_count):
				1:
					action_icon = ONE_ACTION + " "
				2:
					action_icon = TWO_ACTIVITY + " "
				3:
					action_icon = THREE_ACTIVITY + " "
		
		# Add traits
		var ability_traits: String = "("
		var i: int = 0
		for ability_trait in ability["system"]["traits"]["value"]:
			#ability_traits += get_sheet_tooltip("trait", ability_trait) + ability_trait + "[/hint]"
			ability_traits += ability_trait
			i += 1
			if i < ability["system"]["traits"]["value"].size():
				ability_traits += ", "
		ability_traits += ") "
		if ability_traits == "() ":
			ability_traits = ""
		
		# Add description
		var desc_text: String = text_interpreter.ability_parser(ability["system"]["description"]["value"])
		desc_text = get_damage_roll_meta(desc_text)
		new_ability_entry.text = ability_name + action_icon + ability_traits + desc_text
		defensive_abilities.add_child(new_ability_entry)
	
	if defensive_abilities.get_child_count() > 0:
		defensive_abilities.visible = true

func setup_speed():
	for child in attacks.get_children():
		child.queue_free()
	var speed_entry = create_sheet_content()
	var speed_text: String = "[b]Speed[/b] "
	var speed = enemy_attributes["speed"]
	if speed["value"] != null:
		if speed["value"] > 0:
			speed_text += str(speed["value"]) + " feet"
	# Add different speed methods
	if speed.has("otherSpeeds"):
		for speed_type in speed["otherSpeeds"]:
			# comma viarbale stops speed from turning out like Speed , swim 50 if a creature has no land speed
			var comma: String = ", "
			if !speed_text.contains(" feet"):
				comma = ""
			speed_text += comma + speed_type["type"] + " " + str(speed_type["value"]) + " feet"
	
	# Add details such as magma swim
	if speed.has("details"):
		speed_text += "; " + speed["details"]
	speed_entry.text = speed_text
	attacks.add_child(speed_entry)
	attacks.visible = true

func setup_attacks():
	var text_interpreter: TextInterpreter = TextInterpreter.new()
	attacks.visible = false
	
	for ability in enemy_abilities:
		if ability["type"] == "melee":
			
			# Initialize ability
			var new_attack_entry = create_sheet_content()
			new_attack_entry.info_type = SheetContent.InfoTypes.TRAIT
			
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
			if ranged:
				for attack_trait in attack_traits_array:
					if attack_trait.contains("range-increment") || attack_trait.contains("ranged"):
						ranged = true
			
			
			# Add name and icon
			var melee: String
			if !ranged:
				melee = "[b]" + "Melee" + "[/b] "
			else:
				melee = "[b]" + "Ranged" + "[/b] "
			var attack_icon := ONE_ACTION + " "
			var attack_name: String = ability["name"] + " "
			
			# Attack bonus handling
			var attack_bonus: int = ability["system"]["bonus"]["value"]
				# Remove the "+" if the attack is negative
			var attack_plus: String = "+"
			if attack_bonus < 0:
				attack_plus = ""
			var multiple_attack_penalty: int = 5
			if attack_traits_array.has("agile"):
				multiple_attack_penalty = 4
			var attack_bonus_text: String = attack_plus + get_d20_meta(attack_bonus, "Attack") + " "
			if attack_bonus - multiple_attack_penalty < 0:
				attack_plus = ""
			attack_bonus_text += "[" + attack_plus + get_d20_meta(attack_bonus - multiple_attack_penalty, "Attack (MAP: -" + str(multiple_attack_penalty) + ")")
			if attack_bonus - multiple_attack_penalty * 2 < 0:
				attack_plus = ""
			attack_bonus_text += "/" + attack_plus + get_d20_meta(attack_bonus - multiple_attack_penalty * 2, "Attack (MAP: -" + str(multiple_attack_penalty * 2) + ")")
			attack_bonus_text += "] "
			
			# Traits
			var attack_traits: String = "("
			var i: int = 0
			for attack_trait in attack_traits_array:
				var final_trait: String = text_interpreter.trait_name_parser(attack_trait)
				#attack_traits += get_sheet_tooltip("trait", final_trait) + final_trait + "[/hint]"
				attack_traits += final_trait
				i += 1
				if i < attack_traits_array.size():
					attack_traits += ", "
			attack_traits += ") "
			if attack_traits == "() ":
				attack_traits = ""
			
			# Damage
			var damage_text: String = get_damage_text(ability)
			
			new_attack_entry.text = melee + attack_icon + attack_name + attack_bonus_text + attack_traits + damage_text
			attacks.add_child(new_attack_entry)
			
			
	
	if attacks.get_child_count() > 0:
		attacks.visible = true

func get_damage_text(ability: Dictionary) -> String:
	var system: Dictionary = ability["system"]
	const BASE_DAMAGE_TEXT: String = "[b]Damage[/b] "
	const BASE_EFFECT_TEXT: String = "[b]EFfect[/b] "
	var damage_text: String = ""
	
	var i: int = 0
	for damage_roll in system["damageRolls"].keys():
		if i > 0:
			damage_text += " plus "
		damage_text += system["damageRolls"][damage_roll]["damage"] + " " + system["damageRolls"][damage_roll]["damageType"] 
		i += 1
	if system.has("oneLineDamageRoll"):
		damage_text += system["oneLineDamageRoll"]
	
	if damage_text == "":
		damage_text = BASE_EFFECT_TEXT
	
	damage_text += get_damage_extra_effects(system, damage_text == "")
	
	damage_text = get_damage_roll_meta(damage_text)
	
	var extra_text: String = ""
	if system.has("rules"):
		var rules: Array = system["rules"]
		var condition_regex: RegEx = RegEx.new()
		condition_regex.compile("target:trait:(.*)")
		for rule: Dictionary in rules:
			# Check if has condition
			if rule["key"] != "DamageDice":
				continue
			if !rule.has("predicate"):
				continue
			
			var extra_damage_rule: String = evaluate_damage_rule(rule)
			if extra_damage_rule == "":
				continue
			if extra_text == "":
				extra_text = " ("
			extra_text += extra_damage_rule
		if !extra_text.is_empty():
			extra_text += ")"
	
	extra_text = get_damage_roll_meta(extra_text)
	
	damage_text += extra_text
	
	
	return BASE_DAMAGE_TEXT + damage_text

func evaluate_damage_rule(rule: Dictionary) -> String:
	if !rule.has("dieSize"):
		return ""
	var predicate: Array = rule["predicate"]
	var condition: String
	if predicate[0] is Dictionary:
		if predicate[0].has("or"):
			condition = predicate[0]["or"][0]
	else:
		condition = predicate[0]
	
	var target_trait_regex: RegEx = RegEx.new()
	target_trait_regex.compile("target:trait:(.*)")
	var target_condition_regex: RegEx = RegEx.new()
	target_condition_regex.compile("target:condition:(.*)")
	
	var extra_damage: String = rule["dieSize"]
	if rule.has("diceNumber"):
		extra_damage = extra_damage.insert(0, str(rule["diceNumber"]))
	var condition_text: String = "plus an additional " + extra_damage + " " + rule["damageType"] + " to "
	if target_trait_regex.search(condition) != null:
		condition_text += "targets with the " + target_trait_regex.search(condition).strings[1].replace("-", " ") + " trait"
	elif target_condition_regex.search(condition) != null:
		condition_text += target_condition_regex.search(condition).strings[1].replace("-", " ") + " targets"
	else:
		condition_text += condition.replace("-", " ") + " targets"
	
	return condition_text

func get_damage_extra_effects(ability_system: Dictionary, empty_damage: bool = false) -> String:
	if ability_system["attackEffects"]["value"].size() == 0:
		return ""
	
	var effects: String = ""
	if !empty_damage:
		effects += " plus "
	
	for n in ability_system["attackEffects"]["value"].size():
		if n > 0:
			effects += " and "
		effects += ability_system["attackEffects"]["value"][n].replace("-", " ")
	
	return effects

func setup_spells():
	var has_spells: bool = false
	
	# Holds every individual casting entry an enemy may have
	var spellcasting_entries = []
	
	# Verify that the enemy has spells
	for ability in enemy_abilities:
		if ability["type"] == "spellcastingEntry" && !ability["name"].to_lower().contains("staff"):
			has_spells = true
			if !ability.has("_id"):
				ability["_id"] = ""
			if ability["_id"] == "":
				ability["_id"] = ability["name"]
			spellcasting_entries.append(ability)
	
	if !has_spells:
		return
	attacks.visible = true
	
	for casting_entry in spellcasting_entries:
		new_casting_entry(casting_entry)

func new_casting_entry(casting_entry: Dictionary):
	var casting_type: String = casting_entry["system"]["prepared"]["value"]
	# Whether or not the spells are focus spells
	var is_focus: bool = casting_type == "focus"
	var id: String = casting_entry["_id"]
	var spell_tradition_name: String = casting_entry["name"]
	var dc: int = int(casting_entry["system"]["spelldc"]["dc"])
	var attack_roll: int = int(casting_entry["system"]["spelldc"]["value"])
	var cantrip_focus_level: int = clampi(ceili(enemy_system["details"]["level"]["value"] / 2), 1, 10)
	
	var dc_text: String = "DC " + str(dc) + ", "
	# Holds either tradition attack roll or its focus points
	
	# Initialize spell_list
	var spell_list: SheetContent = create_sheet_content()
	attacks.add_child(spell_list)
	
	spell_list.text = "[b]" + spell_tradition_name + "[/b] "
	spell_list.text += dc_text
	if !is_focus:
		var level_spell_text: Array[String] = ["", "", "", "", "", "", "", "", "", ""]
		var cantrip_text: String = ""
		var constant_spell_text: String = ""
		
		for spell in enemy_abilities:
			var is_constant: bool = false
			var is_cantrip: bool = false
			if spell["type"] != "spell":
				continue
			if spell["system"]["location"]["value"] == "":
				spell["system"]["location"]["value"] = id
			if spell["system"]["location"]["value"] != id:
				continue
			if spell["name"].to_lower().contains("(constant)"):
				is_constant = true
			if spell["system"]["traits"]["value"].has("cantrip"):
				is_cantrip = true 
			
			
			var spell_level: int
			if spell["system"]["location"].has("heightenedLevel"):
				spell_level = spell["system"]["location"]["heightenedLevel"]
			else:
				spell_level = spell["system"]["level"]["value"]
			
			if !is_cantrip && !is_constant:
				var spell_array_index: int = 10 - spell_level
				if level_spell_text[spell_array_index] == "":
					level_spell_text[spell_array_index] = "[b]" + ordinal_numbers(spell_level) + "[/b] "
				else:
					level_spell_text[spell_array_index] += ", "
			
				level_spell_text[spell_array_index] += "[i]" + spell["name"] + "[/i]"
				if casting_type == "prepared":
					if spell["system"]["location"].has("uses"):
						level_spell_text[spell_array_index] += " (x%s)" % spell["location"]["uses"]
			elif is_cantrip:
				if cantrip_text == "":
					cantrip_text = "[b]Cantrips (%s) [/b] " % ordinal_numbers(cantrip_focus_level)
				else:
					cantrip_text += ", "
				cantrip_text += "[i]" + spell["name"] + "[/i]"
			elif is_constant:
				if constant_spell_text == "":
					constant_spell_text = "[b]Constant (%s) [/b] " % ordinal_numbers(cantrip_focus_level)
				else:
					constant_spell_text += ", "
				constant_spell_text += "[i]" + spell["name"] + "[/i]"
		
		var spell_list_text: String = "[ul bullet=•]"
		for level in level_spell_text:
			if level == "":
				continue 
			spell_list_text += " " + level + "\n"
		if cantrip_text != "":
			spell_list_text += " " + cantrip_text + "\n"
		if constant_spell_text != "":
			spell_list_text += " " + constant_spell_text + "\n"
		
		spell_list.text += "attack +" + get_d20_meta(attack_roll, "Spell Attack")
		spell_list.text += spell_list_text
	else:
		var focus_spells_text: String = ""
		var focus_spell_count: int = 0
		for focus_spell in enemy_abilities:
			# Doesn't add cantrips to the list
			if focus_spell["type"] != "spell":
				continue
			if focus_spell["system"]["location"]["value"] != id:
				continue
			
			if focus_spell_count > 0:
				focus_spells_text += ", "
			focus_spells_text += focus_spell["name"]
			focus_spell_count += 1
		focus_spell_count = clamp(focus_spell_count, 1, 3)
		
		if focus_spell_count > 1:
			spell_list.text += str(focus_spell_count) + " Focus Points; "
		else:
			spell_list.text += str(focus_spell_count) + " Focus Point; "
		spell_list.text += "[b]" + ordinal_numbers(cantrip_focus_level) + "[/b] "
		spell_list.text += focus_spells_text

# Converts 1, 2, etc. to 1st, 2nd
func ordinal_numbers(number: int) -> String:
	var mod_number: int = number % 10
	match mod_number:
		1:
			return "1st"
		2:
			return "2nd"
		3:
			return "3rd"
		_:
			return str(number) + "th"

# Add in every remaining ability to the enemy
func setup_offensive_abilities():
	var text_interpreter: TextInterpreter = TextInterpreter.new()
	
	for ability in enemy_abilities:
		
		if !ability["system"].has("category"):
			continue
		
		if !ability["system"]["category"] is String:
			continue
		
		if (ability["system"]["category"] == "offensive") || (ability["system"]["category"] == "interaction" && ability["system"]["actionType"]["value"] == "action"):
			
			# Initialize ability
			var new_offensive_entry = create_sheet_content()
			new_offensive_entry.info_type = SheetContent.InfoTypes.TRAIT
			
			# Add name and icon
			var ability_name = "[b]" + ability["name"] + "[/b] "
			var action_icon := ""
			if ability["system"]["actionType"]["value"] == "free":
				action_icon = FREE_ACTION + " "
			elif ability["system"]["actions"]["value"] != null:
				var action_count = ability["system"]["actions"]["value"]
				match int(action_count):
					1:
						action_icon = ONE_ACTION + " "
					2:
						action_icon = TWO_ACTIVITY + " "
					3:
						action_icon = THREE_ACTIVITY + " "
			
			# Traits
			var ability_traits: String = "("
			var i: int = 0
			for ability_trait in ability["system"]["traits"]["value"]:
				var final_trait: String = text_interpreter.trait_name_parser(ability_trait)
				#ability_traits += get_sheet_tooltip("trait", final_trait) + final_trait + "[/hint]"
				ability_traits += final_trait
				i += 1
				if i < ability["system"]["traits"]["value"].size():
					ability_traits += ", "
			ability_traits += ") "
			if ability_traits == "() ":
				ability_traits = ""
			
			
			# Description
			var ability_description: String = text_interpreter.ability_parser(ability["system"]["description"]["value"])
			ability_description = get_damage_roll_meta(ability_description)
			
			new_offensive_entry.text = ability_name + action_icon + ability_traits + ability_description
			attacks.add_child(new_offensive_entry)
			attacks.visible = true

func get_d20_meta(number, type: String):
	var number_text: String = str(number)
	
	var roll_dictionary: Dictionary = {
		"type": "d20",
		"rolls": {
			type: "d20+" + number_text,
		}
	}
	
	var meta: String = "[url=" + JSON.stringify(roll_dictionary) + "]" + number_text + "[/url]"
	return meta


func get_damage_roll_meta(damage_text: String):
	var meta: String = damage_text
	
	var dice_count: String = "(?:\\d+)?"
	var dice_number: String = "d(?:\\d+)"
	var damage_bonus: String = "(?:\\s*\\+\\s*\\d+)?"
	var element: String = "(\\s+[a-zA-Z-]+)?"
	var damage_roll_regex: String = "(" + dice_count + dice_number + damage_bonus + ")" + element
	var roll_regex: RegEx = RegEx.new()
	roll_regex.compile(damage_roll_regex)
	var roll_matches: Array[RegExMatch] = roll_regex.search_all(damage_text)
	if roll_matches.is_empty():
		return meta
	for roll_match in roll_matches:
		var dice_roll: String = roll_match.strings[1]
		var roll_element: String = "damage"
		if roll_match.strings.size() > 2:
			roll_element = roll_match.strings[2].strip_edges()
		
		var roll_dictionary: Dictionary = {
				"type": "damage",
				"rolls": {
					roll_element: dice_roll,
				}
		}
		
		var tag: String = "[url=" + JSON.stringify(roll_dictionary) + "]" + roll_match.strings[0] + "[/url]"
		meta = meta.replace(roll_match.strings[0], tag)
	return meta

func create_sheet_content() -> SheetContent:
	var new_sheet_content: RichTextLabel = SHEET_CONTENT.instantiate()
	new_sheet_content.meta_clicked.connect(sheet_content_clicked)
	return new_sheet_content

func sheet_content_clicked(meta: Variant):
	var roll_json: JSON = JSON.new()
	roll_json.parse(str(meta))
	
	var roll_data: Dictionary = roll_json.get_data()
	EventBus.dice_roll.emit(roll_data, enemy_name.text)
	#EventBus.emit_signal("d20_rolled", meta.to_int(), enemy_name.text)

func get_sheet_tooltip(tooltip_type, tooltip_reference) -> String:
	var tooltip_list
	match tooltip_type:
		"sense":
			tooltip_list = Tooltips.senses_tooltips
		"trait":
			tooltip_list = Tooltips.traits_tooltips
	for tooltip in tooltip_list:
		if tooltip in tooltip_reference:
			return "[hint=" + tooltip_list[tooltip] + "]"
	return "[hint=]"
