extends Node

#region Onreadies

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

const ABILITY_MODIFIERS: String				 = "res://Custom/Roadmap Tables/Ability Modifiers.csv"
const AREA_DAMAGE: String					 = "res://Custom/Roadmap Tables/Area Damage.csv"
const ARMOR_CLASS: String					 = "res://Custom/Roadmap Tables/Armor Class.csv"
const HIT_POINTS: String					 = "res://Custom/Roadmap Tables/Hit Points.csv"
const PERCEPTION: String					 = "res://Custom/Roadmap Tables/Perception.csv"
const RESISTANCES_AND_WEAKNESSES: String	 = "res://Custom/Roadmap Tables/Resistances and Weaknesses.csv"
const SAFE_ITEMS: String					 = "res://Custom/Roadmap Tables/Safe Items.csv"
const SAVING_THROWS: String					 = "res://Custom/Roadmap Tables/Saving Throws.csv"
const SKILLS: String						 = "res://Custom/Roadmap Tables/Skills.csv"
const SPELL_ATTACK: String					 = "res://Custom/Roadmap Tables/Spell Attack.csv"
const SPELL_D_CS: String					 = "res://Custom/Roadmap Tables/Spell DCs.csv"
const STRIKE_ATTACK_BONUS: String			 = "res://Custom/Roadmap Tables/Strike Attack Bonus.csv"
const STRIKE_DAMAGE: String					 = "res://Custom/Roadmap Tables/Strike Damage.csv"

const CASTING_ENTRY = preload("res://Custom/CastingEntry.tscn")

var ability_modifier_table: Array = []		# extreme - high - moderate - low
var ac_table: Array = []					# extreme - high - moderate - low
var hp_table: Array = []					# high - moderate - low
var perception_table: Array = []			# extreme - high - moderate - low - terrible
var saving_throws_table: Array = []			# extreme - high - moderate - low - terrible
var skills_table: Array = []				# extreme - high - moderate - low
var spell_attack_table: Array = []			# extreme - high - moderate
var spell_dcs_table: Array = []				# extreme - high - moderate
var strike_attack_table: Array = []			# extreme - high - moderate - low
var strike_damage_table: Array = []			# extreme - high - moderate - low

func _ready() -> void:
	populate_local_array(ability_modifier_table, ABILITY_MODIFIERS)
	populate_local_array(ac_table, ARMOR_CLASS)
	populate_local_array(hp_table, HIT_POINTS)
	populate_local_array(perception_table, PERCEPTION)
	populate_local_array(saving_throws_table, SAVING_THROWS)
	populate_local_array(skills_table, SKILLS)
	populate_local_array(spell_attack_table, SPELL_ATTACK)
	populate_local_array(spell_dcs_table, SPELL_D_CS)
	populate_local_array(strike_attack_table, STRIKE_ATTACK_BONUS)
	populate_local_array(strike_damage_table, STRIKE_DAMAGE)

func populate_local_array(array: Array, file: String):
	var csv_accessor: FileAccess = FileAccess.open(file, FileAccess.READ)
	var csv_line: PackedStringArray = csv_accessor.get_csv_line()
	while (csv_line[0] != ""):
		array.append(csv_line)
		csv_line = csv_accessor.get_csv_line()

func get_table_value_by_level(table: Array, level: int, column: int):
	level += 1 # Since level starts at -1, rather than 0
	return table[level][column]

func autofill_clicked() -> void:
	var level_number: int = int(level_field.get_value())
	if level_number < -1 || level_number > 24:
		return
	
	source_field.set_value("Custom Enemy")
	match option_button.selected:
		0:
			fill_brute(level_number)
		1:
			fill_magical_striker(level_number)
		2:
			fill_skill_paragon(level_number)
		3:
			fill_skirmisher(level_number)
		4:
			fill_sniper(level_number)
		5:
			fill_soldier(level_number)
		6:
			fill_spellcaster(level_number)

func fill_brute(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 3))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 3))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 0))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 1), get_table_value_by_level(strike_damage_table, level, 1)
	)
	

func fill_magical_striker(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 2))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 2))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 1))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 1), get_table_value_by_level(strike_damage_table, level, 1)
	)
	
	var new_casting_entry: CastingEntry = CASTING_ENTRY.instantiate()
	casting_entry_tabs.add_child(new_casting_entry)
	new_casting_entry.name = "Roadmap Spells"
	new_casting_entry.entry_name_field.set_value("Roadmap Spells")
	new_casting_entry.spell_dc_field.set_value(get_table_value_by_level(spell_dcs_table, level, 1))
	new_casting_entry.spell_attack_field.set_value(get_table_value_by_level(spell_attack_table, level, 1))
	


func fill_skill_paragon(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 1))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 2))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 2))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 2), get_table_value_by_level(strike_damage_table, level, 2)
	)


func fill_skirmisher(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 1))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 1))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 1))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 1), get_table_value_by_level(strike_damage_table, level, 2)
	)



func fill_sniper(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 1))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 2))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 2))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 1), get_table_value_by_level(strike_damage_table, level, 1), true
	)
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 3), get_table_value_by_level(strike_damage_table, level, 3)
	)


func fill_soldier(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 2))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 1))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 0))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 1), get_table_value_by_level(strike_damage_table, level, 1)
	)


func fill_spellcaster(level: int):
	perception_field.set_value(get_table_value_by_level(perception_table, level, 2))
	
	str_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	dex_field.set_value(get_table_value_by_level(ability_modifier_table, level, 2))
	con_field.set_value(get_table_value_by_level(ability_modifier_table, level, 3))
	int_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	wis_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	cha_field.set_value(get_table_value_by_level(ability_modifier_table, level, 1))
	
	ac_field.set_value(get_table_value_by_level(ac_table, level, 2))
	fortitude_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 3))
	reflex_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 2))
	will_save_field.set_value(get_table_value_by_level(saving_throws_table, level, 1))
	
	hp_field.set_value(get_table_value_by_level(hp_table, level, 2))
	
	attacks.new_data_attack(
		get_table_value_by_level(strike_attack_table, level, 3), get_table_value_by_level(strike_damage_table, level, 3)
	)
	
	
	var new_casting_entry: CastingEntry = CASTING_ENTRY.instantiate()
	casting_entry_tabs.add_child(new_casting_entry)
	new_casting_entry.name = "Roadmap Spells"
	new_casting_entry.entry_name_field.set_value("Roadmap Spells")
	new_casting_entry.spell_dc_field.set_value(get_table_value_by_level(spell_dcs_table, level, 0))
	new_casting_entry.spell_attack_field.set_value(get_table_value_by_level(spell_attack_table, level, 0))
