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

# For zooming during runtime
static var sheet_theme: Theme = load("res://Themes/EnemySheetContext.tres")

func setup(enemy_file, conditions = {}):
	# Gets the enemy sheet data
	enemy_data = enemy_file
	
	enemy_system = enemy_data["system"]
	enemy_abilities = enemy_data["items"]
	enemy_attributes = enemy_system["attributes"]
	
	# Set up name and level
	if !conditions.has("custom_name"):
		enemy_name.text = enemy_data["name"]
	else:
		enemy_name.text = conditions["custom_name"]
	enemy_level.text = "CREATURE " + str(enemy_system["details"]["level"]["value"])
	
	
	
	# Set up traits
	setup_traits()
	# Enemy Source
	enemy_source.text = "[b]Source[/b] [i]" + enemy_system["details"]["source"]["value"] + "[/i]"
	
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
	senses.text = ""
	var perception = "[b]Perception[/b] " + "+" + "[url]" + str(enemy_system["attributes"]["perception"]["value"]) + "[/url]"
	
	var enemy_senses: Array
	if enemy_system["traits"]["senses"] is Array:
		enemy_senses = enemy_system["traits"]["senses"]
	else:
		enemy_senses = enemy_system["traits"]["senses"]["value"].split(",")
	var i: int = 0
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
		#enemy_senses[i] = get_sheet_tooltip("sense", sense) + sense + "[/hint]"
		senses.text += enemy_senses[i]
		if enemy_senses.size() > i + 1:
			senses.text += ", "
		i += 1

func setup_languages():
	if enemy_system["traits"]["languages"]["value"].is_empty():
		languages.visible = false
		return
	languages.visible = true
	languages.text = "[b]Languages[/b] "
	var monster_languages: Array = enemy_system["traits"]["languages"]["value"]
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
		var skill_text = "[i]" + skill["name"] + "[/i]" + " +" + "[url]" + str(skill["system"]["mod"]["value"]) + "[/url]"
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
	abilities.text += "[b]Str[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["str"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["dex"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Dex[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["dex"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["con"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Con[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["con"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["int"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Int[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["int"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["wis"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Wis[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["wis"]["mod"]) + "[/url]" + ", "
	if enemy_system["abilities"]["cha"]["mod"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	abilities.text += "[b]Cha[/b] " + positive_negative + "[url]" + str(enemy_system["abilities"]["cha"]["mod"]) + "[/url]"

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
	ac_saves.text += "[b]Fort[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["fortitude"]["value"]) + "[/url], "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Ref[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["reflex"]["value"]) + "[/url], "
	if enemy_system["saves"]["fortitude"]["value"] > 0:
		positive_negative = "+"
	else:
		positive_negative = ""
	ac_saves.text += "[b]Will[/b] " + positive_negative + "[url]" + str(enemy_system["saves"]["will"]["value"]) + "[/url]"
	
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
		var desc_text = text_interpreter.ability_parser(ability["system"]["description"]["value"])
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
			var attack_bonus_text: String = attack_plus + "[url]" + str(attack_bonus) + "[/url]" + " "
			if attack_bonus - multiple_attack_penalty < 0:
				attack_plus = ""
			attack_bonus_text += "[" + attack_plus + "[url]" + str(attack_bonus - multiple_attack_penalty) + "[/url]"
			if attack_bonus - multiple_attack_penalty * 2 < 0:
				attack_plus = ""
			attack_bonus_text += "/" + attack_plus + "[url]" + str(attack_bonus - multiple_attack_penalty * 2) + "[/url]" + "] "
			
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
			var damage_text: String = "[b]Damage[/b] "
			i = 0
			for damage_roll in ability["system"]["damageRolls"].keys():
				if i > 0:
					damage_text += " plus "
				damage_text += ability["system"]["damageRolls"][damage_roll]["damage"] + " " + ability["system"]["damageRolls"][damage_roll]["damageType"] 
				i += 1
			if ability["system"].has("oneLineDamageRoll"):
				damage_text += ability["system"]["oneLineDamageRoll"]
			
			new_attack_entry.text = melee + attack_icon + attack_name + attack_bonus_text + attack_traits + damage_text
			attacks.add_child(new_attack_entry)
	
	if attacks.get_child_count() > 0:
		attacks.visible = true


func setup_spells():
	var has_spells: bool = false
	
	# Holds every individual casting entry an enemy may have
	var spellcasting_entries = []
	
	
	# Verify that the enemy has spells
	for ability in enemy_abilities:
		if ability["type"] == "spellcastingEntry" && !ability["name"].to_lower().contains("staff"):
			has_spells = true
			spellcasting_entries.append(ability)
	
	if !has_spells:
		return
	attacks.visible = true
	
	for casting_entry in spellcasting_entries:
		setup_casting_entry(casting_entry)
	
 
func setup_casting_entry(ability):
	var spell_tradition_name: String = ""
	var dc: int = 0
	var attack_roll: int = 0
	
	# Whether or not the spells are focus spells
	var is_focus: bool = false
	
	if ability["system"]["prepared"]["value"] == "focus":
		is_focus = true
		
	spell_tradition_name = ability["name"]
	if dc is int:
		pass
	else:
		print("WHO THE FUCK ARE YOU")
		print(enemy_data["name"])
		print("AAA")
	dc = int(ability["system"]["spelldc"]["dc"])
	attack_roll = ability["system"]["spelldc"]["value"]
	var tradition_title: String = "[b]" + spell_tradition_name + "[/b] "
	var dc_text: String = "DC " + str(dc) + ", "
	# Holds either tradition attack roll or its focus points
	var attack_roll_focus_points_text: String = ""
	
	var focus_spell_names: Array[String] = []
	var focus_spell_count: int = 0
	if is_focus:
		# Gets the focus spells; done beforehand to count focus point number
		for focus_spell in enemy_abilities:
			# Doesn't add cantrips to the list
			if focus_spell["type"] != "spell":
				continue
			if focus_spell["system"]["category"]["value"] != "focus":
				continue
			
			focus_spell_names.append(focus_spell["name"])
			focus_spell_count += 1
		focus_spell_count = clamp(focus_spell_count, 1, 3)
	
	if !is_focus:
		attack_roll_focus_points_text = "attack +" + "[url]" + str(attack_roll) + "[/url]; "
	else:
		attack_roll_focus_points_text = str(focus_spell_count) + " Focus Points; [b]" + ordinal_numbers(int(ceili(enemy_system["details"]["level"]["value"] / 2))) + "[/b] "
	
	# Initialize spell_list
	var spell_list = create_sheet_content()
	spell_list.text = tradition_title + dc_text + attack_roll_focus_points_text
	attacks.add_child(spell_list)
	
	
	
	if !is_focus:
		# Find spells then sort by level
		
		spell_list.text += "[ul]"
		
		var has_normal_spells: bool = false
		var has_cantrips: bool = false
		var has_constant_spells: bool = false
		
		
		var spell_levels: Array[int] = []
		for spell in enemy_abilities:
			# Doesn't add cantrips to the list
			if spell["type"] != "spell":
				continue
			if (spell["system"]["category"]["value"] != "spell" && !is_focus):
				continue
			if spell["name"].to_lower().contains("(constant)"):
				has_constant_spells = true
				continue
			if spell["system"]["traits"]["value"].has("cantrip"):
				has_cantrips = true 
				continue
			has_normal_spells = true
			var spell_level: int
			if spell["system"]["location"].has("heightenedLevel"):
				spell_level = spell["system"]["location"]["heightenedLevel"]
			else:
				spell_level = spell["system"]["level"]["value"]
				
			if !spell_levels.has(spell_level):
				spell_levels.append(spell_level)
		spell_levels.sort()
		spell_levels.reverse()
		
		# Add non-cantrip and non-constant spells to the spell list
		if has_normal_spells:
			for spell_level in spell_levels:
				var spell_level_text: String = "[b]" + ordinal_numbers(spell_level) + "[/b] "
				for spell in enemy_abilities:
					if spell["type"] != "spell":
						continue
					if spell["system"]["category"]["value"] != "spell":
						continue
					if spell["system"]["traits"]["value"].has("cantrip") || spell["name"].contains("(Constant)"):
						continue
					# Adds the post-heightening level; the databse uses both of these to heighten. IDK why.
					var this_spell_level: int
					if spell["system"]["location"].has("heightenedLevel"):
						this_spell_level = spell["system"]["location"]["heightenedLevel"]
					else:
						this_spell_level = spell["system"]["level"]["value"]
						
					
					if this_spell_level == spell_level:
						spell_level_text += "[i]" + spell["name"].to_lower() + "[/i]"
					else:
						continue
					
					# Adds uses if a spell has multiple
					if spell["system"]["location"].has("uses"):
						spell_level_text += " [b](" + str(spell["system"]["location"]["uses"]["value"]) + "x)[/b]"
					
					spell_level_text += ", "
				# Makes the last spell end with "; " instead of ", "
				spell_level_text[-2] = ";"
				spell_list.text += spell_level_text + "\n"

		# Add cantrips to the spell list
		if has_cantrips:
			var cantrip_level: int
			if !spell_levels.is_empty():
				cantrip_level = spell_levels[0]
			else:
				cantrip_level = int(ceil(enemy_system["details"]["level"]["value"] / 2))
			var cantrips_text: String = "[b]Cantrips (" + ordinal_numbers(cantrip_level) + ")[/b] "
			for spell in enemy_abilities:
				if spell["type"] != "spell":
					continue
				if spell["system"]["traits"]["value"].has("cantrip"):
					cantrips_text += "[i]" + spell["name"].to_lower() + "[/i], "
			cantrips_text[-2] = ""
			spell_list.text += cantrips_text + "\n"
		
		# Add constant spells to the spell list
		if has_constant_spells:
			var constant_text: String = "[b]Constant[/b] "
			for spell in enemy_abilities:
				if spell["type"] != "spell":
					continue
				if spell["name"].contains("(Constant)"):
					var this_spell_level: int
					if spell["system"]["location"].has("heightenedLevel"):
						this_spell_level = spell["system"]["location"]["heightenedLevel"]
					else:
						this_spell_level = spell["system"]["level"]["value"]
					constant_text += "[i]" + spell["name"].replace(" (Constant)", "") + "[/i] (" + ordinal_numbers(this_spell_level) + "), "
			constant_text[-2] = ""
			spell_list.text += constant_text
		spell_list.text += "[/ul]"
	else:
		for focus_spell in focus_spell_names:
			spell_list.text += focus_spell
			if focus_spell != focus_spell_names[-1]:
				spell_list.text += ", "
		

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
			
			
			new_offensive_entry.text = ability_name + action_icon + ability_traits + ability_description
			attacks.add_child(new_offensive_entry)
			attacks.visible = true

func create_sheet_content() -> SheetContent:
	var new_sheet_content: RichTextLabel = SHEET_CONTENT.instantiate()
	new_sheet_content.meta_clicked.connect(sheet_content_clicked)
	return new_sheet_content

func sheet_content_clicked(meta):
	EventBus.emit_signal("d20_rolled", meta.to_int(), enemy_name.text)

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
